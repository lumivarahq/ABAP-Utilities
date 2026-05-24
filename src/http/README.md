# HTTP / REST — `ZCL_AU_HTTP`

> Call an external REST API in one line, using the modern, cloud-ready
> `IF_WEB_HTTP_CLIENT` stack.

## Objects & dependencies
- `ZCL_AU_HTTP` — stateless utility (`class-methods`).
- Depends on: **`ZCX_AU_ERROR`** ([error](../error/README.md) module). Uses the
  released `CL_HTTP_DESTINATION_PROVIDER` + `CL_WEB_HTTP_CLIENT_MANAGER`
  → **ABAP Cloud / clean core safe**.

> ℹ️ Outbound calls require the target host to be reachable and trusted: in
> on-premise add the certificate to `STRUST`; in ABAP Cloud create a
> **communication arrangement / destination** and prefer
> `create_by_comm_arrangement( )` over a raw URL.

## Install (cherry-pick)
1. Copy the [error](../error/README.md) module (`ZCX_AU_ERROR`).
2. Copy `src/http/zcl_au_http.clas.abap` (+ `.clas.xml`).
3. Assign both objects to your TR.

## How to use

```abap
" GET
data(ls_resp) = zcl_au_http=>get( `https://api.example.com/v1/ping` ).
if ls_resp-code = 200.
  ... ls_resp-body ...
endif.

" POST JSON
data(lv_json) = zcl_au_json=>serialize( ls_payload ).
data(ls_post) = zcl_au_http=>post(
  iv_url     = `https://api.example.com/v1/orders`
  iv_body    = lv_json
  it_headers = value #( ( name = `Content-Type`  value = `application/json` )
                        ( name = `Authorization` value = |Bearer { lv_token }| ) ) ).

" Any verb
data(ls_del) = zcl_au_http=>request( iv_url    = lv_url
                                     iv_method = 'DELETE' ).
```

## API
| Method | Purpose |
|--------|---------|
| `get( iv_url, it_headers )` | HTTP GET |
| `post( iv_url, iv_body, it_headers )` | HTTP POST |
| `request( iv_url, iv_method, iv_body, it_headers )` | any verb (GET/POST/PUT/DELETE/PATCH) |

Returns `ty_response` = `code` (int), `reason`, `body` (string). Transport/SSL
errors are wrapped in `ZCX_AU_ERROR`.

## Tests
Network calls aren't suitable for plain ABAP Unit. Test callers by injecting a
test double of your own client interface, or use a local mock service.

## Extending
Add timeout / retry handling, automatic JSON (de)serialization via
[`ZCL_AU_JSON`](../json/README.md), OAuth token handling, or a destination-based
overload (`create_by_comm_arrangement`, `create_by_cloud_destination`).
