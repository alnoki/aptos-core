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

import { HttpClient, RequestParams } from './http-client';

export class Spec<SecurityDataType = unknown> {
  http: HttpClient<SecurityDataType>;

  constructor(http: HttpClient<SecurityDataType>) {
    this.http = http;
  }

  /**
   * @description Provides a UI that you can use to explore the API. You can also retrieve the API directly at `/openapi.yaml` and `/openapi.json`.
   *
   * @tags General
   * @name Openapi
   * @summary Show OpenAPI explorer
   * @request GET:/spec
   */
  openapi = (params: RequestParams = {}) =>
    this.http.request<string, any>({
      path: `/spec`,
      method: 'GET',
      ...params,
    });
}
