import { ResponseContext, RequestContext, HttpFile } from '../http/http';
import * as models from '../models/all';
import { Configuration} from '../configuration'
import { Observable, of, from } from '../rxjsStub';
import {mergeMap, map} from  '../rxjsStub';
import { AccountData } from '../models/AccountData';
import { IndexResponse } from '../models/IndexResponse';
import { RoleType } from '../models/RoleType';

import { GeneralApiRequestFactory, GeneralApiResponseProcessor} from "../apis/GeneralApi";
export class ObservableGeneralApi {
    private requestFactory: GeneralApiRequestFactory;
    private responseProcessor: GeneralApiResponseProcessor;
    private configuration: Configuration;

    public constructor(
        configuration: Configuration,
        requestFactory?: GeneralApiRequestFactory,
        responseProcessor?: GeneralApiResponseProcessor
    ) {
        this.configuration = configuration;
        this.requestFactory = requestFactory || new GeneralApiRequestFactory(configuration);
        this.responseProcessor = responseProcessor || new GeneralApiResponseProcessor();
    }

    /**
     * Return high level information about an account such as its sequence number.
     * get_account
     * @param address 
     * @param ledgerVersion 
     */
    public getAccount(address: string, ledgerVersion?: number, _options?: Configuration): Observable<AccountData> {
        const requestContextPromise = this.requestFactory.getAccount(address, ledgerVersion, _options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.getAccount(rsp)));
            }));
    }

    /**
     * Get the latest ledger information, including data such as chain ID, role type, ledger versions, epoch, etc.
     * Get ledger info
     */
    public getLedgerInfo(_options?: Configuration): Observable<IndexResponse> {
        const requestContextPromise = this.requestFactory.getLedgerInfo(_options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.getLedgerInfo(rsp)));
            }));
    }

    /**
     * Provides a UI that you can use to explore the API. You can also retrieve the API directly at `/openapi.yaml` and `/openapi.json`.
     * Show OpenAPI explorer
     */
    public openapi(_options?: Configuration): Observable<string> {
        const requestContextPromise = this.requestFactory.openapi(_options);

        // build promise chain
        let middlewarePreObservable = from<RequestContext>(requestContextPromise);
        for (let middleware of this.configuration.middleware) {
            middlewarePreObservable = middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => middleware.pre(ctx)));
        }

        return middlewarePreObservable.pipe(mergeMap((ctx: RequestContext) => this.configuration.httpApi.send(ctx))).
            pipe(mergeMap((response: ResponseContext) => {
                let middlewarePostObservable = of(response);
                for (let middleware of this.configuration.middleware) {
                    middlewarePostObservable = middlewarePostObservable.pipe(mergeMap((rsp: ResponseContext) => middleware.post(rsp)));
                }
                return middlewarePostObservable.pipe(map((rsp: ResponseContext) => this.responseProcessor.openapi(rsp)));
            }));
    }

}
