module aptos_framework::cpmm {
    use aptos_framework::fungible_asset::{Self, BurnRef, MintRef, Metadata};
    use aptos_framework::object::{Self, ExtendRef, Object, ObjectGroup};
    use aptos_framework::primary_fungible_store;
    use aptos_std::math128;
    use aptos_std::math64;
    use std::option;
    use std::signer;
    use std::string::String;

    /// All liquidity has been removed from the pool. It is dead.
    const E_DEAD_POOL: u64 = 0;
    /// Unable to add quote reserves due to overflow.
    const E_ADD_QUOTE_OVERFLOW: u64 = 1;
    /// Unable to add base reserves due to overflow.
    const E_ADD_BASE_OVERFLOW: u64 = 2;
    /// May not mint more than (2^64 - 1) liquidity provider tokens.
    const E_MINT_AMOUNT_OVERFLOW: u64 = 3;
    /// No pool at specified address.
    const E_NO_POOL: u64 = 4;

    const BASIS_POINTS_PER_UNIT: u16 = 10_000;
    const U64_MAX: u128 = 0xffffffffffffffff;

    #[resource_group_member(group = ObjectGroup)]
    struct Pool has key {
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
        base_reserve: u64,
        quote_reserve: u64,
        fee_in_basis_points: u16,
        pool_extend_ref: ExtendRef,
        lp_token_mint_ref: MintRef,
        lp_token_burn_ref: BurnRef,
    }

    struct AssetMetadata {
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
        quote_reserve: u64,
        fee_in_basis_points: u16,
        lp_token_metadata: AssetMetadata,
    }

    struct SwapEvent {
        pool_address: address,
        swapper_address: address,
        input_asset_metadata: AssetMetadata,
        output_asset_metadata: AssetMetadata,
        input_amount: u64,
        input_is_base: bool,
        fee_in_basis_points: u16,
        fee_in_output_asset: u16,
        output_amount_after_fees: u64,
        slippage_after_fees_in_basis_points: u16,
    }

    public entry fun create_pool(
        creator: &signer,
        base_reserve: u64,
        quote_reserve: u64,
        base_metadata: Object<Metadata>,
        quote_metadata: Object<Metadata>,
        fee_in_basis_points: u16,
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
                fee_in_basis_points,
                pool_extend_ref:
                    object::generate_extend_ref(&constructor_ref),
                lp_token_mint_ref,
                lp_token_burn_ref:
                    fungible_asset::generate_burn_ref(&constructor_ref),
            },
        );
    }

    public entry fun add_liquidity(
        provider: &signer,
        pool_address: address,
        quote_amount: u64,
    ) acquires Pool {
        let (pool_ref_mut, base_reserve, quote_reserve) =
            check_and_borrow_pool_with_reserves_mut(pool_address);
        let quote_reserve_new =
            (quote_reserve as u128) + (quote_amount as u128);
        assert!(quote_reserve_new <= U64_MAX, E_ADD_QUOTE_OVERFLOW);
        let base_reserve_new = math128::mul_div(
            (base_reserve as u128),
            quote_reserve_new,
            (quote_reserve as u128)
        );
        assert!(base_reserve_new <= U64_MAX, E_ADD_BASE_OVERFLOW);
        primary_fungible_store::transfer(
            provider,
            pool_ref_mut.base_metadata,
            pool_address,
            (base_reserve_new as u64) - base_reserve
        );
        primary_fungible_store::transfer(
            provider,
            pool_ref_mut.quote_metadata,
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

    public entry fun remove_liquidity(
        provider: &signer,
        pool_address: address,
        lp_tokens_to_burn: u64,
    ) acquires Pool {
        let (pool_ref_mut, base_reserve, quote_reserve) =
            check_and_borrow_pool_with_reserves_mut(pool_address);
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
        let provider_address = signer::address_of(provider);
        let pool_signer = get_pool_signer(pool_ref_mut);
        primary_fungible_store::transfer(
            &pool_signer,
            pool_ref_mut.base_metadata,
            provider_address,
            base_reserve - (base_reserve_new as u64),
        );
        primary_fungible_store::transfer(
            &pool_signer,
            pool_ref_mut.quote_metadata,
            provider_address,
            quote_reserve - (quote_reserve_new as u64),
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
        let (pool_ref_mut, base_reserve, quote_reserve) =
            check_and_borrow_pool_with_reserves_mut(pool_address);
        let pool_signer = get_pool_signer(pool_ref_mut);
        let (
            input_metadata,
            input_reserve,
            output_metadata,
            output_reserve,
            input_overflow_e_code,
            input_reserve_ref_mut,
            output_reserve_ref_mut,
        ) = if (input_is_base) (
            pool_ref_mut.base_metadata,
            base_reserve,
            pool_ref_mut.quote_metadata,
            quote_reserve,
            E_ADD_BASE_OVERFLOW,
            &mut pool_ref_mut.base_reserve,
            &mut pool_ref_mut.quote_reserve,
        ) else (
            pool_ref_mut.quote_metadata,
            quote_reserve,
            pool_ref_mut.base_metadata,
            base_reserve,
            E_ADD_QUOTE_OVERFLOW,
            &mut pool_ref_mut.quote_reserve,
            &mut pool_ref_mut.base_reserve,
        );
        let input_reserve_new =
            (input_reserve as u128) + (input_amount as u128);
        assert!(input_reserve_new <= U64_MAX, input_overflow_e_code);
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
            (pool_ref_mut.fee_in_basis_points as u64),
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
    }

    #[view]
    public fun pool_info(
        pool_address: address,
    ): PoolInfo
    acquires Pool {
        let (pool_ref, base_reserve, quote_reserve) =
            check_and_borrow_pool_with_reserves(pool_address);
        PoolInfo {
            pool_address,
            base_asset_metadata:
                get_asset_metadata_view(pool_ref.base_metadata),
            base_reserve,
            quote_asset_metadata:
                get_asset_metadata_view(pool_ref.quote_metadata),
            quote_reserve,
            fee_in_basis_points: pool_ref.fee_in_basis_points,
            lp_token_metadata: get_asset_metadata_view(
                object::address_to_object<Metadata>(pool_address)
            ),
        }
    }

    inline fun check_and_borrow_pool_with_reserves(
        pool_address: address,
    ): (
        &Pool,
        u64,
        u64,
    ) acquires Pool {
        check_and_borrow_pool_with_reserves_mut(pool_address)
    }

    inline fun check_and_borrow_pool_with_reserves_mut(
        pool_address: address,
    ): (
        &mut Pool,
        u64,
        u64,
    ) acquires Pool {
        assert!(exists<Pool>(pool_address), E_NO_POOL);
        let pool_ref_mut = borrow_global_mut<Pool>(pool_address);
        assert!(
            pool_ref_mut.base_reserve != 0 && pool_ref_mut.quote_reserve != 0,
            E_DEAD_POOL
        );
        let base_reserve = pool_ref_mut.base_reserve;
        let quote_reserve = pool_ref_mut.quote_reserve;
        (pool_ref_mut, base_reserve, quote_reserve)
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

    inline fun get_pool_signer(
        pool_ref: &Pool
    ): signer {
        object::generate_signer_for_extending(&pool_ref.pool_extend_ref)
    }

}