module constant_product_market_maker::constant_product_market_maker {
    use aptos_framework::event;
    use aptos_framework::fungible_asset::{Self, BurnRef, MintRef, Metadata};
    use aptos_framework::object::{Self, ExtendRef, Object, ObjectGroup};
    use aptos_framework::primary_fungible_store;
    use aptos_std::math128;
    use aptos_std::math64;
    use std::option;
    use std::signer;
    use std::string::String;

    /// All base has been removed from the pool. It is dead.
    const E_DEAD_POOL_NO_BASE: u64 = 0;
    /// All quote has been removed from the pool. It is dead.
    const E_DEAD_POOL_NO_QUOTE: u64 = 1;
    /// Unable to add quote reserves due to overflow.
    const E_ADD_QUOTE_OVERFLOW: u64 = 2;
    /// Unable to add base reserves due to overflow.
    const E_ADD_BASE_OVERFLOW: u64 = 3;
    /// May not mint more than (2^64 - 1) liquidity provider tokens.
    const E_MINT_AMOUNT_OVERFLOW: u64 = 4;
    /// No pool at specified address.
    const E_NO_POOL: u64 = 5;
    /// Actual base asset in the pool is less than expected reserves.
    const E_BASE_NOT_COLLATERALIZED: u64 = 6;
    /// Actual quote asset in the pool is less than expected reserves.
    const E_QUOTE_NOT_COLLATERALIZED: u64 = 7;

    const BASIS_POINTS_PER_UNIT: u16 = 10_000;
    const U64_MAX: u128 = 0xffffffffffffffff;

    #[resource_group_member(group = ObjectGroup)]
    struct Pool has key {
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
        base_reserve: u64,
        quote_reserve: u64,
        fee_rate_in_basis_points: u16,
        pool_extend_ref: ExtendRef,
        lp_token_mint_ref: MintRef,
        lp_token_burn_ref: BurnRef,
    }

    struct AssetMetadata has drop, store {
        metadata_address: address,
        name: String,
        symbol: String,
        decimals: u8,
    }

    struct PoolInfo {
        pool_address: address,
        base_asset_metadata: AssetMetadata,
        quote_asset_metadata: AssetMetadata,
        base_reserve: u64,
        actual_base_in_store: u64,
        quote_reserve: u64,
        actual_quote_in_store: u64,
        fee_rate_in_basis_points: u16,
        lp_token_metadata: AssetMetadata,
        lp_token_supply: u128
    }

    #[event]
    struct SwapEvent has drop, store {
        pool_address: address,
        swapper_address: address,
        input_asset_metadata: AssetMetadata,
        output_asset_metadata: AssetMetadata,
        input_amount: u64,
        input_is_base: bool,
        fee_rate_in_basis_points: u16,
        fee_in_output_asset: u64,
        output_amount_after_fees: u64,
        price_impact_including_fees_in_basis_points: u16,
    }

    public entry fun add_liquidity(
        provider: &signer,
        pool_address: address,
        quote_amount: u64,
    ) acquires Pool {
        let (
            pool_ref_mut,
            base_metadata,
            quote_metadata,
            base_reserve,
            actual_base_in_store,
            quote_reserve,
            actual_quote_in_store
        ) = check_and_borrow_pool_with_core_fields_mut(
            pool_address,
            true,
            true,
        );
        let quote_reserve_new =
            (quote_reserve as u128) + (quote_amount as u128);
        let actual_quote_in_store_new =
            (actual_quote_in_store as u128) + (quote_amount as u128);
        assert!(actual_quote_in_store_new <= U64_MAX, E_ADD_QUOTE_OVERFLOW);
        let base_reserve_new = math128::mul_div(
            (base_reserve as u128),
            quote_reserve_new,
            (quote_reserve as u128)
        );
        let base_amount = (base_reserve_new as u128) - (base_reserve as u128);
        let actual_base_in_store_new =
            (actual_base_in_store as u128) + (base_amount);
        assert!(actual_base_in_store_new <= U64_MAX, E_ADD_BASE_OVERFLOW);
        primary_fungible_store::transfer(
            provider,
            base_metadata,
            pool_address,
            (base_amount as u64)
        );
        primary_fungible_store::transfer(
            provider,
            quote_metadata,
            pool_address,
            quote_amount
        );
        let lp_token_supply = get_lp_token_supply_unchecked(pool_address);
        let mint_amount = math128::mul_div(
            lp_token_supply,
            (quote_amount as u128),
            quote_reserve_new
        );
        assert!(mint_amount < U64_MAX, E_MINT_AMOUNT_OVERFLOW);
        primary_fungible_store::mint(
            &pool_ref_mut.lp_token_mint_ref,
            signer::address_of(provider),
            (mint_amount as u64),
        );
        pool_ref_mut.base_reserve = (base_reserve_new as u64);
        pool_ref_mut.quote_reserve = (quote_reserve_new as u64);
    }

    public entry fun create_pool(
        creator: &signer,
        base_reserve: u64,
        quote_reserve: u64,
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
        fee_rate_in_basis_points: u16,
        lp_token_name: String,
        lp_token_symbol: String,
        lp_token_decimals: u8,
        lp_token_icon_uri: String,
        lp_token_project_uri: String,
        lp_token_initial_supply: u64,
    ) {
        let creator_address = signer::address_of(creator);
        let constructor_ref = object::create_object(creator_address);
        let pool_address =
            object::address_from_constructor_ref(&constructor_ref);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
           &constructor_ref,
           option::none(),
           lp_token_name,
           lp_token_symbol,
           lp_token_decimals,
           lp_token_icon_uri,
           lp_token_project_uri,
        );
        primary_fungible_store::transfer(
            creator,
            base_metadata,
            pool_address,
            base_reserve,
        );
        primary_fungible_store::transfer(
            creator,
            quote_metadata,
            pool_address,
            quote_reserve,
        );
        let pool_signer = object::generate_signer(&constructor_ref);
        let lp_token_mint_ref =
            fungible_asset::generate_mint_ref(&constructor_ref);
        primary_fungible_store::mint(
            &lp_token_mint_ref,
            creator_address,
            lp_token_initial_supply,
        );
        move_to(
            &pool_signer,
            Pool{
                base_metadata,
                base_reserve,
                quote_metadata,
                quote_reserve,
                fee_rate_in_basis_points,
                pool_extend_ref:
                    object::generate_extend_ref(&constructor_ref),
                lp_token_mint_ref,
                lp_token_burn_ref:
                    fungible_asset::generate_burn_ref(&constructor_ref),
            },
        );
    }

    public entry fun remove_liquidity(
        provider: &signer,
        pool_address: address,
        lp_tokens_to_burn: u64,
    ) acquires Pool {
        let (
            pool_ref_mut,
            base_metadata,
            quote_metadata,
            base_reserve,
            actual_base_in_store,
            quote_reserve,
            actual_quote_in_store
        ) = check_and_borrow_pool_with_core_fields_mut(
            pool_address,
            false,
            false,
        );
        let lp_token_supply = get_lp_token_supply_unchecked(pool_address);
        primary_fungible_store::burn(
            &pool_ref_mut.lp_token_burn_ref,
            signer::address_of(provider),
            lp_tokens_to_burn,
        );
        let lp_token_supply_new = get_lp_token_supply_unchecked(pool_address);
        let base_reserve_new = math128::mul_div(
            (base_reserve as u128),
            lp_token_supply_new,
            lp_token_supply
        );
        let quote_reserve_new = math128::mul_div(
            (quote_reserve as u128),
            lp_token_supply_new,
            lp_token_supply
        );
        let new_base_in_store = math128::mul_div(
            (actual_base_in_store as u128),
            lp_token_supply_new,
            lp_token_supply
        );
        let new_quote_in_store = math128::mul_div(
            (actual_quote_in_store as u128),
            lp_token_supply_new,
            lp_token_supply
        );
        let provider_address = signer::address_of(provider);
        let pool_signer = get_pool_signer(pool_ref_mut);
        primary_fungible_store::transfer(
            &pool_signer,
            base_metadata,
            provider_address,
            actual_base_in_store - (new_base_in_store as u64),
        );
        primary_fungible_store::transfer(
            &pool_signer,
            quote_metadata,
            provider_address,
            actual_quote_in_store - (new_quote_in_store as u64),
        );
        pool_ref_mut.base_reserve = (base_reserve_new as u64);
        pool_ref_mut.quote_reserve = (quote_reserve_new as u64);
    }

    public entry fun swap(
        swapper: &signer,
        pool_address: address,
        input_is_base: bool,
        input_amount: u64,
    ) acquires Pool {
        let (
            pool_ref_mut,
            base_metadata,
            quote_metadata,
            base_reserve,
            actual_base_in_store,
            quote_reserve,
            actual_quote_in_store
        ) = check_and_borrow_pool_with_core_fields_mut(
            pool_address,
            true,
            true,
        );
        let pool_signer = get_pool_signer(pool_ref_mut);
        let (
            input_metadata,
            input_reserve,
            input_in_store,
            output_metadata,
            output_reserve,
            input_overflow_e_code,
            input_reserve_ref_mut,
            output_reserve_ref_mut,
        ) = if (input_is_base) (
            base_metadata,
            base_reserve,
            actual_base_in_store,
            quote_metadata,
            quote_reserve,
            E_ADD_BASE_OVERFLOW,
            &mut pool_ref_mut.base_reserve,
            &mut pool_ref_mut.quote_reserve,
        ) else (
            quote_metadata,
            quote_reserve,
            actual_quote_in_store,
            base_metadata,
            base_reserve,
            E_ADD_QUOTE_OVERFLOW,
            &mut pool_ref_mut.quote_reserve,
            &mut pool_ref_mut.base_reserve,
        );
        let input_reserve_new =
            (input_reserve as u128) + (input_amount as u128);
        let input_in_store_new =
            (input_in_store as u128) + (input_amount as u128);
        assert!(input_in_store_new <= U64_MAX, input_overflow_e_code);
        let output_reserve_new = math128::mul_div(
            (input_reserve as u128),
            (output_reserve as u128),
            input_reserve_new
        );
        let output_amount_before_fee =
            output_reserve - (output_reserve_new as u64);
        let fee = math64::mul_div(
            output_amount_before_fee,
            (BASIS_POINTS_PER_UNIT as u64),
            (pool_ref_mut.fee_rate_in_basis_points as u64),
        );
        let output_amount = output_amount_before_fee - fee;
        let swapper_address = signer::address_of(swapper);
        primary_fungible_store::transfer(
            swapper,
            input_metadata,
            pool_address,
            input_amount,
        );
        primary_fungible_store::transfer(
            &pool_signer,
            output_metadata,
            swapper_address,
            output_amount,
        );
        *input_reserve_ref_mut = (input_reserve_new as u64);
        *output_reserve_ref_mut = (output_reserve_new as u64);
        let (final_price_base, final_price_quote) = if (input_is_base)
            (input_amount, output_amount) else (output_amount, input_amount);
        let price_impact_including_fees_in_basis_points = price_impact(
            base_reserve,
            final_price_base,
            quote_reserve,
            final_price_quote
        );
        event::emit(SwapEvent {
            pool_address,
            swapper_address,
            input_asset_metadata: get_asset_metadata_view(input_metadata),
            output_asset_metadata: get_asset_metadata_view(output_metadata),
            input_amount,
            input_is_base,
            fee_rate_in_basis_points: pool_ref_mut.fee_rate_in_basis_points,
            fee_in_output_asset: fee,
            output_amount_after_fees: output_amount,
            price_impact_including_fees_in_basis_points
        });
    }

    #[view]
    public fun pool_info(
        pool_address: address,
    ): PoolInfo
    acquires Pool {
        let (
            pool_ref,
            base_metadata,
            quote_metadata,
            base_reserve,
            actual_base_in_store,
            quote_reserve,
            actual_quote_in_store
        ) = check_and_borrow_pool_with_core_fields(
            pool_address,
            false,
            false,
        );
        PoolInfo {
            pool_address,
            base_asset_metadata: get_asset_metadata_view(base_metadata),
            base_reserve,
            actual_base_in_store,
            quote_asset_metadata: get_asset_metadata_view(quote_metadata),
            quote_reserve,
            actual_quote_in_store,
            fee_rate_in_basis_points: pool_ref.fee_rate_in_basis_points,
            lp_token_metadata: get_asset_metadata_view(
                object::address_to_object<Metadata>(pool_address)
            ),
            lp_token_supply: get_lp_token_supply_unchecked(pool_address)
        }
    }

    inline fun check_and_borrow_pool_with_core_fields(
        pool_address: address,
        check_dead_pool: bool,
        check_collateralization: bool,
    ): (
        &Pool,
        Object<Metadata>,
        Object<Metadata>,
        u64,
        u64,
        u64,
        u64,
    ) acquires Pool {
        check_and_borrow_pool_with_core_fields_mut(
            pool_address,
            check_dead_pool,
            check_collateralization
        )
    }

    inline fun check_and_borrow_pool_with_core_fields_mut(
        pool_address: address,
        check_dead_pool: bool,
        check_collateralization: bool,
    ): (
        &mut Pool,
        Object<Metadata>,
        Object<Metadata>,
        u64,
        u64,
        u64,
        u64,
    ) acquires Pool {
        assert!(exists<Pool>(pool_address), E_NO_POOL);
        let pool_ref_mut = borrow_global_mut<Pool>(pool_address);
        let base_metadata = pool_ref_mut.base_metadata;
        let quote_metadata = pool_ref_mut.quote_metadata;
        let base_reserve = pool_ref_mut.base_reserve;
        let actual_base_in_store =
            primary_fungible_store::balance(pool_address, base_metadata);
        let quote_reserve = pool_ref_mut.quote_reserve;
        let actual_quote_in_store =
            primary_fungible_store::balance(pool_address, quote_metadata);
        if (check_dead_pool) {
            assert!(base_reserve != 0, E_DEAD_POOL_NO_BASE);
            assert!(quote_reserve != 0, E_DEAD_POOL_NO_QUOTE);
        };
        if (check_collateralization) {
            assert!(
                actual_base_in_store >= base_reserve,
                E_BASE_NOT_COLLATERALIZED
            );
            assert!(
                actual_quote_in_store >= quote_reserve,
                E_QUOTE_NOT_COLLATERALIZED
            );
        };
        (
            pool_ref_mut,
            base_metadata,
            quote_metadata,
            base_reserve,
            actual_base_in_store,
            quote_reserve,
            actual_quote_in_store,
        )
    }

    inline fun get_asset_metadata_view(
        metadata: Object<Metadata>,
    ): AssetMetadata {
        AssetMetadata {
            metadata_address: object::object_address(&metadata),
            name: fungible_asset::name(metadata),
            symbol: fungible_asset::symbol(metadata),
            decimals: fungible_asset::decimals(metadata),
        }
    }

    inline fun get_lp_token_supply_unchecked(
        pool_address: address,
    ): u128 {
        option::destroy_some(
            fungible_asset::supply<Pool>(
                object::address_to_object(pool_address)
            )
        )
    }

    inline fun get_pool_signer(
        pool_ref: &Pool
    ): signer {
        object::generate_signer_for_extending(&pool_ref.pool_extend_ref)
    }

    inline fun price_impact(
        _base_initial: u64,
        _base_final: u64,
        _quote_initial: u64,
        _quote_final: u64
    ): u16 {
        1
    }

}