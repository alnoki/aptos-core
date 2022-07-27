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

import { AptosError, Event } from './data-contracts';
import { HttpClient, RequestParams } from './http-client';

export class Events<SecurityDataType = unknown> {
  http: HttpClient<SecurityDataType>;

  constructor(http: HttpClient<SecurityDataType>) {
    this.http = http;
  }

  /**
   * @description todo
   *
   * @tags Events
   * @name GetEventsByEventKey
   * @summary Get events by event key
   * @request GET:/events/{event_key}
   */
  getEventsByEventKey = (eventKey: string, query?: { start?: string; limit?: number }, params: RequestParams = {}) =>
    this.http.request<Event[], AptosError>({
      path: `/events/${eventKey}`,
      method: 'GET',
      query: query,
      format: 'json',
      ...params,
    });
}
