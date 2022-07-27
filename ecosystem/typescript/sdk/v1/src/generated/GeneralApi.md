# .GeneralApi

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAccount**](GeneralApi.md#getAccount) | **GET** /accounts/{address} | get_account
[**getLedgerInfo**](GeneralApi.md#getLedgerInfo) | **GET** / | Get ledger info
[**openapi**](GeneralApi.md#openapi) | **GET** /openapi | Show OpenAPI explorer


# **getAccount**
> AccountData getAccount()

Return high level information about an account such as its sequence number.

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .GeneralApi(configuration);

let body:.GeneralApiGetAccountRequest = {
  // string
  address: "address_example",
  // number (optional)
  ledgerVersion: 1,
};

apiInstance.getAccount(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **address** | [**string**] |  | defaults to undefined
 **ledgerVersion** | [**number**] |  | (optional) defaults to undefined


### Return type

**AccountData**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/octet-stream


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **getLedgerInfo**
> IndexResponse getLedgerInfo()

Get the latest ledger information, including data such as chain ID, role type, ledger versions, epoch, etc.

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .GeneralApi(configuration);

let body:any = {};

apiInstance.getLedgerInfo(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters
This endpoint does not need any parameter.


### Return type

**IndexResponse**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json, application/x-bcs


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)

# **openapi**
> string openapi()

Provides a UI that you can use to explore the API. You can also retrieve the API directly at `/openapi.yaml` and `/openapi.json`.

### Example


```typescript
import {  } from '';
import * as fs from 'fs';

const configuration = .createConfiguration();
const apiInstance = new .GeneralApi(configuration);

let body:any = {};

apiInstance.openapi(body).then((data:any) => {
  console.log('API called successfully. Returned data: ' + data);
}).catch((error:any) => console.error(error));
```


### Parameters
This endpoint does not need any parameter.


### Return type

**string**

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/html


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
**200** |  |  -  |

[[Back to top]](#) [[Back to API list]](README.md#documentation-for-api-endpoints) [[Back to Model list]](README.md#documentation-for-models) [[Back to README]](README.md)


