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

import {
  AptosError,
  EncodeSubmissionRequest,
  PendingTransaction,
  SubmitTransactionRequest,
  Transaction,
} from './data-contracts';
import { ContentType, HttpClient, RequestParams } from './http-client';

export class Transactions<SecurityDataType = unknown> {
  http: HttpClient<SecurityDataType>;

  constructor(http: HttpClient<SecurityDataType>) {
    this.http = http;
  }

  /**
   * @description todo
   *
   * @tags Transactions
   * @name GetTransactions
   * @summary Get transactions
   * @request GET:/transactions
   */
  getTransactions = (query?: { start?: string; limit?: number }, params: RequestParams = {}) =>
    this.http.request<Transaction[], AptosError>({
      path: `/transactions`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
  /**
   * @description todo
   *
   * @tags Transactions
   * @name SubmitTransaction
   * @summary Submit transaction
   * @request POST:/transactions
   */
  submitTransaction = (data: SubmitTransactionRequest, params: RequestParams = {}) =>
    this.http.request<PendingTransaction, AptosError>({
      path: `/transactions`,
      method: 'POST',
      body: data,
      type: ContentType.Json,
      format: 'json',
      ...params,
    });
  /**
   * @description todo
   *
   * @tags Transactions
   * @name GetTransactionByHash
   * @summary Get transaction by hash
   * @request GET:/transactions/by_hash/{txn_hash}
   */
  getTransactionByHash = (txnHash: string, params: RequestParams = {}) =>
    this.http.request<Transaction, AptosError>({
      path: `/transactions/by_hash/${txnHash}`,
      method: 'GET',
      format: 'json',
      ...params,
    });
  /**
   * @description todo
   *
   * @tags Transactions
   * @name GetTransactionByVersion
   * @summary Get transaction by version
   * @request GET:/transactions/by_version/{txn_version}
   */
  getTransactionByVersion = (txnVersion: string, params: RequestParams = {}) =>
    this.http.request<Transaction, AptosError>({
      path: `/transactions/by_version/${txnVersion}`,
      method: 'GET',
      format: 'json',
      ...params,
    });
  /**
   * @description Simulate submitting a transaction. To use this, you must: - Create a SignedTransaction with a zero-padded signature. - Submit a SubmitTransactionRequest containing a UserTransactionRequest containing that signature.
   *
   * @tags Transactions
   * @name SimulateTransaction
   * @summary Simulate transaction
   * @request POST:/transactions/simulate
   */
  simulateTransaction = (data: SubmitTransactionRequest, params: RequestParams = {}) =>
    this.http.request<Transaction[], AptosError>({
      path: `/transactions/simulate`,
      method: 'POST',
      body: data,
      type: ContentType.Json,
      format: 'json',
      ...params,
    });
  /**
   * @description This endpoint accepts an EncodeSubmissionRequest, which internally is a UserTransactionRequestInner (and optionally secondary signers) encoded as JSON, validates the request format, and then returns that request encoded in BCS. The client can then use this to create a transaction signature to be used in a SubmitTransactionRequest, which it then passes to the /transactions POST endpoint. To be clear, this endpoint makes it possible to submit transaction requests to the API from languages that do not have library support for BCS. If you are using an SDK that has BCS support, such as the official Rust, TypeScript, or Python SDKs, you do not need to use this endpoint. To sign a message using the response from this endpoint: - Decode the hex encoded string in the response to bytes. - Sign the bytes to create the signature. - Use that as the signature field in something like Ed25519Signature, which you then use to build a TransactionSignature.
   *
   * @tags Transactions
   * @name EncodeSubmission
   * @summary Encode submission
   * @request POST:/transactions/encode_submission
   */
  encodeSubmission = (data: EncodeSubmissionRequest, params: RequestParams = {}) =>
    this.http.request<string, AptosError>({
      path: `/transactions/encode_submission`,
      method: 'POST',
      body: data,
      type: ContentType.Json,
      format: 'json',
      ...params,
    });
}
