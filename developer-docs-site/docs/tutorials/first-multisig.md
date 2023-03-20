---
title: "Your First Multisig"
slug: "your-first-multisig"
---

# Your First Multisig

This tutorial introduces assorted [K-of-N multi-signer authentication](../concepts/accounts.md#multi-signer-authentication) operations and supplements content from the following tutorials:

* [Your First Transaction](./first-transaction.md)
* [Your First Coin](./first-coin.md)
* [Your First Move Module](./first-move-module.md)

:::tip
Try out the above tutorials (which include dependency installations) before moving on to multisig operations.
:::

## Step 1: Pick an SDK

This tutorial, a community contribution, was created for the [Python SDK](../sdks/python-sdk.md).

Other developers are invited to add support for the [TypeScript SDK](../sdks/ts-sdk/index.md), [Rust SDK](../sdks/rust-sdk.md), and [Unity SDK](../sdks/unity-sdk.md)!

## Step 2: Start the example

Navigate to the Python SDK directory:

```zsh
cd <aptos-core-parent-directory>/aptos-core/ecosystem/python/sdk/
```

Run the `multisig.py` example:

```zsh
poetry run python -m examples.multisig
```

:::tip
This example uses the Aptos devnet, which has historically been reset each Thursday.
Make sure devnet is live when you try running the example!
:::

## Step 3: Generate single signer accounts

First, we will generate single signer accounts for Alice, Bob, and Chad:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_1
```

Fresh accounts are generated for each example run, but the output should resemble:

```zsh title=Output
=== Account addresses ===
Alice: 0x93c1b7298d53dd0d517f503f2d3188fc62f6812ab94a412a955720c976fecf96
Bob:   0x85eb913e58d0885f6a966d98c76e4d00714cf6627f8db5903e1cd38cc86d1ce0
Chad:  0x14cf8dc376878ac268f2efc7ba65a2ee0ac13ceb43338b6106dd88d8d23e087a

=== Authentication keys ===
Alice: 0x93c1b7298d53dd0d517f503f2d3188fc62f6812ab94a412a955720c976fecf96
Bob:   0x85eb913e58d0885f6a966d98c76e4d00714cf6627f8db5903e1cd38cc86d1ce0
Chad:  0x14cf8dc376878ac268f2efc7ba65a2ee0ac13ceb43338b6106dd88d8d23e087a

=== Public keys ===
Alice: 0x3f23f869632aaa4378f3d68560e08d18b1fc2e80f91d6f9d1b39d720b0ef7a3f
Bob:   0xcf21e85337a313bdac33d068960a3e52d22ce0e6190e9acc03a1c9930e1eaf3e
Chad:  0xa1a2aef8525eb20655387d3ed50b9a3ea1531ef6117f579d0da4bcf5a2e1f76d
```

For each user, note the [account address](../concepts/accounts.md#account-address) and [authentication key](../concepts/accounts.md#single-signer-authentication) are identical, but the [public key](../concepts/accounts.md#creating-an-account) is different.

## Step 4: Generate a multisig account

Next generate a [K-of-N multi-signer](../concepts/accounts.md#multi-signer-authentication) public key and account address for a multisig account requiring two of the three signatures:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_2
```

The multisig account address depends on the public keys of the single signers. (Hence, it will be different for each example.) But the output should resemble:

```zsh title=Output
=== 2-of-3 Multisig account ===
Account public key: 2-of-3 Multi-Ed25519 public key
Account address:    0x08cac3b7b7ce4fbc5b18bc039279d7854e4c898cbf82518ac2650b565ad4d364
```

## Step 5: Fund all accounts

Next fund all accounts:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_3
```

```zsh title=Output
=== Funding accounts ===
Alice's balance:  10000000
Bob's balance:    20000000
Chad's balance:   30000000
Multisig balance: 40000000
```

## Step 6: Send coins from the multisig

This transaction will send 100 octas from the multisig account to Chad's account.
Since it is a two-of-three multisig account, signatures are required from only two individual signers.

### Step 6.1: Gather individual signatures

First generate a raw transaction, signed by Alice and Bob, but not by Chad.

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_4
```

Again, signatures vary for each example run:

```zsh title=Output
=== Individual signatures ===
Alice: 0x41b9dd65857df2d8d8fba251336357456cc9f17974de93292c13226f560102eac1e70ddc7809a98cd54ddee9b79853e8bf7d18cfef23458f23e3a335c3189e0d
Bob:   0x6305101f8f3ad5a75254a8fa74b0d9866756abbf359f9e4f2b54247917caf8c52798a36c5a81c77505ebc1dc9b80f2643e8fcc056bcc4f795e80b229fa41e509
```

### Step 6.2: Submit the multisig transaction

Next generate a [multisig authenticator](../guides/sign-a-transaction.md#multisignature-transactions) and submit the transaction:


```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_5
```

```zsh title=Output
=== Submitting transfer transaction ===
Transaction hash: 0x3ff2a848bf6145e6df3abb3ccb8b94fefd07ac16b4acb0c694fa7fa30b771f8c
```

### Step 6.3: Check balances

Check the new account balances:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_6
```

```zsh title=Output
=== New account balances===
Alice's balance:  10000000
Bob's balance:    20000000
Chad's balance:   30000100
Multisig balance: 39999300
```

Note that even though Alice and Bob signed the transaction, their account balances have not changed.
Chad, however, has received 100 octas from the multisig account, which assumed the gas costs of the transaction and thus has had more than 100 octas deducted.

## Step 7: Create a vanity address multisig

In this section, a fourth user named Deedee will generate a vanity address, then rotate her account to the two-of-three multisig.

### Step 7.1 Generate a vanity address

A fourth user, Deedee, wants her account address to start with `0xdd..`, so she generates random accounts until she finds one with a matching account address:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_7
```

```zsh title=Output
=== Funding vanity address ===
Deedee's address:    0xdd86860ae7f77f58d08188e1c39fbc6a2f7cec782f09f6767f8367d84357ed57
Deedee's public key: 0xdbf02311c45903f0217e9ab76ca64007c2876363118bb422922410d4cfe9964c
Deedee's balance:    50000000
```

### Step 7.2 Sign a rotation proof challenge

Deedee and the two-of-three multisig must both sign a `RotationProofChallenge`, yielding two signatures.
Deedee's signature, `cap_rotate_key`, verifies that she approves of the authentication key rotation.
The multisig signature, `cap_update_table`, verifies that the multisig approves of the authentication key rotation.
Here, Bob and Chad provide individual signatures for the multisig:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_8
```

```zsh title=Output
=== Signing rotation proof challenge ===
cap_rotate_key:   0x3b2906df78bb79f210051e910985c358572c2ec7cdd03f688480fb6adf8d538df48a52787d5651d85f2959dcca88d58da49709c9c0dc9c3c58b67169ec1e1c01
cap_update_table: 0x965fd11d7afe14396e5af40b8ffb78e6eb6f7caa1f1b1d8c7b819fdd6045864e70258788ec1670a3989c85f8cc604f4b54e43e1ce173a59aa0a6f7cf124fd902dcbb2ad53467d05c144260b2be1814777c082d8db437698b00e6a2109a015a565ff5783e827a21a4c07ae332b56398b69dfdbcc08b8ad5585dc1ac649b74730760000000
```

### Step 7.3 Rotate the authentication key

Now that the relevant signatures have been gathered, the authentication key rotation transaction can be submitted.
After it executes, the rotated authentication key matches the address of the first multisig account (the one that sent octas to Chad):

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_9
```

```zsh title=Output
=== Submitting authentication key rotation transaction ===
Auth key pre-rotation: 0xdd86860ae7f77f58d08188e1c39fbc6a2f7cec782f09f6767f8367d84357ed57
Transaction hash:      0x57c66089a1b81e2895a2d6919ab19eb90c4d3c3cbe9fecab8169eaeedff2c6e6
New auth key:          0x08cac3b7b7ce4fbc5b18bc039279d7854e4c898cbf82518ac2650b565ad4d364
1st multisig address:  0x08cac3b7b7ce4fbc5b18bc039279d7854e4c898cbf82518ac2650b565ad4d364
```

In other words, Deedee generated an account with a vanity address so that Alice, Bob, and Chad could use it as a multisig account.
Then Deedee and the Alice/Bob/Chad group (under the authority of Bob and Chad) approved to rotate the vanity account's authentication key to the authentication key of the first multisig account.

## Step 8: Perform Move package governance

In this section, the multisig vanity account will publish a simple package, upgrade it, then invoke a Move script.

Move source code for this section is found in the [`upgrade_and_govern`](https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples/upgrade_and_govern) directory.

### Step 8.1: Review genesis package

The `UpgradeAndGovern` genesis package (version `1.0.0`) contains a simple `.toml` manifest and a single Move source file:

```toml title="Move.toml"
:!: static/move-examples/upgrade_and_govern/genesis/Move.toml manifest
```

```rust title="parameters.move"
:!: static/move-examples/upgrade_and_govern/genesis/sources/parameters.move module
```

As soon as the package is published, a `GovernanceParameters` resource is moved to the `upgrade_and_govern` package account with the values specified by `GENESIS_PARAMETER_1` and `GENESIS_PARAMETER_2`.
Then, the `get_parameters()` function can be used to look up the governance parameters, but note that in this version there is no setter function.
The setter function will be added later.

### Step 8.2: Publish genesis package

Here, Alice and Chad will sign off on the publication transaction.

All compilation and publication operations are handled via the ongoing Python script:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_10
```

```zsh title=Output
=== Genesis publication ===
Running aptos CLI command: aptos move compile --save-metadata --package-dir ../../../../aptos-move/move-examples/upgrade_and_govern/genesis --named-addresses upgrade_and_govern=0xdd86860ae7f77f58d08188e1c39fbc6a2f7cec782f09f6767f8367d84357ed57

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern

Transaction hash: 0x3c65c681194d6c64d73dc5d0cbcbad62e99a997b8600b8edad6847285e580c13
Package name from on-chain registry: UpgradeAndGovern
On-chain upgrade number: 0
```

### Step 8.3: Review package upgrades

The `UpgradeAndGovern` upgrade package adds the following parameter setter functionality at the end of `parameters.move`:

```rust title=parameters.move
:!: static/move-examples/upgrade_and_govern/upgrade/sources/parameters.move appended
```

Here, the account that the package is published under, `upgrade_and_govern`, has the authority to change the `GovernanceParameter` values from the genesis values to the new `parameter_1` and `parameter_2` values.

There is also a new module, `transfer.move`:

```rust title=transfer.move
:!: static/move-examples/upgrade_and_govern/upgrade/sources/transfer.move module
```

This module simply looks up the `GovernanceParameter` values, and treats them as the amount of octas to send to two recipients.

Lastly, the manifest has been updated with the new version number `1.1.0`:

```toml title=Move.toml
:!: static/move-examples/upgrade_and_govern/upgrade/Move.toml manifest
```

### Step 8.4: Upgrade the package

Alice, Bob, and Chad will all sign off on this publication transaction, which results in an upgrade.
This process is almost identical to that of the genesis publication, with the new `transfer` module listed after the `parameters` module:

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_11
```

:::tip
Modules that `use` other modules must be listed *after* the modules they use.
:::

```zsh title=Output
=== Upgrade publication ===
Running aptos CLI command: aptos move compile --save-metadata --package-dir ../../../../aptos-move/move-examples/upgrade_and_govern/upgrade --named-addresses upgrade_and_govern=0xdd86860ae7f77f58d08188e1c39fbc6a2f7cec782f09f6767f8367d84357ed57

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern

Transaction hash: 0x0f0ea3bb7271ddeaceac5b49ff5503d6c652d4746c1510e47665ceee5a89aaf0
On-chain upgrade number: 1
```

Note that the on-chain upgrade number has been incremented by 1.

### Step 8.6: Review the governance script

The `UpgradeAndGovern` upgrade package also includes a Move script at `set_and_transfer.move`:

```rust title=set_and_transfer.move
:!: static/move-examples/upgrade_and_govern/upgrade/scripts/set_and_transfer.move script
```

This script calls the governance parameter setter using hard-coded values defined at the top of the script, then calls the octa transfer function.
The script accepts as arguments the signature of the account hosting the package, as well as two target addresses for the transfer operation.

Note that both functions in the script are `public entry fun` functions, which means that everything achieved in the script could be performed without a script.
However, a non-script approach would require two transactions instead of just one, and would complicate the signature aggregation process:
in practical terms, Alice, Bob, and/or Chad would likely have to send single-signer transaction signatures around through off-chain communication channels, and a *scribe* for the group would then have to submit a multisig `Authenticator` (for *each* `public entry fun` call).
Hence in a non-script approach, extra operational complexity can quickly introduce opportunities for consensus failure.

A Move script, by contrast, collapses multiple governance function calls into a single transaction; and moreover, Move scripts can be published in a public forum like GitHub so that all signatories can review the actual function calls before they sign the script.

### Step 8.5: Execute the governance script

Alice and Bob sign off on the Move script, which sends coins from the vanity multisig account to their personal accounts.
Here, the amounts sent to each account are specified in the hard-coded values from the script.

```python title="multisig.py snippet"
:!: static/sdks/python/examples/multisig.py section_12
```

```zsh title=Output
=== Invoking Move script ===
Transaction hash: 0xd06de4bd9fb12a9f3cbd8ce1b9a9fd47ea2b923a8cfac21f9788869430e4149b
Alice's balance:  10000300
Bob's balance:    20000200
Chad's balance:   30000100
```

## Step 9: Expedite execution with AMEE

The above code snippets demonstrate concepts relevant to multisig operations, but are impractical for realistic workflows:
all of the private keys are stored in memory on the same machine, the function calls do not generalize to other multisig operations, etc.
As a result, there is a significant amount of overhead required to implement a bespoke solution that ports the above concepts to one's particular use case, which almost necessarily involves signers coordinating across space and time through an off-chain social consensus strategy (e.g. Have enough signatories signed yet? How do we compile their signatures?)

To expedite this process, the Python SDK thus provides the Aptos Multisig Execution Expeditor (AMEE), a command-line tool that facilitates general multisig workflows through straightforward data structures and function calls.

To use AMEE, navigate to the Python SDK package directory:

```zsh
cd <aptos-core-parent-directory>/aptos-core/ecosystem/python/sdk/aptos_sdk
```

Then call up the help menu from the command line:

```python title=Command
:!: static/sdks/python/examples/multisig.sh help
```

```zsh title=Output
usage: amee.py [-h] {keyfile,k,metafile,m,publish,p,rotate,r,script,s} ...

Aptos Multisig Execution Expeditor (AMEE): A collection of tools designed to expedite multisig account execution.

positional arguments:
  {keyfile,k,metafile,m,publish,p,rotate,r,script,s}
    keyfile (k)         Single-signer keyfile operations.
    metafile (m)        Multisig metafile operations.
    publish (p)         Move package publication.
    rotate (r)          Authentication key rotation operations.
    script (s)          Move script invocation.

optional arguments:
  -h, --help            show this help message and exit
```

AMEE offers a rich collection of useful subcommands, and to access their all of their help menus recursively simply call the `multisig.sh` shell script file with the `menus` argument (still from inside the `aptos_sdk` directory):

```zsh title=Command
sh ../examples/multisig.sh menus
```

:::tip
This shell script file will be used for several other examples throughout the remainder of this tutorial, so try running it now!
:::

```zsh title=Output

<Top-level help menu>

...

usage: amee.py keyfile [-h] {change-password,c,extract,e,fund,f,generate,g,verify,v} ...

Assorted single-signer keyfile operations.

positional arguments:
  {change-password,c,extract,e,fund,f,generate,g,verify,v}
    change-password (c)
                        Change keyfile password.
    extract (e)         Extract Aptos account store from keyfile.
    fund (f)            Fund on devnet faucet.
    generate (g)        Generate new keyfile.
    verify (v)          Verify keyfile password.

options:
  -h, --help            show this help message and exit





usage: amee.py keyfile change-password [-h] [-u] keyfile

Change password for a single-singer keyfile.

positional arguments:
  keyfile               Relative path to keyfile.

options:
  -h, --help            show this help message and exit
  -u, --use-test-password
                        Flag to use test password.

...

<More menus>

```

### Step 9.1 Keyfiles

Unlike the `aptos` CLI which stores private keys in plain text on disk, AMEE encrypts single-signer private keys in a [JSON](https://docs.python.org/3/library/json.html) keyfile format with password protection:

```zsh title=Command
:!: static/sdks/python/examples/multisig.sh generate_keyfile
```

This initiates a hidden password prompt and creates a new file on disk:

```zsh title=Output
Enter new password for encrypting private key:
Re-enter password:
Keyfile now at the_aptos_foundation.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "The Aptos Foundation",
    "public_key": "0x7d1bed984fd185595059f94cbe95ed3e4ce9b49bd3c53bace8102813cfdc4adc",
    "authentication_key": "0x682b1a757af92532d184aab6d6ca7fa92b8229c38118c1729187ed1fb2106b15",
    "encrypted_private_key": "0x674141414141426a377157643961486e544875424b4e43546831586454654855376956734656465039335a336266544f4f4d7157785354544a5671387932364d69494c364f724e44447143766871626b35564b36306e4362726a33566356536330636965524d5f777656466c5a394273314f78714151384c6d352d764b6666344443716978365a35397a4a65",
    "salt": "0x5e323ba1f941152c38be4b05a04e24dd"
}
```

This keyfile can be decrypted using the password to produce an unprotected account store (via `aptos_sdk.account.Account.store()`), which may be useful when trying to fund via the testnet faucet. Note here the abbreviation of `keyfile` to `k`:

```zsh title=Command
:!: static/sdks/python/examples/multisig.sh extract_keyfile
```

```zsh title=Output
Enter password for encrypted private key:
New account store at the_aptos_foundation.account_store:
{"account_address": "0x682b1a757af92532d184aab6d6ca7fa92b8229c38118c1729187ed1fb2106b15", "private_key": "0x4ae3985bd49571cf67b42a391d72956a95cfb9aa634fd05c019a96a6eccd399d"}
```

Similarly, AMEE can generate keyfiles from an unprotected account store format. Note here the abbreviation of `generate` to `g` and the optional `outfile` positional argument:

:::tip
AMEE supports abbreviations for all commands and subcommands!
:::

```zsh title=Command
:!: static/sdks/python/examples/multisig.sh generate_from_store
```

```zsh title=Output
Enter new password for encrypting private key:
Re-enter password:
Keyfile now at from_store.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "The Aptos Foundation",
    "public_key": "0x7d1bed984fd185595059f94cbe95ed3e4ce9b49bd3c53bace8102813cfdc4adc",
    "authentication_key": "0x682b1a757af92532d184aab6d6ca7fa92b8229c38118c1729187ed1fb2106b15",
    "encrypted_private_key": "0x674141414141426a3771576861794330645a4949575051494f4f5a45647847426b5659723638506a464d666a5768486549357375437834696747514b6373466a683741732d78616e4958426e326a717066683071376c486c76364159646761765a514e2d715669664a50776e7a6c655f4436546d57762d426e3471765f5f6e45664e737530336f7a7a75702d",
    "salt": "0x0656247cc0c7d571058a9b9ad7d6858b"
}
```

To change the password on a keyfile:


```zsh title=Command
:!: static/sdks/python/examples/multisig.sh change_password
```

```zsh title=Output
Enter password for encrypted private key:
Enter new password for encrypting private key:
Re-enter password:
Keyfile now at from_store.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "The Aptos Foundation",
    "public_key": "0x7d1bed984fd185595059f94cbe95ed3e4ce9b49bd3c53bace8102813cfdc4adc",
    "authentication_key": "0x682b1a757af92532d184aab6d6ca7fa92b8229c38118c1729187ed1fb2106b15",
    "encrypted_private_key": "0x674141414141426a3771576c48575570445a56707149732d6153785773753630696a656565315a5f684f365469696f523276705946565f2d7077556c49466c3656625468303731486c3654744a456e6575693443596d417065454f4f687435435a316f4b55444762536c43584b5067534e466664455135615f414a614270757a4637445a5554555870533149",
    "salt": "0xd831bcda8cfac7b94a2065c7c829eac3"
}
```

Now verify the new password:

```zsh title=Command
:!: static/sdks/python/examples/multisig.sh verify_password
```

```zsh title=Output
Enter password for encrypted private key:
Keyfile password verified for The Aptos Foundation
Public key:         0x7d1bed984fd185595059f94cbe95ed3e4ce9b49bd3c53bace8102813cfdc4adc
Authentication key: 0x682b1a757af92532d184aab6d6ca7fa92b8229c38118c1729187ed1fb2106b15
```

Note that all of these commands can be run in a scripted fashion simply by calling the `multisig.sh` shell script with the `keyfiles` argument.

```zsh title=Command
sh ../examples/multisig.sh keyfiles
```

:::tip
Try running the shell script yourself, then experiment with variations on the commands!
:::

### Step 9.2 Metafiles

AMEE manages multisig account metadata through metafiles, which assimilate information from multiple single-signer keyfiles.

The below demo script, also in `multisig.sh`, demonstrates assorted metafile operations:

| Command                | Use                                                              |
|------------------------|------------------------------------------------------------------|
| `metafile incorporate` | Incorporate multiple signers into a multisig metafile            |
| `metafile threshold`   | Modify the threshold, outputting a new metafile                  |
| `metafile append`      | Append a new signatory or signatories, outputting a new metafile |
| `metafile remove`      | Remove a signatory or signatories, outputting a new metafile     |

```zsh title=Command
sh ../examples/multisig.sh keyfiles
```

The first part of the demo generates a vanity account for both Ace and Bee, via the `--vanity-prefix` argument, which mines an account having a matching authentication key prefix. Note also the use of the `--use-test-password` command to reduce password inputs for the demo process:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_ace_bee
```

Here, each keyfile's authentication key begins with the specified vanity prefix:

```zsh title=Output
=== Generate vanity account for Ace ===


Mining vanity address...
Using test password.
Keyfile now at ace.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Ace",
    "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a",
    "authentication_key": "0xace34c150c214397f17f3374bb9bca9d56ae9ad80c5cc26e5e3104ba2e72132a",
    "encrypted_private_key": "0x674141414141426a37753267476d4e49386b636d6577514b3172355f356c6c49426b545861715859667268646e343137337a4d524d52454f487a4766725078686d576834346b6344754231455338525a6d344b36692d684941376c7346326c7a33364a6f4a6b3472315f62564d424e54483062354737675275476d5a41315a6d33773044376863536a4c424b",
    "salt": "0x0248e25cfe88b9f00bfb1948df6791f9"
}


=== Generate vanity account for Bee ===


Mining vanity address...
Using test password.
Keyfile now at bee.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Bee",
    "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6",
    "authentication_key": "0xbeea9f7d3365f1c95348b803297081458eb77babc4c059518e3453b398653349",
    "encrypted_private_key": "0x674141414141426a377532674659654e366c34566e77457077705065626566583167697a66434c635138496e594875334b70586c37437034566f4d6d686943376937483255366c314f5a46674d4e5a6c3852442d7267796d4c345376443444645249572d4a497353796d2d78743451355a5f6a376e4a546e554e4277483978626a6f59515346755f73373750",
    "salt": "0x16312e818976ccf60dae4006f0161c12"
}

```

Next, Ace and Bee are incorporated into a 1-of-2 multisig via `metafile incorporate`:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_incorporate
```

```zsh title=Output
=== Incorporate Ace and Bee into 1-of-2 multisig ===


Multisig metafile now at ace_and_bee.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Ace and Bee",
    "address": null,
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e601",
    "authentication_key": "0x9e6413fac20e0d493c78b6a7744d71c8ad772796e7dcd3f78bf5d647d6a31afe",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a",
            "authentication_key": "0xace34c150c214397f17f3374bb9bca9d56ae9ad80c5cc26e5e3104ba2e72132a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6",
            "authentication_key": "0xbeea9f7d3365f1c95348b803297081458eb77babc4c059518e3453b398653349"
        }
    ]
}
```

The `metafile threshold` command is used to increase the threshold to two signatures:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_threshold
```

```zsh title=Output
=== Increase threshold to two signatures ===


Multisig metafile now at ace_and_bee_increased.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Ace and Bee increased",
    "address": null,
    "threshold": 2,
    "n_signatories": 2,
    "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e602",
    "authentication_key": "0x7a66bb589973c243e91251bdf26e43b47b7e0297e713ab48428d0b489b9618f8",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a",
            "authentication_key": "0xace34c150c214397f17f3374bb9bca9d56ae9ad80c5cc26e5e3104ba2e72132a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6",
            "authentication_key": "0xbeea9f7d3365f1c95348b803297081458eb77babc4c059518e3453b398653349"
        }
    ]
}
```

Now Cad and Dee have vanity accounts generated as well:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_cad_dee
```

```zsh title=Output
=== Generate vanity account for Cad ===


Mining vanity address...
Using test password.
Keyfile now at cad.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Cad",
    "public_key": "0x774ffbf31e70681a795a61d5c8e47fa05e5088925ffa27d7eeb8e16d8bd1d5bb",
    "authentication_key": "0xcad97c90570bdecf8737d3317604291f6c4cdd6f4651924c79eded5c9c4d0da7",
    "encrypted_private_key": "0x674141414141426a37753269346d665469474f3873507459687531424470516831675a6b4c4541595936444f4b42694e567a444f346a38457764536955745144424a7a7454535f594777425764373238414d527a43455f39444270727a767a4d70676c544236665141574141674a4d777a4c32543056357453474b34724765395254536a7a33456774656434",
    "salt": "0xdef251c71a113c7ddbbafc2881f297ed"
}


=== Generate vanity account for Dee ===


Mining vanity address...
Using test password.
Keyfile now at dee.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Dee",
    "public_key": "0x159481f2929ba902f4640815ca27662843e2090438ea0db630e4addb150741a7",
    "authentication_key": "0xdeee312ec51d2f30f4291fa3105d907237b2550afcb9e608192f1b44af5cd747",
    "encrypted_private_key": "0x674141414141426a377532695a416d6335623373304a4c456165784a44655955414830456f5a78737a6e704165677072356d474332435467756c675a70343566372d32704b716e314d3744737456326375716133502d4a7647363758773152686270656a583033746775515758564f4e326c744361486c56345a4c4f466b7878556b55356b4b536e47636764",
    "salt": "0x027b97dac9ab2f60f847e51dd71ddf35"
}

```

Now Cad and Dee are appended to the first multisig metafile via `metafile append`:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_append
```

```zsh title=Output

=== Append Cad and Dee to 3-of-4 multisig ===


Multisig metafile now at cad_and_dee_added.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Cad and Dee added",
    "address": null,
    "threshold": 3,
    "n_signatories": 4,
    "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6774ffbf31e70681a795a61d5c8e47fa05e5088925ffa27d7eeb8e16d8bd1d5bb159481f2929ba902f4640815ca27662843e2090438ea0db630e4addb150741a703",
    "authentication_key": "0x2fc0693aed20883859cb9a03e25c31943267d91d6062992e56c251496d793ec9",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x198fed1db594fc9df0b926cef3a17471e394b627506a2bba37e71c7b7186898a",
            "authentication_key": "0xace34c150c214397f17f3374bb9bca9d56ae9ad80c5cc26e5e3104ba2e72132a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6",
            "authentication_key": "0xbeea9f7d3365f1c95348b803297081458eb77babc4c059518e3453b398653349"
        },
        {
            "signatory": "Cad",
            "public_key": "0x774ffbf31e70681a795a61d5c8e47fa05e5088925ffa27d7eeb8e16d8bd1d5bb",
            "authentication_key": "0xcad97c90570bdecf8737d3317604291f6c4cdd6f4651924c79eded5c9c4d0da7"
        },
        {
            "signatory": "Dee",
            "public_key": "0x159481f2929ba902f4640815ca27662843e2090438ea0db630e4addb150741a7",
            "authentication_key": "0xdeee312ec51d2f30f4291fa3105d907237b2550afcb9e608192f1b44af5cd747"
        }
    ]
}

```

Finally, Ace and Dee are removed from the resultant multisig via `metafile remove` to produce another 1-of-2 multisig:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh metafiles_remove
```

```zsh title=Output

=== Remove Ace and Dee for 1-of-2 multisig ===


Multisig metafile now at ace_and_dee_removed.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Ace and Dee removed",
    "address": null,
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6774ffbf31e70681a795a61d5c8e47fa05e5088925ffa27d7eeb8e16d8bd1d5bb01",
    "authentication_key": "0xeef31014c0e711722bf1b652188d0829d71d27aa05cfe25e31bdc38a0ebc5ffd",
    "signatories": [
        {
            "signatory": "Bee",
            "public_key": "0x7bf9cbad4386d95c239f0b2b186a3b970e0c9bd0914eaaec00756abf5ea675e6",
            "authentication_key": "0xbeea9f7d3365f1c95348b803297081458eb77babc4c059518e3453b398653349"
        },
        {
            "signatory": "Cad",
            "public_key": "0x774ffbf31e70681a795a61d5c8e47fa05e5088925ffa27d7eeb8e16d8bd1d5bb",
            "authentication_key": "0xcad97c90570bdecf8737d3317604291f6c4cdd6f4651924c79eded5c9c4d0da7"
        }
    ]
}
```

Thus far all AMEE operations have been conducted off-chain, because the relevant keyfile and metafile operations have simply involved public keys, private keys, and authentication keys.

As such, all multisig metafiles have `"address": null`, since an on-chain account address has not yet been linked with any of the multisig accounts.

### Step 9.3 Authentication key rotation

In this section, the authentication key for Ace's vanity account will be rotated to a 1-of-2 multisig including Ace and Bee, then to a 2-of-2 multisig, and finally back to Ace as a single signer.
Here the demo script uses devnet to automatically fund Ace's account from the faucet, but note that Bee's account does not need to be funded, because only her *signature* is required throughout operations.

In general, authentication key rotation can be used to "convert" a single-signer account to a multisig account, to modify signatories or the threshold of a multisig account, and to convert a multisig account back to a single-signer account.

| Command                      | Use                                                              |
|------------------------------|------------------------------------------------------------------|
| `rotate challenge propose`   | Propose a rotation proof challenge                               |
| `rotate challenge sign`      | Sign a rotation proof challenge                                  |
| `rotate transaction propose` | Propose key rotation transaction for multisig account            |
| `rotate transaction sign`    | Sign key rotation transaction for multisig account               |
| `rotate execute single`      | Execute key rotation transaction from single-signer account      |
| `rotate execute multisig`    | Execute key rotation transaction from multisig account           |

:::tip
The next few demos use the Aptos devnet, which has historically been reset each Thursday.
Make sure devnet is live when you try running the examples!
:::

```zsh title=Command
sh ../examples/multisig.sh rotate
```

First, generate a vanity account for Ace and Bee, funding Ace since his account will need to pay for authentication key rotation transactions:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_prep_accounts
```

Note that the `keyfile fund` command is used to wrap a call to the `aptos` CLI:

<details>
<summary>Output</summary>

```zsh
=== Generate vanity account for Ace ===


Mining vanity address...
Using test password.
Keyfile now at ace.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Ace",
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "encrypted_private_key": "0x674141414141426a37762d5074594a4e397066647776426b59666a7043616a52736a51516f785279496359356e41336a646a6d4852652d5657534a5f554b4c774e4e716a713976416d7334423941526858493763614865444c735039685f47484a3530717557374e6e4e31794c6364625a347436747a4b4b4858576d4a4c384e6b386b556779553279586565",
    "salt": "0x3b98be7c51cfd4aa511d2e7050c714af"
}


=== Generate vanity account for Bee ===


Mining vanity address...
Using test password.
Keyfile now at bee.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Bee",
    "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
    "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3",
    "encrypted_private_key": "0x674141414141426a37762d515752725870697532417937533431445a495779357934625f38624a7948536761326c3433543944484967756e5978483259615369446f394331493969567a6f54475767395930614c4a49537a4d74574f5042466e6533375143587a73517a3843373848576a626b47715a59754a587742616b6d6367455f554d79726b46625242",
    "salt": "0x6b659b567324ce0883483240bfa77241"
}


=== Fund Ace on devnet ===


Running aptos CLI command: aptos account fund-with-faucet --account 0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a --faucet-url https://faucet.devnet.aptoslabs.com --url https://fullnode.devnet.aptoslabs.com/v1
New balance: 100000000
```

</details>

Next incorporate Ace and Bee into a multisig account, proposing a rotation proof challenge for rotation to the multisig account:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_convert_multisig
```

Here, since the multisig account has a threshold of 1, only Ace needs to sign the rotation proof challenge.
Then he can initiate the authentication key rotation transaction from his account:

<details>
<summary>Output</summary>

```zsh
=== Incorporate to 1-of-2 multisig ===


Multisig metafile now at initial.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Initial",
    "address": null,
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
    "authentication_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}


=== Propose rotation challenge for rotating to multisig ===


Rotation proof challenge proposal now at initial.challenge_proposal:
{
    "filetype": "Rotation proof challenge proposal",
    "description": "Initial",
    "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
    "from_is_single_signer": true,
    "to_is_single_signer": false,
    "sequence_number": 0,
    "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "current_auth_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
    "chain_id": 44,
    "expiry": "2030-01-01T00:00:00"
}


=== Have Ace sign challenge proposal ===


Using test password.
Rotation proof challenge signature now at ace_initial.challenge_signature:
{
    "filetype": "Rotation proof challenge signature",
    "description": "Ace initial",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Initial",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "from_is_single_signer": true,
        "to_is_single_signer": false,
        "sequence_number": 0,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
    },
    "signature": "0x4e5fcde82936f9160c37234945e0dfb4ba8c4424242b4589e054136bcecc2c65f02f021fcd412a168825edd8d3ab69eb4dd2ccecba59328ffd6061af88a8af05"
}


=== Have Ace execute rotation from single-signer account ===


Using test password.
Transaction successful: 0xc4e0c3e2b3d3d2195cbc98c068b0619f5bb0020af8db1cac375eab5efce3b1a4
Updating address in multisig metafile.
Multisig metafile now at initial.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Initial",
    "address": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
    "authentication_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}
```

</details>

Note that after the successful rotation transaction, the `"address"` field of the multisig metafile has been updated to the vanity address starting with `0xace...`.

Now, propose a threshold increase to 2 signatories:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_increase_propose
```

In this case, Ace and Bee both need to sign the rotation proof challenge since the account is rotating to a 2-of-2 multisig:

<details>
<summary>Output</summary>

```zsh
=== Increase metafile threshold to two signatures ===


Multisig metafile now at increased.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Increased",
    "address": null,
    "threshold": 2,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
    "authentication_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}


=== Propose rotation challenge for increasing threshold ===


Rotation proof challenge proposal now at increase.challenge_proposal:
{
    "filetype": "Rotation proof challenge proposal",
    "description": "Increase",
    "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
    "from_is_single_signer": false,
    "to_is_single_signer": false,
    "sequence_number": 1,
    "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "current_auth_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
    "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
    "chain_id": 44,
    "expiry": "2030-01-01T00:00:00"
}


=== Have Ace sign challenge proposal ===


Using test password.
Rotation proof challenge signature now at ace_increase.challenge_signature:
{
    "filetype": "Rotation proof challenge signature",
    "description": "Ace increase",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Increase",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
        "from_is_single_signer": false,
        "to_is_single_signer": false,
        "sequence_number": 1,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
    },
    "signature": "0x9e889c195507116c757336398e549d47216fa15612b4d36d06d3c7ad4107f87e7745a21874c8a7da2e78b299669170f574254731ace5dd2f7b9263d322f7d60e"
}


=== Have Bee sign challenge proposal ===


Using test password.
Rotation proof challenge signature now at bee_increase.challenge_signature:
{
    "filetype": "Rotation proof challenge signature",
    "description": "Bee increase",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Increase",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
        "from_is_single_signer": false,
        "to_is_single_signer": false,
        "sequence_number": 1,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "signatory": {
        "signatory": "Bee",
        "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
        "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
    },
    "signature": "0xd8e2c539b8004979c4091ae0318e8c3441629133e3158d9de25a6c74bd6fba0c442757f4390f8f2207af23043604bb87c59c209db680e6186e0b848fcea46a0c"
}
```

</details>

Now that the rotation proof challenge has been signed, the rotation transaction can be proposed.
Note that even though Ace and Bee both needed to sign the challenge (since the account to rotate to requires two signatures), only one of them needs to sign the transaction proposal (since the account undergoing rotation is originally 1-of-2).
Here, only Bee signs the transaction proposal, then the transaction can be executed.

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_increase_execute
```

<details>
<summary>Output</summary>

```zsh
=== Propose rotation transaction ===


Rotation transaction proposal now at increase.rotation_transaction_proposal:
{
    "filetype": "Rotation transaction proposal",
    "description": "Increase",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Increase",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
        "from_is_single_signer": false,
        "to_is_single_signer": false,
        "sequence_number": 1,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "challenge_from_signatures": [
        {
            "signatory": {
                "signatory": "Ace",
                "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
            },
            "signature": "0x9e889c195507116c757336398e549d47216fa15612b4d36d06d3c7ad4107f87e7745a21874c8a7da2e78b299669170f574254731ace5dd2f7b9263d322f7d60e"
        }
    ],
    "challenge_to_signatures": [
        {
            "signatory": {
                "signatory": "Ace",
                "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
            },
            "signature": "0x9e889c195507116c757336398e549d47216fa15612b4d36d06d3c7ad4107f87e7745a21874c8a7da2e78b299669170f574254731ace5dd2f7b9263d322f7d60e"
        },
        {
            "signatory": {
                "signatory": "Bee",
                "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
                "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
            },
            "signature": "0xd8e2c539b8004979c4091ae0318e8c3441629133e3158d9de25a6c74bd6fba0c442757f4390f8f2207af23043604bb87c59c209db680e6186e0b848fcea46a0c"
        }
    ]
}


=== Have Bee only sign rotation transaction proposal ===


Using test password.
Rotation transaction signature now at bee_increase.rotation_transaction_signature:
{
    "filetype": "Rotation transaction signature",
    "description": "Bee increase",
    "transaction_proposal": {
        "filetype": "Rotation transaction proposal",
        "description": "Increase",
        "challenge_proposal": {
            "filetype": "Rotation proof challenge proposal",
            "description": "Increase",
            "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
            "from_is_single_signer": false,
            "to_is_single_signer": false,
            "sequence_number": 1,
            "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
            "current_auth_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
            "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
            "chain_id": 44,
            "expiry": "2030-01-01T00:00:00"
        },
        "challenge_from_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0x9e889c195507116c757336398e549d47216fa15612b4d36d06d3c7ad4107f87e7745a21874c8a7da2e78b299669170f574254731ace5dd2f7b9263d322f7d60e"
            }
        ],
        "challenge_to_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0x9e889c195507116c757336398e549d47216fa15612b4d36d06d3c7ad4107f87e7745a21874c8a7da2e78b299669170f574254731ace5dd2f7b9263d322f7d60e"
            },
            {
                "signatory": {
                    "signatory": "Bee",
                    "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
                    "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
                },
                "signature": "0xd8e2c539b8004979c4091ae0318e8c3441629133e3158d9de25a6c74bd6fba0c442757f4390f8f2207af23043604bb87c59c209db680e6186e0b848fcea46a0c"
            }
        ]
    },
    "signatory": {
        "signatory": "Bee",
        "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
        "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
    },
    "signature": "0xdd38f37d861d6bba653040e661295747744b3bfa952d266cb114114f68b2ae5b46af25483c20ec5a70f4774f6bb05d74be193d17970bf5e06e1282392e76070c"
}


=== Submit rotation transaction ===


Transaction successful: 0x6e4675bdd5b4873c2d26797b39d44e0244182d2d11a979212b4e3d3f570cd0e1
Updating address in multisig metafile.
Multisig metafile now at initial.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Initial",
    "address": null,
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b01",
    "authentication_key": "0x4256f6a9293fd19642a5042c99dc772cac5afe6f4c1f5727794feb5aa324ac77",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}
Updating address in multisig metafile.
Multisig metafile now at increased.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Increased",
    "address": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "threshold": 2,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
    "authentication_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}
```

</details>

Note that the `"address"` field of `initial.multisig` has been set to `null`, and `increased.multisig` now reflects the vanity address starting with `0xace...`.

Next, propose a rotation proof challenge for rotating the account back to have Ace as a single signer:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_convert_single_propose
```

Here, Ace and Bee both need to sign the proposal since the account undergoing rotation is a 2-of-2 multisig:

<details>
<summary>Output</summary>

```zsh
=== Propose rotation challenge for rotating back to Ace ===

Rotation proof challenge proposal now at return.challenge_proposal:
{
    "filetype": "Rotation proof challenge proposal",
    "description": "Return",
    "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
    "from_is_single_signer": false,
    "to_is_single_signer": true,
    "sequence_number": 2,
    "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
    "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
    "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
    "chain_id": 44,
    "expiry": "2030-01-01T00:00:00"
}


=== Have Ace sign challenge proposal ===


Using test password.
Rotation proof challenge signature now at ace_return.challenge_signature:
{
    "filetype": "Rotation proof challenge signature",
    "description": "Ace return",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Return",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "from_is_single_signer": false,
        "to_is_single_signer": true,
        "sequence_number": 2,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
    },
    "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
}


=== Have Bee sign challenge proposal ===


Using test password.
Rotation proof challenge signature now at bee_return.challenge_signature:
{
    "filetype": "Rotation proof challenge signature",
    "description": "Bee return",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Return",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "from_is_single_signer": false,
        "to_is_single_signer": true,
        "sequence_number": 2,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "signatory": {
        "signatory": "Bee",
        "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
        "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
    },
    "signature": "0xdbc73adcce8e942e11a5ae0d4f9db57ce7055a279b9a436d5ad98a458ace0f27fb95b52569b5b8f290a21e23bfbe3d6c2717217c92d1cdeeb2d7d68aed41660c"
}
```

</details>

Now that both challenge signatures are available, a transaction from the multisig account can be proposed and executed:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh rotate_convert_single_execute
```

In this case, both Ace and Bee have to sign the transaction since the account undergoing rotation starts off as a 2-of-2 multisig:

<details>
<summary>Output</summary>

```zsh
=== Propose rotation transaction ===


Rotation transaction proposal now at return.rotation_transaction_proposal:
{
    "filetype": "Rotation transaction proposal",
    "description": "Return",
    "challenge_proposal": {
        "filetype": "Rotation proof challenge proposal",
        "description": "Return",
        "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
        "from_is_single_signer": false,
        "to_is_single_signer": true,
        "sequence_number": 2,
        "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
        "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
        "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "chain_id": 44,
        "expiry": "2030-01-01T00:00:00"
    },
    "challenge_from_signatures": [
        {
            "signatory": {
                "signatory": "Ace",
                "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
            },
            "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
        },
        {
            "signatory": {
                "signatory": "Bee",
                "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
                "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
            },
            "signature": "0xdbc73adcce8e942e11a5ae0d4f9db57ce7055a279b9a436d5ad98a458ace0f27fb95b52569b5b8f290a21e23bfbe3d6c2717217c92d1cdeeb2d7d68aed41660c"
        }
    ],
    "challenge_to_signatures": [
        {
            "signatory": {
                "signatory": "Ace",
                "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
            },
            "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
        }
    ]
}


=== Have Ace sign rotation transaction proposal ===


Using test password.
Rotation transaction signature now at ace_return.rotation_transaction_signature:
{
    "filetype": "Rotation transaction signature",
    "description": "Ace return",
    "transaction_proposal": {
        "filetype": "Rotation transaction proposal",
        "description": "Return",
        "challenge_proposal": {
            "filetype": "Rotation proof challenge proposal",
            "description": "Return",
            "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
            "from_is_single_signer": false,
            "to_is_single_signer": true,
            "sequence_number": 2,
            "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
            "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
            "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "chain_id": 44,
            "expiry": "2030-01-01T00:00:00"
        },
        "challenge_from_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
            },
            {
                "signatory": {
                    "signatory": "Bee",
                    "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
                    "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
                },
                "signature": "0xdbc73adcce8e942e11a5ae0d4f9db57ce7055a279b9a436d5ad98a458ace0f27fb95b52569b5b8f290a21e23bfbe3d6c2717217c92d1cdeeb2d7d68aed41660c"
            }
        ],
        "challenge_to_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
            }
        ]
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
        "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
    },
    "signature": "0xc0fe90d7274bfc9b1bea0e941dbbf4a11e28eabbefdd61b95e2e43ae4e2083eefa08f64c69938be5d58c1701f7850f3a1b493a7bf486799aaeba520d95c7f80e"
}


=== Have Bee sign rotation transaction proposal ===


Using test password.
Rotation transaction signature now at bee_return.rotation_transaction_signature:
{
    "filetype": "Rotation transaction signature",
    "description": "Bee return",
    "transaction_proposal": {
        "filetype": "Rotation transaction proposal",
        "description": "Return",
        "challenge_proposal": {
            "filetype": "Rotation proof challenge proposal",
            "description": "Return",
            "from_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
            "from_is_single_signer": false,
            "to_is_single_signer": true,
            "sequence_number": 2,
            "originator": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a",
            "current_auth_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
            "new_public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "chain_id": 44,
            "expiry": "2030-01-01T00:00:00"
        },
        "challenge_from_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
            },
            {
                "signatory": {
                    "signatory": "Bee",
                    "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
                    "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
                },
                "signature": "0xdbc73adcce8e942e11a5ae0d4f9db57ce7055a279b9a436d5ad98a458ace0f27fb95b52569b5b8f290a21e23bfbe3d6c2717217c92d1cdeeb2d7d68aed41660c"
            }
        ],
        "challenge_to_signatures": [
            {
                "signatory": {
                    "signatory": "Ace",
                    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
                    "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
                },
                "signature": "0xdb3e1c896703eedcbad0854ccbf5d87287c61885ea7490ed1f70560f23f9faf7a3278f04cf01ed9714236ab7e4fd0637889691dea197520cb28d5da0fbc4f401"
            }
        ]
    },
    "signatory": {
        "signatory": "Bee",
        "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
        "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
    },
    "signature": "0xafec5c906b5800848f6bede2fc313cf2a7565d298d4fcb43c1bb31040a2e405ed7a0e2941ef0650d6efa30702f51b97a4c1e02b5584a4b1fc20d07136c28a70f"
}


=== Submit rotation transaction ===


Transaction successful: 0x1c91d97ef2d9bfb9a09a0dbd1c34d272fa957d2468301d65e5e9d07068291373
Updating address in multisig metafile.
Multisig metafile now at increased.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Increased",
    "address": null,
    "threshold": 2,
    "n_signatories": 2,
    "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf75bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b02",
    "authentication_key": "0x3894d1a4d7b3a59e6b86c4fff71d6531315199fdb873f87a5b9fe30cf3b50315",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0x6691a5a2bc421a3b3049614a30c506b1ce0ecbc2a780fb843bf5cfba2b386bf7",
            "authentication_key": "0xace3e630afa569ce67bcb98de667d6a8323f02c4d5f77cead0cc41bedc172f1a"
        },
        {
            "signatory": "Bee",
            "public_key": "0x5bb9f4793e76a2320aba7151706ff2ed79cb0a5a8254312dbdb15c042165e04b",
            "authentication_key": "0xbeec0429e5e8afdd98d39fb5fbfcd608e438ea87d9d0dd1d5ba8fe23c2db21a3"
        }
    ]
}

```

</details>

Note that after the rotation, the metafile has been updated with `"address": null`

In practice, note that the consensus mechanism will probably entail something like the following:

1. Ace and Bee independently generate single-signer keyfiles.
2. One of them, for example Ace, acts as a "scribe", so Bee sends her keyfile to Ace.
3. Ace uses the `metafile incorporate` command to generate a multisig metafile, and sends a copy to Bee for her records.
4. Ace then uses the appropriate `metafile` and `rotate` subcommands to propose rotation proof challenges, rotation transactions, etc. (note that Bee's private key is encrypted so this is not a security threat).
5. Ace sends proposals over to Bee, then Bee signs them and sends her signature files back to Ace.
6. Ace signs locally, then executes transactions using his and Bee's signature files.

Theoretically this can be scaled to as many as 32 independent signatories, but note that higher numbers of signatories introduce logistical complexities (e.g. sending signature files back and forth in a group chat, or running shell commands with 32 arguments).

### Step 9.4 Protocol governance

In this section AMEE will be used to [publish and upgrade the same `UpgradeAndGovern` package as above](#step-8-perform-move-package-governance), then to invoke a different governance script, all under the authority of a 1-of-2 multisig account:

| Command                      | Use                                                              |
|------------------------------|------------------------------------------------------------------|
| `publish propose`            | Propose Move package publication                                 |
| `publish sign`               | Sign a Move package publication proposal                         |
| `publish execute`            | Execute Move package publication from proposal signature file(s) |
| `script propose`             | Propose Move script invocation                                   |
| `script sign`                | Sign a Move script invocation proposal                           |
| `script execute`             | Execute Move script invocation from proposal signature file(s)   |

```zsh title=Command
sh ../examples/multisig.sh govern
```

As before, this example begins with a vanity account for both Ace and Bee:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh govern_prep_accounts
```

<details>
<summary>Output</summary>

```zsh
=== Generate vanity account for Ace ===


Mining vanity address...
Using test password.
Keyfile now at ace.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Ace",
    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
    "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe",
    "encrypted_private_key": "0x674141414141426a394272644a6b4f7a66584d7a46764168397370784e6e694e3455634a51514b4b615159517034776941647a68675547684c76316f7a5045474958726635487444656f695859746a32646464487165446d69454a494a72424c4249306b58654e48384e5836342d42694c713642325769756772394946622d635a56563244694d456e504c66",
    "salt": "0x8e1eab26663623afb580ddbc51df6827"
}


=== Generate vanity account for Bee ===


Mining vanity address...
Using test password.
Keyfile now at bee.keyfile:
{
    "filetype": "Keyfile",
    "signatory": "Bee",
    "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
    "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b",
    "encrypted_private_key": "0x674141414141426a3942726550316a324c757a456d556f35727248506e77466c58697a3041713742744c384b41567a4931654a384c586576504e5438654b347964394470374a665166384a675a5533566f5279436d596d61577a2d7a76786d356d4762682d6b50322d594e5832664642326e4456346e6b7a4c574f42467358424f78505848534f4d4e574345",
    "salt": "0xdd3379cc341a5e32701cba37b48d2aa5"
}
```

</details>

Ace and Bee are then incorporated in a multisig, which is funded on devnet.
Note here that neither Ace nor Bee need to be funded, since the multisig account is linked with an on-chain account through direct funding, rather than through authentication key rotation.
Here, the multisig account address is identical to its authentication key, so the devnet faucet can simply be used to fund the corresponding address.
On testnet or mainnet, this process would probably entail sending `APT` to the account in question.

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh govern_prep_multisig
```

Note that the multisig metafile has `"address": null` before but not after the faucet funding operation:

<details>
<summary>Output</summary>

```zsh
=== Incorporate to 1-of-2 multisig ===


Multisig metafile now at protocol.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Protocol",
    "address": null,
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
    "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
            "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
        },
        {
            "signatory": "Bee",
            "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
            "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
        }
    ]
}


=== Fund multisig ===


Running aptos CLI command: aptos account fund-with-faucet --account 0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e --faucet-url https://faucet.devnet.aptoslabs.com --url https://fullnode.devnet.aptoslabs.com/v1
New balance: 100000000
Updating address in multisig metafile.
Multisig metafile now at protocol.multisig:
{
    "filetype": "Multisig metafile",
    "multisig_name": "Protocol",
    "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
    "threshold": 1,
    "n_signatories": 2,
    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
    "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
    "signatories": [
        {
            "signatory": "Ace",
            "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
            "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
        },
        {
            "signatory": "Bee",
            "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
            "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
        }
    ]
}
```

</details>

Next a Move package publication proposal is constructed, signed, and the package is published. Here, only Ace's signature is necessary because the multisig threshold is 1:

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh govern_publish
```

Note that the publication proposal includes information required to download and publish the package from GitHub:

* GitHub user
* GitHub project
* Commit
* Path to package's `Move.toml` inside the repository
* Named address to substitute inside `Move.toml`
* Sequence to publish modules in

:::tip
Modules should be listed from the bottom of the dependency hierarchy up, with modules that are used listed before the modules that use them, and modules that declare friends listed before the friends they declare.
:::

For this example, the `Move.toml` file in question is as follows:

```toml title="Move.toml"
:!: static/move-examples/upgrade_and_govern/v1_0_0/Move.toml manifest
```

Here, `Move.toml` contains the named address `upgrade_and_govern`, which is defined generically as `_`:
AMEE expects a named address of this format, corresponding to the multisig account address to publish under.

Note that the repository is downloaded and recompiled before signing, and before transaction execution.
This is to ensure that all signatories, as well as the transaction submitter, are referring to the same transaction payload (as defined by the GitHub information from the proposal file):

<details>
<summary>Output</summary>


```zsh
=== Propose publication ===


Publication proposal now at genesis.publication_proposal:
{
    "filetype": "Publication proposal",
    "description": "Genesis",
    "github_user": "alnoki",
    "github_project": "aptos-core",
    "commit": "1c26076f5f",
    "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_0_0/Move.toml",
    "named_address": "upgrade_and_govern",
    "module_sequence": [
        "parameters"
    ],
    "multisig": {
        "filetype": "Multisig metafile",
        "multisig_name": "Protocol",
        "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "threshold": 1,
        "n_signatories": 2,
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
        "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "signatories": [
            {
                "signatory": "Ace",
                "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
            },
            {
                "signatory": "Bee",
                "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
            }
        ]
    },
    "sequence_number": 0,
    "chain_id": 44,
    "expiry": "2030-12-31T00:00:00"
}


=== Sign publication proposal ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp4i9z7k4h.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp4i9z7k4h/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_0_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Using test password.
Publication signature now at genesis.publication_signature:
{
    "filetype": "Publication signature",
    "description": "Genesis",
    "transaction_proposal": {
        "filetype": "Publication proposal",
        "description": "Genesis",
        "github_user": "alnoki",
        "github_project": "aptos-core",
        "commit": "1c26076f5f",
        "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_0_0/Move.toml",
        "named_address": "upgrade_and_govern",
        "module_sequence": [
            "parameters"
        ],
        "multisig": {
            "filetype": "Multisig metafile",
            "multisig_name": "Protocol",
            "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "threshold": 1,
            "n_signatories": 2,
            "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
            "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "signatories": [
                {
                    "signatory": "Ace",
                    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                    "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
                },
                {
                    "signatory": "Bee",
                    "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                    "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
                }
            ]
        },
        "sequence_number": 0,
        "chain_id": 44,
        "expiry": "2030-12-31T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
        "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
    },
    "signature": "0xff4a53e80ea1ab58c33284df07a601bdd21082cf2106804a4176c351203b973c03b2530a1a0224fa415bddebfd7b576fe7bc294284a031f041cb37718fcda90c"
}


=== Execute publication ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmpi7mexcok.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmpi7mexcok/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_0_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Transaction successful: 0x54a594684829b5c7d84c1b5756ac0b5bd62e5e35a6747cf617bc415a1be5104a
```

</details>

Next, the package is upgraded to `v1.1.0`, which involves the same workflow albeit with a different manifest path and a new module to publish (`transfer.move` uses `parameters.move`, so it is listed second):

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh govern_upgrade
```

<details>
<summary>Output</summary>

```zsh
=== Propose upgrade ===


Publication proposal now at upgrade.publication_proposal:
{
    "filetype": "Publication proposal",
    "description": "Upgrade",
    "github_user": "alnoki",
    "github_project": "aptos-core",
    "commit": "1c26076f5f",
    "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_1_0/Move.toml",
    "named_address": "upgrade_and_govern",
    "module_sequence": [
        "parameters",
        "transfer"
    ],
    "multisig": {
        "filetype": "Multisig metafile",
        "multisig_name": "Protocol",
        "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "threshold": 1,
        "n_signatories": 2,
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
        "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "signatories": [
            {
                "signatory": "Ace",
                "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
            },
            {
                "signatory": "Bee",
                "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
            }
        ]
    },
    "sequence_number": 1,
    "chain_id": 44,
    "expiry": "2030-12-31T00:00:00"
}


=== Sign upgrade proposal ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmphpou29jf.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmphpou29jf/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_1_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Using test password.
Publication signature now at upgrade.publication_signature:
{
    "filetype": "Publication signature",
    "description": "Upgrade",
    "transaction_proposal": {
        "filetype": "Publication proposal",
        "description": "Upgrade",
        "github_user": "alnoki",
        "github_project": "aptos-core",
        "commit": "1c26076f5f",
        "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_1_0/Move.toml",
        "named_address": "upgrade_and_govern",
        "module_sequence": [
            "parameters",
            "transfer"
        ],
        "multisig": {
            "filetype": "Multisig metafile",
            "multisig_name": "Protocol",
            "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "threshold": 1,
            "n_signatories": 2,
            "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
            "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "signatories": [
                {
                    "signatory": "Ace",
                    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                    "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
                },
                {
                    "signatory": "Bee",
                    "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                    "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
                }
            ]
        },
        "sequence_number": 1,
        "chain_id": 44,
        "expiry": "2030-12-31T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
        "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
    },
    "signature": "0x999fe7b09ea10268c0178b3b20c8d23b6d12cdb1c0b7886ba7bcee200dc83a0472fe77c7f802e0cd36061fbb3258c73133622f4528ed0f1d242b7272156d1306"
}


=== Execute upgrade ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmpf2_geeeq.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmpf2_geeeq/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_1_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Transaction successful: 0x6aa9c7be0f42146d4c33257d7a82d913360b9f345d2247ee5ffb30ebeea81114
```

</details>

Lastly, the `set_only.move` governance script is invoked from the multisig account:

```rust title=set_only.move
:!: static/move-examples/upgrade_and_govern/v1_1_0/scripts/set_only.move script
```

Note here that the main function in this script, `set_only`, accepts only a `&signer` as an argument, with constants like `PARAMETER_1` and `PARAMETER_2` defined inside the script.
AMEE expects scripts of this format, having only a single `&signer` argument in the main function call, such that all inner function arguments other than the governance signature can be easily inspected on GitHub.

```zsh title="multisig.sh snippet"
:!: static/sdks/python/examples/multisig.sh govern_script
```

Note here that a script proposal is similar in form to a publication proposal, except for an additional `script_name` field (which specifies the name of the main function call), and no `module_sequence` field.
Similarly, the Move script in question is downloaded and recompiled during signing and submission, to ensure the same transaction payload:

<details>
<summary>Output</summary>

```zsh
=== Propose script invocation ===


Script proposal now at invoke.script_proposal:
{
    "filetype": "Script proposal",
    "description": "Invoke",
    "github_user": "alnoki",
    "github_project": "aptos-core",
    "commit": "1c26076f5f",
    "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_1_0/Move.toml",
    "named_address": "upgrade_and_govern",
    "script_name": "set_only",
    "multisig": {
        "filetype": "Multisig metafile",
        "multisig_name": "Protocol",
        "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "threshold": 1,
        "n_signatories": 2,
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
        "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
        "signatories": [
            {
                "signatory": "Ace",
                "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
            },
            {
                "signatory": "Bee",
                "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
            }
        ]
    },
    "sequence_number": 2,
    "chain_id": 44,
    "expiry": "2030-12-31T00:00:00"
}


=== Sign invocation proposal ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp45hu664y.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp45hu664y/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_1_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Using test password.
Script signature now at invoke.script_signature:
{
    "filetype": "Script signature",
    "description": "Invoke",
    "transaction_proposal": {
        "filetype": "Script proposal",
        "description": "Invoke",
        "github_user": "alnoki",
        "github_project": "aptos-core",
        "commit": "1c26076f5f",
        "manifest_path": "aptos-move/move-examples/upgrade_and_govern/v1_1_0/Move.toml",
        "named_address": "upgrade_and_govern",
        "script_name": "set_only",
        "multisig": {
            "filetype": "Multisig metafile",
            "multisig_name": "Protocol",
            "address": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "threshold": 1,
            "n_signatories": 2,
            "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4b1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e5601",
            "authentication_key": "0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e",
            "signatories": [
                {
                    "signatory": "Ace",
                    "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
                    "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
                },
                {
                    "signatory": "Bee",
                    "public_key": "0xb1966fd2d4d17c7963d485ac817b8a931b5be64e96ec65d5a6b575e6ff037e56",
                    "authentication_key": "0xbeec3b1787e9fcc0362fe28ea2c8c7e98b42ab9355e95fb440612d629756903b"
                }
            ]
        },
        "sequence_number": 2,
        "chain_id": 44,
        "expiry": "2030-12-31T00:00:00"
    },
    "signatory": {
        "signatory": "Ace",
        "public_key": "0xd956242c23a2a98a135e5685cc041b47b79866105d2cc91a507051a283fefae4",
        "authentication_key": "0xaceb4c8b33e42978f775f3b95207a500b4f6a6866fa449f9c4bed3a70f2baabe"
    },
    "signature": "0x2621d89dce35d188fde2f8cae70f80bac01a8d0c5de5230477003e6b39113122d56cf217a71b2b92292e26a23a2a8f8a80cc3d4660292eaa6cefce0bbc29b604"
}


=== Execute script invocation ===


Extracting https://github.com/alnoki/aptos-core/archive/1c26076f5f.zip to temporary directory /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp7wigfph5.
Running aptos CLI command: aptos move compile --save-metadata --included-artifacts none --package-dir /var/folders/4c/rtts9qpj3yq0f5_f_gbl6cn40000gn/T/tmp7wigfph5/aptos-core-1c26076f5f29f3e554393df6f6fb4851422755b9/aptos-move/move-examples/upgrade_and_govern/v1_1_0 --named-addresses upgrade_and_govern=0x2ab4d591c6d9a56c80fd3efecc8dbf2b6e13d64e1b2f1c1ab5eeb9f691c7da6e

Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING UpgradeAndGovern
Transaction successful: 0x75c783e1ed49539d1d6681ba0c5baf931f49958e0635622eca68fbe66badbc54
```

</details>

Again, in practice note that the consensus mechanism will probably entail something like the following, in the case of a 2-of-2 multisig (unlike a 1-of-2 in the above example):

1. Ace and Bee independently generate single-signer keyfiles.
2. One of them, for example Bee, acts as a "scribe", so Ace sends his keyfile to Bee.
3. Bee uses the `metafile incorporate` command to generate a multisig metafile, and sends a copy to Ace for his records.
4. Bee then uses the appropriate `publish` and `script` subcommands to propose package publications, package upgrades, and script invocations from the multisig account.
5. Bee sends proposals over to Ace, then Ace reviews the corresponding package on GitHub before signing and sending a signature files back to Bee.
6. Bee signs locally, then executes transactions using her and Ace's signature files.

Theoretically this can be scaled to as many as 32 independent signatories, but note that higher numbers of signatories introduce logistical complexities (e.g. sending signature files back and forth in a group chat, or running shell commands with 32 arguments).

---

Congratulations on completing the tutorial on K-of-N multi-signer authentication operations!
