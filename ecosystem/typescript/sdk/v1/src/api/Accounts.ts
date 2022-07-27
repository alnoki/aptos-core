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

import { AccountData, AptosError, Event, MoveModuleBytecode, MoveResource, Transaction } from './data-contracts';
import { HttpClient, RequestParams } from './http-client';

export class Accounts<SecurityDataType = unknown> {
  http: HttpClient<SecurityDataType>;

  constructor(http: HttpClient<SecurityDataType>) {
    this.http = http;
  }

  /**
   * @description Return high level information about an account such as its sequence number.
   *
   * @tags Accounts
   * @name GetAccount
   * @summary Get account
   * @request GET:/accounts/{address}
   */
  getAccount = (address: string, query?: { ledger_version?: string }, params: RequestParams = {}) =>
    this.http.request<AccountData, AptosError>({
      path: `/accounts/${address}`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
  /**
   * @description This endpoint returns all account resources at a given address at a specific ledger version (AKA transaction version). If the ledger version is not specified in the request, the latest ledger version is used. The Aptos nodes prune account state history, via a configurable time window (link). If the requested data has been pruned, the server responds with a 404.
   *
   * @tags Accounts
   * @name GetAccountResources
   * @summary Get account resources
   * @request GET:/accounts/{address}/resources
   */
  getAccountResources = (address: string, query?: { ledger_version?: string }, params: RequestParams = {}) =>
    this.http.request<MoveResource[], AptosError>({
      path: `/accounts/${address}/resources`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
  /**
   * @description This endpoint returns account resources for a specific ledger version (AKA transaction version). If not present, the latest version is used. <---- TODO Update this comment The Aptos nodes prune account state history, via a configurable time window (link). If the requested data has been pruned, the server responds with a 404
   *
   * @tags Accounts
   * @name GetAccountModules
   * @summary Get account modules
   * @request GET:/accounts/{address}/modules
   */
  getAccountModules = (address: string, query?: { ledger_version?: string }, params: RequestParams = {}) =>
    this.http.request<MoveModuleBytecode[], AptosError>({
      path: `/accounts/${address}/modules`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
  /**
   * @description This API extracts event key from the account resource identified by the `event_handle_struct` and `field_name`, then returns events identified by the event key.
   *
   * @tags Events
   * @name GetEventsByEventHandle
   * @summary Get events by event handle
   * @request GET:/accounts/{address}/events/{event_handle}/{field_name}
   */
  getEventsByEventHandle = (
    address: string,
    eventHandle: string,
    fieldName: string,
    query?: { start?: string; limit?: number },
    params: RequestParams = {},
  ) =>
    this.http.request<Event[], AptosError>({
      path: `/accounts/${address}/events/${eventHandle}/${fieldName}`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
  /**
   * @description todo todo, note that this currently returns [] even if the account doesn't exist, when it should really return a 404.
   *
   * @tags Transactions
   * @name GetAccountTransactions
   * @summary Get account transactions
   * @request GET:/accounts/{address}/transactions
   */
  getAccountTransactions = (address: string, query?: { start?: string; limit?: number }, params: RequestParams = {}) =>
    this.http.request<Transaction[], AptosError>({
      path: `/accounts/${address}/transactions`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
}
