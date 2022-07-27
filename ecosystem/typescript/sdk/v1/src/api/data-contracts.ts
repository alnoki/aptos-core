/* eslint-disable */
/* tslint:disable */
/*
 * ---------------------------------------------------------------
 * ## THIS FILE WAS GENERATED VIA SWAGGER-TYPESCRIPT-API        ##
 * ##                                                           ##
 * ## AUTHOR: acacode                                           ##
 * ## SOURCE: https://github.com/acacode/swagger-typescript-api ##
 * ---------------------------------------------------------------
 */

export interface AccountData {
  /** @format U64 */
  sequence_number: string;

  /** @format HexEncodedBytes */
  authentication_key: string;
}

export type AccountSignature = AccountSignatureEd25519Signature | AccountSignatureMultiEd25519Signature;

export type AccountSignatureEd25519Signature = { type: string } & Ed25519Signature;

export type AccountSignatureMultiEd25519Signature = { type: string } & MultiEd25519Signature;

/**
* This is the generic struct we use for all API errors, it contains a string
message and an Aptos API specific error code.
*/
export interface AptosError {
  message: string;

  /**
   * These codes provide more granular error information beyond just the HTTP
   * status code of the response.
   */
  error_code?: AptosErrorCode;

  /** @format U64 */
  aptos_ledger_version?: string;
}

/**
* These codes provide more granular error information beyond just the HTTP
status code of the response.
*/
export enum AptosErrorCode {
  UnsupportedAcceptType = 'UnsupportedAcceptType',
  ReadFromStorageError = 'ReadFromStorageError',
  InvalidBcsInStorageError = 'InvalidBcsInStorageError',
  BcsSerializationError = 'BcsSerializationError',
  InvalidStartParam = 'InvalidStartParam',
  InvalidLimitParam = 'InvalidLimitParam',
}

export interface BlockMetadataTransaction {
  /** @format U64 */
  version: string;

  /** @format HashValue */
  hash: string;

  /** @format HashValue */
  state_root_hash: string;

  /** @format HashValue */
  event_root_hash: string;

  /** @format U64 */
  gas_used: string;
  success: boolean;
  vm_status: string;

  /** @format HashValue */
  accumulator_root_hash: string;
  changes: WriteSetChange[];

  /** @format HashValue */
  id: string;

  /** @format U64 */
  epoch: string;

  /** @format U64 */
  round: string;
  events: Event[];
  previous_block_votes: boolean[];

  /** @format Address */
  proposer: string;
  failed_proposer_indices: number[];

  /** @format U64 */
  timestamp: string;
}

export interface DeleteModule {
  /** @format Address */
  address: string;
  state_key_hash: string;
  module: MoveModuleId;
}

export interface DeleteResource {
  /** @format Address */
  address: string;
  state_key_hash: string;
  resource: MoveStructTag;
}

export interface DeleteTableItem {
  state_key_hash: string;

  /** @format HexEncodedBytes */
  handle: string;

  /** @format HexEncodedBytes */
  key: string;
}

export interface DirectWriteSet {
  changes: WriteSetChange[];
  events: Event[];
}

export interface Ed25519Signature {
  /** @format HexEncodedBytes */
  public_key: string;

  /** @format HexEncodedBytes */
  signature: string;
}

export interface EncodeSubmissionRequest {
  /** @format Address */
  sender: string;

  /** @format U64 */
  sequence_number: string;

  /** @format U64 */
  max_gas_amount: string;

  /** @format U64 */
  gas_unit_price: string;

  /** @format U64 */
  expiration_timestamp_secs: string;
  payload: TransactionPayload;
  secondary_signers?: string[];
}

export interface Event {
  /** @format EventKey */
  key: string;

  /** @format U64 */
  sequence_number: string;

  /** @format MoveType */
  type: string;
  data: any;
}

export type GenesisPayload = GenesisPayloadWriteSetPayload;

export type GenesisPayloadWriteSetPayload = { type: string } & WriteSetPayload;

export interface GenesisTransaction {
  /** @format U64 */
  version: string;

  /** @format HashValue */
  hash: string;

  /** @format HashValue */
  state_root_hash: string;

  /** @format HashValue */
  event_root_hash: string;

  /** @format U64 */
  gas_used: string;
  success: boolean;
  vm_status: string;

  /** @format HashValue */
  accumulator_root_hash: string;
  changes: WriteSetChange[];
  payload: GenesisPayload;
  events: Event[];
}

/**
* The struct holding all data returned to the client by the
index endpoint (i.e., GET "/").
*/
export interface IndexResponse {
  /** @format uint8 */
  chain_id: number;

  /** @format U64 */
  epoch: string;

  /** @format U64 */
  ledger_version: string;

  /** @format U64 */
  oldest_ledger_version: string;

  /** @format U64 */
  ledger_timestamp: string;
  node_role: RoleType;
}

export interface ModuleBundlePayload {
  modules: MoveModuleBytecode[];
}

export interface MoveFunction {
  /** @format IdentifierWrapper */
  name: string;
  visibility: MoveFunctionVisibility;
  is_entry: boolean;
  generic_type_params: MoveFunctionGenericTypeParam[];
  params: string[];
  return: string[];
}

export interface MoveFunctionGenericTypeParam {
  constraints: string[];
}

export enum MoveFunctionVisibility {
  Private = 'Private',
  Public = 'Public',
  Friend = 'Friend',
}

export interface MoveModule {
  /** @format Address */
  address: string;

  /** @format IdentifierWrapper */
  name: string;
  friends: MoveModuleId[];
  exposed_functions: MoveFunction[];
  structs: MoveStruct[];
}

export interface MoveModuleBytecode {
  /** @format HexEncodedBytes */
  bytecode: string;
  abi?: MoveModule;
}

export interface MoveModuleId {
  /** @format Address */
  address: string;

  /** @format IdentifierWrapper */
  name: string;
}

export interface MoveResource {
  type: MoveStructTag;
  data: Record<string, any>;
}

export interface MoveScriptBytecode {
  /** @format HexEncodedBytes */
  bytecode: string;
  abi?: MoveFunction;
}

export interface MoveStruct {
  /** @format IdentifierWrapper */
  name: string;
  is_native: boolean;
  abilities: string[];
  generic_type_params: MoveStructGenericTypeParam[];
  fields: MoveStructField[];
}

export interface MoveStructField {
  /** @format IdentifierWrapper */
  name: string;

  /** @format MoveType */
  type: string;
}

export interface MoveStructGenericTypeParam {
  constraints: string[];
  is_phantom: boolean;
}

export interface MoveStructTag {
  /** @format Address */
  address: string;

  /** @format IdentifierWrapper */
  module: string;

  /** @format IdentifierWrapper */
  name: string;
  generic_type_params: string[];
}

export interface MultiAgentSignature {
  sender: AccountSignature;
  secondary_signer_addresses: string[];
  secondary_signers: AccountSignature[];
}

export interface MultiEd25519Signature {
  public_keys: string[];
  signatures: string[];

  /** @format uint8 */
  threshold: number;

  /** @format HexEncodedBytes */
  bitmap: string;
}

export interface PendingTransaction {
  /** @format HashValue */
  hash: string;

  /** @format Address */
  sender: string;

  /** @format U64 */
  sequence_number: string;

  /** @format U64 */
  max_gas_amount: string;

  /** @format U64 */
  gas_unit_price: string;

  /** @format U64 */
  expiration_timestamp_secs: string;
  payload: TransactionPayload;
  signature?: TransactionSignature;
}

export enum RoleType {
  Validator = 'Validator',
  FullNode = 'FullNode',
}

export interface ScriptFunctionId {
  module: MoveModuleId;

  /** @format IdentifierWrapper */
  name: string;
}

export interface ScriptFunctionPayload {
  function: ScriptFunctionId;
  type_arguments: string[];
  arguments: any[];
}

export interface ScriptPayload {
  code: MoveScriptBytecode;
  type_arguments: string[];
  arguments: any[];
}

export interface ScriptWriteSet {
  /** @format Address */
  execute_as: string;
  script: ScriptPayload;
}

export interface StateCheckpointTransaction {
  /** @format U64 */
  version: string;

  /** @format HashValue */
  hash: string;

  /** @format HashValue */
  state_root_hash: string;

  /** @format HashValue */
  event_root_hash: string;

  /** @format U64 */
  gas_used: string;
  success: boolean;
  vm_status: string;

  /** @format HashValue */
  accumulator_root_hash: string;
  changes: WriteSetChange[];

  /** @format U64 */
  timestamp: string;
}

export interface SubmitTransactionRequest {
  /** @format Address */
  sender: string;

  /** @format U64 */
  sequence_number: string;

  /** @format U64 */
  max_gas_amount: string;

  /** @format U64 */
  gas_unit_price: string;

  /** @format U64 */
  expiration_timestamp_secs: string;
  payload: TransactionPayload;
  signature: TransactionSignature;
}

export type Transaction =
  | TransactionPendingTransaction
  | TransactionUserTransaction
  | TransactionGenesisTransaction
  | TransactionBlockMetadataTransaction
  | TransactionStateCheckpointTransaction;

export type TransactionPayload =
  | TransactionPayloadScriptFunctionPayload
  | TransactionPayloadScriptPayload
  | TransactionPayloadModuleBundlePayload
  | TransactionPayloadWriteSetPayload;

export type TransactionPayloadModuleBundlePayload = { type: string } & ModuleBundlePayload;

export type TransactionPayloadScriptFunctionPayload = { type: string } & ScriptFunctionPayload;

export type TransactionPayloadScriptPayload = { type: string } & ScriptPayload;

export type TransactionPayloadWriteSetPayload = { type: string } & WriteSetPayload;

export type TransactionSignature =
  | TransactionSignatureEd25519Signature
  | TransactionSignatureMultiEd25519Signature
  | TransactionSignatureMultiAgentSignature;

export type TransactionSignatureEd25519Signature = { type: string } & Ed25519Signature;

export type TransactionSignatureMultiAgentSignature = { type: string } & MultiAgentSignature;

export type TransactionSignatureMultiEd25519Signature = { type: string } & MultiEd25519Signature;

export type TransactionBlockMetadataTransaction = { type: string } & BlockMetadataTransaction;

export type TransactionGenesisTransaction = { type: string } & GenesisTransaction;

export type TransactionPendingTransaction = { type: string } & PendingTransaction;

export type TransactionStateCheckpointTransaction = { type: string } & StateCheckpointTransaction;

export type TransactionUserTransaction = { type: string } & UserTransaction;

export interface UserTransaction {
  /** @format U64 */
  version: string;

  /** @format HashValue */
  hash: string;

  /** @format HashValue */
  state_root_hash: string;

  /** @format HashValue */
  event_root_hash: string;

  /** @format U64 */
  gas_used: string;
  success: boolean;
  vm_status: string;

  /** @format HashValue */
  accumulator_root_hash: string;
  changes: WriteSetChange[];

  /** @format Address */
  sender: string;

  /** @format U64 */
  sequence_number: string;

  /** @format U64 */
  max_gas_amount: string;

  /** @format U64 */
  gas_unit_price: string;

  /** @format U64 */
  expiration_timestamp_secs: string;
  payload: TransactionPayload;
  signature?: TransactionSignature;
  events: Event[];

  /** @format U64 */
  timestamp: string;
}

export interface WriteModule {
  /** @format Address */
  address: string;
  state_key_hash: string;
  data: MoveModuleBytecode;
}

export interface WriteResource {
  /** @format Address */
  address: string;
  state_key_hash: string;
  data: MoveResource;
}

export type WriteSet = WriteSetScriptWriteSet | WriteSetDirectWriteSet;

export type WriteSetChange =
  | WriteSetChangeDeleteModule
  | WriteSetChangeDeleteResource
  | WriteSetChangeDeleteTableItem
  | WriteSetChangeWriteModule
  | WriteSetChangeWriteResource
  | WriteSetChangeWriteTableItem;

export type WriteSetChangeDeleteModule = { type: string } & DeleteModule;

export type WriteSetChangeDeleteResource = { type: string } & DeleteResource;

export type WriteSetChangeDeleteTableItem = { type: string } & DeleteTableItem;

export type WriteSetChangeWriteModule = { type: string } & WriteModule;

export type WriteSetChangeWriteResource = { type: string } & WriteResource;

export type WriteSetChangeWriteTableItem = { type: string } & WriteTableItem;

export interface WriteSetPayload {
  write_set: WriteSet;
}

export type WriteSetDirectWriteSet = { type: string } & DirectWriteSet;

export type WriteSetScriptWriteSet = { type: string } & ScriptWriteSet;

export interface WriteTableItem {
  state_key_hash: string;

  /** @format HexEncodedBytes */
  handle: string;

  /** @format HexEncodedBytes */
  key: string;

  /** @format HexEncodedBytes */
  value: string;
}
