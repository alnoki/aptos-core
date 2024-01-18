
<a id="0x1_cpmm"></a>

# Module `0x1::cpmm`



-  [Resource `Pool`](#0x1_cpmm_Pool)
-  [Constants](#@Constants_0)
-  [Function `create_pool`](#0x1_cpmm_create_pool)
-  [Function `add_liquidity`](#0x1_cpmm_add_liquidity)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/error.md#0x1_error">0x1::error</a>;
<b>use</b> <a href="fungible_asset.md#0x1_fungible_asset">0x1::fungible_asset</a>;
<b>use</b> <a href="object.md#0x1_object">0x1::object</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="primary_fungible_store.md#0x1_primary_fungible_store">0x1::primary_fungible_store</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">0x1::signer</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string">0x1::string</a>;
</code></pre>



<a id="0x1_cpmm_Pool"></a>

## Resource `Pool`



<pre><code>#[resource_group_member(#[group = <a href="object.md#0x1_object_ObjectGroup">0x1::object::ObjectGroup</a>])]
<b>struct</b> <a href="cpmm.md#0x1_cpmm_Pool">Pool</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_metadata: <a href="object.md#0x1_object_Object">object::Object</a>&lt;<a href="fungible_asset.md#0x1_fungible_asset_Metadata">fungible_asset::Metadata</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>base_reserve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>quote_metadata: <a href="object.md#0x1_object_Object">object::Object</a>&lt;<a href="fungible_asset.md#0x1_fungible_asset_Metadata">fungible_asset::Metadata</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>quote_reserve: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>constant_product: u128</code>
</dt>
<dd>

</dd>
<dt>
<code>fee_in_basis_points: u16</code>
</dt>
<dd>

</dd>
<dt>
<code>mint_ref: <a href="fungible_asset.md#0x1_fungible_asset_MintRef">fungible_asset::MintRef</a></code>
</dt>
<dd>

</dd>
<dt>
<code>burn_ref: <a href="fungible_asset.md#0x1_fungible_asset_BurnRef">fungible_asset::BurnRef</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_cpmm_E_ADD_BASE_OVERFLOW"></a>

Unable to add liquidity due to base overflow.


<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_E_ADD_BASE_OVERFLOW">E_ADD_BASE_OVERFLOW</a>: u64 = 3;
</code></pre>



<a id="0x1_cpmm_E_ADD_QUOTE_OVERFLOW"></a>

Unable to add liquidity due to quote overflow.


<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_E_ADD_QUOTE_OVERFLOW">E_ADD_QUOTE_OVERFLOW</a>: u64 = 2;
</code></pre>



<a id="0x1_cpmm_E_DEAD_POOL"></a>

All liquidity has been removed from the pool. It is dead.


<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_E_DEAD_POOL">E_DEAD_POOL</a>: u64 = 1;
</code></pre>



<a id="0x1_cpmm_E_INVALID_QUOTE"></a>

Quote metadata does not match that of pool.


<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_E_INVALID_QUOTE">E_INVALID_QUOTE</a>: u64 = 0;
</code></pre>



<a id="0x1_cpmm_E_MINT_AMOUNT_OVERFLOW"></a>

May not mint more than (2^64 - 1) liquidity provider tokens.


<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_E_MINT_AMOUNT_OVERFLOW">E_MINT_AMOUNT_OVERFLOW</a>: u64 = 4;
</code></pre>



<a id="0x1_cpmm_U64_MAX"></a>



<pre><code><b>const</b> <a href="cpmm.md#0x1_cpmm_U64_MAX">U64_MAX</a>: u128 = 18446744073709551615;
</code></pre>



<a id="0x1_cpmm_create_pool"></a>

## Function `create_pool`



<pre><code><b>public</b> entry <b>fun</b> <a href="cpmm.md#0x1_cpmm_create_pool">create_pool</a>(creator: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>, base_reserve: u64, quote_reserve: u64, base_metadata: <a href="object.md#0x1_object_Object">object::Object</a>&lt;<a href="fungible_asset.md#0x1_fungible_asset_Metadata">fungible_asset::Metadata</a>&gt;, quote_metadata: <a href="object.md#0x1_object_Object">object::Object</a>&lt;<a href="fungible_asset.md#0x1_fungible_asset_Metadata">fungible_asset::Metadata</a>&gt;, fee_in_basis_points: u16, lp_token_name: <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string_String">string::String</a>, lp_token_symbol: <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string_String">string::String</a>, lp_token_decimals: u8, lp_token_icon_uri: <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string_String">string::String</a>, lp_token_project_uri: <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string_String">string::String</a>, lp_token_initial_supply: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="cpmm.md#0x1_cpmm_create_pool">create_pool</a>(
    creator: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>,
    base_reserve: u64,
    quote_reserve: u64,
    base_metadata: Object&lt;Metadata&gt;,
    quote_metadata: Object&lt;Metadata&gt;,
    fee_in_basis_points: u16,
    lp_token_name: String,
    lp_token_symbol: String,
    lp_token_decimals: u8,
    lp_token_icon_uri: String,
    lp_token_project_uri: String,
    lp_token_initial_supply: u64,
) {
    <b>let</b> creator_address = <a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(creator);
    <b>let</b> constructor_ref = <a href="object.md#0x1_object_create_object">object::create_object</a>(creator_address);
    <b>let</b> pool_address =
        <a href="object.md#0x1_object_address_from_constructor_ref">object::address_from_constructor_ref</a>(&constructor_ref);
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_create_primary_store_enabled_fungible_asset">primary_fungible_store::create_primary_store_enabled_fungible_asset</a>(
       &constructor_ref,
       <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>(),
       lp_token_name,
       lp_token_symbol,
       lp_token_decimals,
       lp_token_icon_uri,
       lp_token_project_uri,
    );
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_transfer">primary_fungible_store::transfer</a>(
        creator,
        base_metadata,
        pool_address,
        base_reserve,
    );
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_transfer">primary_fungible_store::transfer</a>(
        creator,
        quote_metadata,
        pool_address,
        quote_reserve,
    );
    <b>let</b> pool_signer = <a href="object.md#0x1_object_generate_signer">object::generate_signer</a>(&constructor_ref);
    <b>let</b> mint_ref = <a href="fungible_asset.md#0x1_fungible_asset_generate_mint_ref">fungible_asset::generate_mint_ref</a>(&constructor_ref);
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_mint">primary_fungible_store::mint</a>(
        &mint_ref,
        creator_address,
        lp_token_initial_supply,
    );
    <b>move_to</b>(
        &pool_signer,
        <a href="cpmm.md#0x1_cpmm_Pool">Pool</a>{
            base_metadata,
            base_reserve,
            quote_metadata,
            quote_reserve,
            constant_product:
                (base_reserve <b>as</b> u128) * (quote_reserve <b>as</b> u128),
            fee_in_basis_points,
            mint_ref,
            burn_ref: <a href="fungible_asset.md#0x1_fungible_asset_generate_burn_ref">fungible_asset::generate_burn_ref</a>(&constructor_ref),
        },
    );
}
</code></pre>



</details>

<a id="0x1_cpmm_add_liquidity"></a>

## Function `add_liquidity`



<pre><code><b>public</b> entry <b>fun</b> <a href="cpmm.md#0x1_cpmm_add_liquidity">add_liquidity</a>(provider: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>, pool_address: <b>address</b>, quote_metadata: <a href="object.md#0x1_object_Object">object::Object</a>&lt;<a href="fungible_asset.md#0x1_fungible_asset_Metadata">fungible_asset::Metadata</a>&gt;, quote_amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="cpmm.md#0x1_cpmm_add_liquidity">add_liquidity</a>(
    provider: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>,
    pool_address: <b>address</b>,
    quote_metadata: Object&lt;Metadata&gt;,
    quote_amount: u64,
) <b>acquires</b> <a href="cpmm.md#0x1_cpmm_Pool">Pool</a> {
    <b>let</b> pool_ref_mut = <b>borrow_global_mut</b>&lt;<a href="cpmm.md#0x1_cpmm_Pool">Pool</a>&gt;(pool_address);
    <b>assert</b>!(
        quote_metadata == pool_ref_mut.quote_metadata,
        <a href="cpmm.md#0x1_cpmm_E_INVALID_QUOTE">E_INVALID_QUOTE</a>,
    );
    <b>assert</b>!(
        pool_ref_mut.base_reserve != 0 || pool_ref_mut.quote_reserve != 0,
        <a href="cpmm.md#0x1_cpmm_E_DEAD_POOL">E_DEAD_POOL</a>
    );
    <b>let</b> quote_reserve_new =
        (pool_ref_mut.quote_reserve <b>as</b> u128) + (quote_amount <b>as</b> u128);
    <b>assert</b>!(quote_reserve_new &lt;= <a href="cpmm.md#0x1_cpmm_U64_MAX">U64_MAX</a>, <a href="cpmm.md#0x1_cpmm_E_ADD_QUOTE_OVERFLOW">E_ADD_QUOTE_OVERFLOW</a>);
    <b>let</b> base_reserve_new =
        pool_ref_mut.constant_product / quote_reserve_new;
    <b>assert</b>!(base_reserve_new &lt;= <a href="cpmm.md#0x1_cpmm_U64_MAX">U64_MAX</a>, <a href="cpmm.md#0x1_cpmm_E_ADD_BASE_OVERFLOW">E_ADD_BASE_OVERFLOW</a>);
    <b>let</b> base_amount =
        (base_reserve_new <b>as</b> u64) - pool_ref_mut.base_reserve;
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_transfer">primary_fungible_store::transfer</a>(
        provider,
        quote_metadata,
        pool_address,
        quote_amount
    );
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_transfer">primary_fungible_store::transfer</a>(
        provider,
        pool_ref_mut.base_metadata,
        pool_address,
        base_amount
    );
    <b>let</b> lp_token_supply = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_destroy_some">option::destroy_some</a>(
        <a href="fungible_asset.md#0x1_fungible_asset_supply">fungible_asset::supply</a>&lt;<a href="cpmm.md#0x1_cpmm_Pool">Pool</a>&gt;(
            <a href="object.md#0x1_object_address_to_object">object::address_to_object</a>(pool_address)
        )
    );
    <b>let</b> mint_amount = <a href="../../aptos-stdlib/doc/math128.md#0x1_math128_mul_div">math128::mul_div</a>(
        lp_token_supply,
        (quote_amount <b>as</b> u128),
        quote_reserve_new
    );
    <b>assert</b>!(mint_amount &lt; <a href="cpmm.md#0x1_cpmm_U64_MAX">U64_MAX</a>, <a href="cpmm.md#0x1_cpmm_E_MINT_AMOUNT_OVERFLOW">E_MINT_AMOUNT_OVERFLOW</a>);
    <a href="primary_fungible_store.md#0x1_primary_fungible_store_mint">primary_fungible_store::mint</a>(
        &pool_ref_mut.mint_ref,
        <a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer_address_of">signer::address_of</a>(provider),
        (mint_amount <b>as</b> u64),
    );
    pool_ref_mut.quote_reserve = (quote_reserve_new <b>as</b> u64);
    pool_ref_mut.base_reserve = (base_reserve_new <b>as</b> u64)
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
