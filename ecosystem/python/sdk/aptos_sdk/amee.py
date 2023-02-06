"""Aptos Multisig Execution Expeditor (AMEE)."""

import argparse
import base64
import getpass
import json
import secrets
from pathlib import Path
from typing import Any, Dict, List
from typing import Optional as Option
from typing import Tuple

from aptos_sdk.account import Account
from aptos_sdk.ed25519 import MultiEd25519PublicKey, PublicKey
from cryptography.exceptions import InvalidSignature
from cryptography.fernet import Fernet, InvalidToken
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from nacl.signing import VerifyKey

MAX_SIGNATORIES = 32
"""Maximum number of signatories on a multisig account."""

MIN_PASSWORD_LENGTH = 4
"""The minimum password length."""

MIN_SIGNATORIES = 2
"""Minimum number of signatories on a multisig account."""

MIN_THRESHOLD = 1
"""Minimum number of signatures required to for multisig transaction."""


def bytes_to_prefixed_hex(input_bytes: bytes) -> str:
    """Convert bytes to hex string with 0x prefix."""
    return f"0x{input_bytes.hex()}"


def prefixed_hex_to_bytes(prefixed_hex: str) -> bytes:
    """Convert hex string with 0x prefix to bytes."""
    return bytes.fromhex(prefixed_hex[2:])


def check_keyfile_password(path: Path) -> Tuple[Dict[Any, Any], Option[bytes]]:
    """Check keyfile password, returning JSON data/private key bytes."""
    with open(path, "r", encoding="utf-8") as keyfile:  # Open keyfile:
        data = json.load(keyfile)  # Load JSON data from keyfile.
    salt = prefixed_hex_to_bytes(data["salt"])  # Get salt bytes.
    encrypted_hex = data["encrypted_private_key"]  # Get encrypted key.
    # Convert encrypted private key hex to bytes.
    encrypted_private_key = prefixed_hex_to_bytes(encrypted_hex)
    # Define password input prompt.
    prompt = "Enter password for encrypted private key: "
    password = getpass.getpass(prompt)  # Get keyfile password.
    # Generate Fernet encryption assistant from password and salt.
    fernet = derive_password_protection_fernet(password, salt)
    try:  # Try decrypting private key.
        private_key = fernet.decrypt(encrypted_private_key)
    # If exception from attempting to decrypt private key:
    except (InvalidSignature, InvalidToken):
        print("Invalid password.")  # Inform user.
        private_key = None  # Set private key to none.
    return data, private_key  # Return JSON data, private key.


def check_name(tokens: List[str]) -> str:
    """Check list of tokens for valid name, return concatenated str."""
    name = " ".join(tokens)  # Get name.
    # Assert that name is not blank space.
    assert len(name) != 0 and not name.isspace(), "Name may not be blank."
    return name  # Return name.


def check_outfile_exists(path: Path):
    """Verify desired outfile does not already exist."""
    assert not path.exists(), f"{path} already exists."


def check_password_length(password: str):
    """Verify password meets minimum length threshold."""
    assert (
        len(password) >= MIN_PASSWORD_LENGTH
    ), f"Password should be at least {MIN_PASSWORD_LENGTH} characters."


def derive_password_protection_fernet(password: str, salt: bytes) -> Fernet:
    """Derive Fernet encryption key assistant from password and salt.

    For password-protecting a private key on disk.

    References
    ----------
    https://cryptography.io/en/latest/fernet
    https://stackoverflow.com/questions/2490334
    """
    key_derivation_function = PBKDF2HMAC(
        algorithm=hashes.SHA256(), length=32, salt=salt, iterations=480_000
    )  # Create key derivation function from salt.
    # Derive key from password.
    derived_key = key_derivation_function.derive(password.encode())
    # Return Fernet encryption assistant.
    return Fernet(base64.urlsafe_b64encode(derived_key))


def encrypt_private_key(private_key_bytes: bytes) -> Tuple[bytes, bytes]:
    """Return encrypted private key and salt."""
    # Define new password prompt.
    message = "Enter new password for encrypting private key: "
    password = getpass.getpass(message)  # Get keyfile password.
    check_password_length(password)  # Check password length.
    # Have user re-enter password.
    check = getpass.getpass("Re-enter password: ")
    # Assert passwords match.
    assert password == check, "Passwords do not match."
    salt = secrets.token_bytes(16)  # Generate encryption salt.
    # Generate Fernet encryption assistant from password and salt.
    fernet = derive_password_protection_fernet(password, salt)
    # Encrypt private key.
    encrypted_private_key = fernet.encrypt(private_key_bytes)
    return encrypted_private_key, salt  # Return key, salt.


def incorporate(args):
    """Incorporate single-signer keyfiles to multisig metadata file."""
    n_signers = len(args.keyfiles)  # Get number of signers.
    assert MIN_SIGNATORIES <= n_signers <= MAX_SIGNATORIES, (
        f"Number of signatories must be between {MIN_SIGNATORIES} and "
        f"{MAX_SIGNATORIES} (inclusive)."
    )  # Assert valid number of signatories.
    assert MIN_THRESHOLD <= args.threshold <= n_signers, (
        f"Signature threshold must be greater than {MIN_THRESHOLD} and less "
        f"than the number of signatories."
    )  # Assert valid signature threshold.
    multisig_name = check_name(args.name)  # Check name.
    signatories = []  # Initialize empty signatories list.
    public_keys = []  # Initialize empty public keys list.
    for keyfile in args.keyfiles:  # Loop over keyfiles.
        signatory = json.load(keyfile)  # Load signatory data.
        # Get signatory's public key as bytes.
        public_key_bytes = prefixed_hex_to_bytes(signatory["public_key"])
        # Append public key to list of public keys.
        public_keys.append(PublicKey(VerifyKey(public_key_bytes)))
        signatories.append(
            dict(
                (field, signatory[field])
                for field in ["signatory", "public_key", "authentication_key"]
            )
        )  # Extract relevant fields for list of signatories.
    # Initialize multisig public key.
    multi_key = MultiEd25519PublicKey(public_keys, args.threshold)
    # Get authentication key as prefixed hex.
    auth_key = bytes_to_prefixed_hex(multi_key.auth_key().hex())
    data = {  # Generate JSON data for multisig metadata file.
        "multisig_name": multisig_name,
        "threshold": args.threshold,
        "n_signatories": n_signers,
        "public_key": bytes_to_prefixed_hex(multi_key.to_bytes()),
        "authentication_key": auth_key,
        "signatories": signatories,
    }
    if args.metafile is None:  # If no custom filepath specified:
        # Create filepath from multisig name.
        args.metafile = Path("_".join(args.name).casefold() + ".multisig")
    check_outfile_exists(args.metafile)  # Check if path exists.
    # Dump JSON data to metafile.
    with open(args.metafile, "w", encoding="utf-8") as metafile:
        json.dump(data, metafile, indent=4)
    with open(args.metafile, "r", encoding="utf-8") as metafile:
        header = "New multisig metadata file at"  # Message header.
        # Print contents of new metafile.
        print(f"{header} {args.metafile}: {metafile.read()}")


def keyfile_change_password(args):
    """Change password for a single-signer keyfile."""
    # Check password, get keyfile data and optional private key bytes.
    data, private_key_bytes = check_keyfile_password(args.keyfile)
    if private_key_bytes is not None:  # If able to decrypt private key:
        # Encrypt private key.
        encrypted_private_key_bytes, salt = encrypt_private_key(private_key_bytes)
        # Get encrypted private key hex.
        key_hex = bytes_to_prefixed_hex(encrypted_private_key_bytes)
        # Update JSON with encrypted private key.
        data["encrypted_private_key"] = key_hex
        # Update JSON with new salt.
        data["salt"] = bytes_to_prefixed_hex(salt.hex())
        keyfile_write_json(args.keyfile, data)  # Write JSON to keyfile.


def keyfile_extract(args):
    """Extract private key from keyfile, store via
    aptos_sdk.account.Account.store"""
    check_outfile_exists(args.account_store)  # Check if path exists.
    # Try loading private key bytes.
    _, private_key_bytes = check_keyfile_password(args.keyfile)
    # If able to successfully decrypt:
    if private_key_bytes is not None:
        # Load account.
        account = Account.load_key(private_key_bytes.hex())
        # Store Aptos account file.
        account.store(f"{args.account_store}")
        # Open new Aptos account store:
        with open(args.account_store, "r", encoding="utf-8") as outfile:
            # Print contents of new account store.
            print(f"New account store at {args.account_store}: \n{outfile.read()}")


def keyfile_generate(args):
    """Generate a keyfile for a single signer."""
    signatory = check_name(args.signatory)
    if args.account_store is None:  # If no account store supplied:
        account = Account.generate()  # Generate new account.
    else:  # If account store path supplied:
        # Generate an account from it.
        account = Account.load(f"{args.account_store}")
    # Get private key bytes.
    private_key_bytes = account.private_key.key.encode()
    # Encrypt private key.
    encrypted_private_key_bytes, salt = encrypt_private_key(private_key_bytes)
    # Get encrypted private key hex.
    key_hex = bytes_to_prefixed_hex(encrypted_private_key_bytes)
    data = {  # Generate JSON data for keyfile.
        "signatory": signatory,
        "public_key": f"{account.public_key()}",
        "authentication_key": account.auth_key(),
        "encrypted_private_key": key_hex,
        "salt": bytes_to_prefixed_hex(salt),
    }
    if args.keyfile is None:  # If no custom filepath specified:
        # Create filepath from signatory name.
        args.keyfile = Path("_".join(args.signatory).casefold() + ".keyfile")
    check_outfile_exists(args.keyfile)  # Check if path exists.
    keyfile_write_json(args.keyfile, data)  # Write JSON to keyfile.


def keyfile_verify(args):
    """Verify password for single-signer keyfile generated via
    keyfile_generate(), show public key and authentication key."""
    # Load JSON data and try getting private key bytes.
    data, private_key_bytes = check_keyfile_password(args.keyfile)
    if private_key_bytes is not None:  # If able to decrypt private key:
        # Print keyfile metadata.
        print(f'Keyfile password verified for {data["signatory"]}')
        print(f'Public key:         {data["public_key"]}')
        print(f'Authentication key: {data["authentication_key"]}')


def keyfile_write_json(path: Path, data: Dict[str, str]):
    """Write JSON data to keyfile path."""
    # Dump JSON data to keyfile.
    with open(path, "w", encoding="utf-8") as keyfile:
        json.dump(data, keyfile, indent=4)
    with open(path, "r", encoding="utf-8") as keyfile:
        # Print contents of new keyfile.
        print(f"New keyfile at {path}: \n{keyfile.read()}")


# AMEE parser.
parser = argparse.ArgumentParser(
    description="""Aptos Multisig Execution Expeditor (AMEE): A collection of
        tools designed to expedite multisig account execution."""
)
subparsers = parser.add_subparsers(required=True)

# Incorporate subcommand parser.
parser_incorporate = subparsers.add_parser(
    name="incorporate",
    aliases=["i"],
    description="""Incorporate multiple single-signer keyfiles into a multisig
        metadata file.""",
    help="Incorporate multiple signer singers into a multisig.",
)
parser_incorporate.set_defaults(func=incorporate)
parser_incorporate.add_argument(
    "name",
    type=str,
    nargs="+",
    help="""The name of the multisig entity. For example "Aptos" or "The Aptos
        Foundation".""",
)
parser_incorporate.add_argument(
    "-t",
    "--threshold",
    type=int,
    help="""The number of single signers required to approve a transaction.""",
    required=True,
)
parser_incorporate.add_argument(
    "-k",
    "--keyfiles",
    action="extend",
    nargs="+",
    type=argparse.FileType("r", encoding="utf-8"),
    help="""Relative paths to single-signer keyfiles in the multisig.""",
    required=True,
)
parser_incorporate.add_argument(
    "-m",
    "--metafile",
    type=Path,
    help="""Custom relative path to desired multisig metadata file.""",
)

# Keyfile subcommand parser.
parser_keyfile = subparsers.add_parser(
    name="keyfile",
    aliases=["k"],
    description="Assorted single-signer keyfile operations.",
    help="Single-signer keyfile operations.",
)
subparsers_keyfile = parser_keyfile.add_subparsers(required=True)

# Keyfile change password subcommand parser.
parser_keyfile_change_password = subparsers_keyfile.add_parser(
    name="change-password",
    aliases=["c"],
    description="""Change password for a single-singer keyfile.""",
    help="Change keyfile password.",
)
parser_keyfile_change_password.set_defaults(func=keyfile_change_password)
parser_keyfile_change_password.add_argument(
    "keyfile", type=Path, help="""Relative path to keyfile."""
)

# Keyfile extract subcommand parser.
parser_keyfile_extract = subparsers_keyfile.add_parser(
    name="extract",
    aliases=["e"],
    description="""Generate an `aptos_sdk.account.Account` from a single-signer
        keyfile then store on disk via `aptos_sdk.account.Account.store`.""",
    help="Extract Aptos account store from keyfile.",
)
parser_keyfile_extract.set_defaults(func=keyfile_extract)
parser_keyfile_extract.add_argument(
    "keyfile", type=Path, help="""Relative path to keyfile to extract from."""
)
parser_keyfile_extract.add_argument(
    "account_store",
    metavar="account-store",
    type=Path,
    help="""Relative path to account file to store in.""",
)

# Keyfile generate subcommand parser.
parser_keyfile_generate = subparsers_keyfile.add_parser(
    name="generate",
    aliases=["g"],
    description="Generate a single-signer keyfile.",
    help="Generate new keyfile.",
)
parser_keyfile_generate.set_defaults(func=keyfile_generate)
parser_keyfile_generate.add_argument(
    "signatory",
    type=str,
    nargs="+",
    help="""The name of the entity acting as a signatory. For example "Aptos"
        or "The Aptos Foundation".""",
)
parser_keyfile_generate.add_argument(
    "-a",
    "--account-store",
    type=Path,
    help="""Relative path to Aptos account data generated via
        `aptos_sdk.account.Account.store()`.""",
)
parser_keyfile_generate.add_argument(
    "-k", "--keyfile", type=Path, help="""Relative path to desired keyfile."""
)

# Keyfile verify subcommand parser.
parser_keyfile_verify = subparsers_keyfile.add_parser(
    name="verify",
    aliases=["v"],
    description="Verify password for a single-signer keyfile.",
    help="Verify keyfile password.",
)
parser_keyfile_verify.set_defaults(func=keyfile_verify)
parser_keyfile_verify.add_argument(
    "keyfile", type=Path, help="""Relative path to keyfile."""
)

parsed_args = parser.parse_args()  # Parse command line arguments.
parsed_args.func(parsed_args)  # Call command line argument function.
