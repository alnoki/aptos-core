import { ResponseContext, RequestContext, HttpFile } from '../http/http';
import * as models from '../models/all';
import { Configuration} from '../configuration'

import { AccountData } from '../models/AccountData';
import { IndexResponse } from '../models/IndexResponse';
import { RoleType } from '../models/RoleType';

import { ObservableGeneralApi } from "./ObservableAPI";
import { GeneralApiRequestFactory, GeneralApiResponseProcessor} from "../apis/GeneralApi";

export interface GeneralApiGetAccountRequest {
    /**
     * 
     * @type string
     * @memberof GeneralApigetAccount
     */
    address: string
    /**
     * 
     * @type number
     * @memberof GeneralApigetAccount
     */
    ledgerVersion?: number
}

export interface GeneralApiGetLedgerInfoRequest {
}

export interface GeneralApiOpenapiRequest {
}

export class ObjectGeneralApi {
    private api: ObservableGeneralApi

    public constructor(configuration: Configuration, requestFactory?: GeneralApiRequestFactory, responseProcessor?: GeneralApiResponseProcessor) {
        this.api = new ObservableGeneralApi(configuration, requestFactory, responseProcessor);
    }

    /**
     * Return high level information about an account such as its sequence number.
     * get_account
     * @param param the request object
     */
    public getAccount(param: GeneralApiGetAccountRequest, options?: Configuration): Promise<AccountData> {
        return this.api.getAccount(param.address, param.ledgerVersion,  options).toPromise();
    }

    /**
     * Get the latest ledger information, including data such as chain ID, role type, ledger versions, epoch, etc.
     * Get ledger info
     * @param param the request object
     */
    public getLedgerInfo(param: GeneralApiGetLedgerInfoRequest = {}, options?: Configuration): Promise<IndexResponse> {
        return this.api.getLedgerInfo( options).toPromise();
    }

    /**
     * Provides a UI that you can use to explore the API. You can also retrieve the API directly at `/openapi.yaml` and `/openapi.json`.
     * Show OpenAPI explorer
     * @param param the request object
     */
    public openapi(param: GeneralApiOpenapiRequest = {}, options?: Configuration): Promise<string> {
        return this.api.openapi( options).toPromise();
    }

}
