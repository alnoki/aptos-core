module aptos_framework::cpmm {
    use aptos_framework::fungible_asset::{Self, BurnRef, MintRef, Metadata};
    use aptos_framework::object::{Self, Object, ObjectGroup};
    use aptos_framework::primary_fungible_store;
    use aptos_std::math128;
    use std::option;
    use std::signer;
    use std::string::String;

    /// Quote metadata does not match that of pool.
    const E_INVALID_QUOTE: u64 = 0;
    /// All liquidity has been removed from the pool. It is dead.
    const E_DEAD_POOL: u64 = 1;
    /// Unable to add liquidity due to quote overflow.
    const E_ADD_QUOTE_OVERFLOW: u64 = 2;
    /// Unable to add liquidity due to base overflow.
    const E_ADD_BASE_OVERFLOW: u64 = 3;
    /// May not mint more than (2^64 - 1) liquidity provider tokens.
    const E_MINT_AMOUNT_OVERFLOW: u64 = 4;

    const U64_MAX: u128 = 0xffffffffffffffff;

    #[resource_group_member(group = ObjectGroup)]
    struct Pool has key {
        base_metadata: Object<Metadata>,
        base_reserve: u64,
        quote_metadata: Object<Metadata>,
        quote_reserve: u64,
        constant_product: u128,
        fee_in_basis_points: u16,
        mint_ref: MintRef,
        burn_ref: BurnRef,
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
        let mint_ref = fungible_asset::generate_mint_ref(&constructor_ref);
        primary_fungible_store::mint(
            &mint_ref,
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
                constant_product: (base_reserve as u128) * (quote_reserve as u128),
                fee_in_basis_points,
                mint_ref,
                burn_ref: fungible_asset::generate_burn_ref(&constructor_ref),
            },
        );
    }

    public entry fun add_liquidity(
        provider: &signer,
        pool_address: address,
        quote_metadata: Object<Metadata>,
        quote_amount: u64,
    ) acquires Pool {
        let pool_ref_mut = borrow_global_mut<Pool>(pool_address);
        assert!(
            quote_metadata == pool_ref_mut.quote_metadata,
            E_INVALID_QUOTE,
        );
        assert!(
            pool_ref_mut.base_reserve != 0 || pool_ref_mut.quote_reserve != 0,
            E_DEAD_POOL
        );
        let quote_reserve_new =
            (pool_ref_mut.quote_reserve as u128) + (quote_amount as u128);
        assert!(quote_reserve_new <= U64_MAX, E_ADD_QUOTE_OVERFLOW);
        let base_reserve_new =
            pool_ref_mut.constant_product / quote_reserve_new;
        assert!(base_reserve_new <= U64_MAX, E_ADD_BASE_OVERFLOW);
        let base_amount =
            (base_reserve_new as u64) - pool_ref_mut.base_reserve;
        primary_fungible_store::transfer(
            provider,
            quote_metadata,
            pool_address,
            quote_amount
        );
        primary_fungible_store::transfer(
            provider,
            pool_ref_mut.base_metadata,
            pool_address,
            base_amount
        );
        let lp_token_supply = option::destroy_some(
            fungible_asset::supply<Pool>(
                object::address_to_object(pool_address)
            )
        );
        let mint_amount = math128::mul_div(
            lp_token_supply,
            (quote_amount as u128),
            quote_reserve_new
        );
        assert!(mint_amount < U64_MAX, E_MINT_AMOUNT_OVERFLOW);
        primary_fungible_store::mint(
            &pool_ref_mut.mint_ref,
            signer::address_of(provider),
            (mint_amount as u64),
        );
        pool_ref_mut.quote_reserve = (quote_reserve_new as u64);
        pool_ref_mut.base_reserve = (base_reserve_new as u64)
    }
}