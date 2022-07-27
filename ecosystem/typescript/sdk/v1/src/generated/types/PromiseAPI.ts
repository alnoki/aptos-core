import { ResponseContext, RequestContext, HttpFile } from '../http/http';
import * as models from '../models/all';
import { Configuration} from '../configuration'

import { AccountData } from '../models/AccountData';
import { IndexResponse } from '../models/IndexResponse';
import { RoleType } from '../models/RoleType';
import { ObservableGeneralApi } from './ObservableAPI';

import { GeneralApiRequestFactory, GeneralApiResponseProcessor} from "../apis/GeneralApi";
export class PromiseGeneralApi {
    private api: ObservableGeneralApi

    public constructor(
        configuration: Configuration,
        requestFactory?: GeneralApiRequestFactory,
        responseProcessor?: GeneralApiResponseProcessor
    ) {
        this.api = new ObservableGeneralApi(configuration, requestFactory, responseProcessor);
    }

    /**
     * Return high level information about an account such as its sequence number.
     * get_account
     * @param address 
     * @param ledgerVersion 
     */
    public getAccount(address: string, ledgerVersion?: number, _options?: Configuration): Promise<AccountData> {
        const result = this.api.getAccount(address, ledgerVersion, _options);
        return result.toPromise();
    }

    /**
     * Get the latest ledger information, including data such as chain ID, role type, ledger versions, epoch, etc.
     * Get ledger info
     */
    public getLedgerInfo(_options?: Configuration): Promise<IndexResponse> {
        const result = this.api.getLedgerInfo(_options);
        return result.toPromise();
    }

    /**
     * Provides a UI that you can use to explore the API. You can also retrieve the API directly at `/openapi.yaml` and `/openapi.json`.
     * Show OpenAPI explorer
     */
    public openapi(_options?: Configuration): Promise<string> {
        const result = this.api.openapi(_options);
        return result.toPromise();
    }


}



