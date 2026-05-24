# Clean Core readiness matrix

Per-object audit of whether each utility is usable in **ABAP for Cloud
Development** (the Clean Core language scope), which exact API/statement blocks
the ⚠️/❌ ones, and the **released replacement** to use in the cloud.

> ✅ uses only released APIs / cloud-enabled language (to the best of our
> knowledge). ⚠️ release state must be confirmed / has a documented cloud
> alternative. ❌ no cloud equivalent (SAP GUI / classic statements).
>
> **This matrix is a best-effort static audit. The authoritative check is ATC
> with the `CLOUD_READINESS` variant on your target system** (abaplint cannot
> resolve the SAP released-API classification offline). See
> [Clean Core & ATC Cookbook](clean-core-atc-cookbook.md).

## Cloud-safe set (install these on BTP ABAP / ABAP Cloud)

| Module | Object | Uses (released) |
|--------|--------|-----------------|
| error   | `ZCX_AU_ERROR` | `cx_static_check`, `if_t100_message`, `MESSAGE … INTO` |
| string  | `ZCL_AU_STRING` | pure string built-ins, `alpha` formatting |
| date    | `ZCL_AU_DATE` | date arithmetic, `GET/CONVERT TIME STAMP` (key date now explicit — no `sy-datum`) |
| number  | `ZCL_AU_NUMBER` | `round( )`, `cl_abap_math`, string templates |
| guid    | `ZCL_AU_GUID` | `cl_system_uuid` |
| csv     | `ZCL_AU_CSV` | RTTI, `cl_abap_char_utilities` (newline/cr_lf are released) |
| itab    | `ZCL_AU_ITAB` | `SORT`/`DELETE ADJACENT`/`CREATE DATA` |
| message | `ZCL_AU_MESSAGE` | `MESSAGE … INTO`, `BAPIRET2`; `*_from_sy` read `sy-msg*` (set by `MESSAGE`) |
| context | `ZCL_AU_CONTEXT` | `cl_abap_context_info` (the released sy-field replacement) |
| base64  | `ZCL_AU_BASE64` | `cl_web_http_utility`, `cl_abap_conv_codepage` |
| http    | `ZCL_AU_HTTP` | `cl_http_destination_provider`, `cl_web_http_client_manager` |
| rap     | `ZCL_AU_RAP_MSG` | `cl_abap_behv`, `if_abap_behv_message` |
| clock   | `ZIF_AU_CLOCK`/`ZCL_AU_CLOCK` | `GET/CONVERT TIME STAMP` |
| guard   | `ZCL_AU_GUARD` | language only |
| featureflag | `ZIF_AU_FEATURE_FLAG`/`ZCL_AU_FEATURE_FLAG` | language only (hashed table) |
| dynsql  | `ZCL_AU_DYN_SQL` | `cl_abap_dyn_prg` (released sanitizer) |
| docgen  | `ZCL_AU_DOCGEN` | RTTI (`cl_abap_typedescr`) — **the class only** |
| fiori   | `ZCL_AU_FIORI_GEN` | RTTI + string building (emits CDS/RAP/SRVD source) |
| wrapper | `ZCL_AU_WRAP_GEN` | string building (emits a released facade class) |
| export  | `ZCL_AU_ANALYTICS_GEN` | string building (emits OData/analytics/extraction CDS) |
| test    | `ZCL_AU_TEST_DATA` | `cl_abap_random*` |

## Confirm-before-cloud / has a documented alternative (⚠️)

| Module | Blocking API | Released replacement |
|--------|--------------|----------------------|
| json    | `/UI2/CL_JSON` | `xco_cp_json` or [ajson](https://github.com/sbcgua/ajson) |
| logger  | BAL FMs + `sy-uname`/`sy-cprog` | `cl_bali_log` / [ABAP Logger](https://github.com/ABAP-Logger/ABAP-Logger) |
| email   | `cl_bcs` | `cl_bcs_mail` |
| numrange| `NUMBER_GET_NEXT` | `cl_numberrange_runtime=>number_get( )` |
| hash    | `cl_abap_message_digest` | `XCO_CP` hashing / `cl_abap_hmac` |
| zip     | `cl_abap_zip` | `XCO_CP` archive APIs |
| config  | `SELECT` on `TVARVC` | custom released CDS/custom entity, or config apps |
| lock    | generic `ENQUEUE`/`DEQUEUE` | a lock object's released `ENQUEUE_*`/`DEQUEUE_*` |
| retry   | `WAIT UP TO n SECONDS` | call with `iv_wait_seconds = 0`, or RAP async patterns |
| timer   | `cl_abap_runtime` (release state unconfirmed) | diff two `GET TIME STAMP` values / `ZIF_AU_CLOCK` |
| profiler | `GET RUN TIME` in start/stop (`record`/`report` are cloud-safe) | time steps with `CL_ABAP_RUNTIME`/timestamps and call `record( )` |
| text    | `READ_TEXT`/`SAVE_TEXT` + `sy-langu` default | model long text as a released entity (object-specific) |
| fiori (`ZCL_AU_FIORI_FROM_ALV`) | LVC field-catalog type | on cloud seed fields with `ZCL_AU_FIORI_GEN=>fields_from_structure` |

## On-premise / SAP GUI only (❌)

| Module | Blocking | Cloud direction |
|--------|----------|-----------------|
| alv     | `cl_salv_table` full-screen, GUI events, `sy-repid` | CDS + RAP + Fiori Elements |
| dataset | `OPEN DATASET` | exchange files via OData/HTTP or released file APIs |
| docgen (report `ZAU_DOCGEN`) | selection screen + `cl_demo_output` | call the **class** `ZCL_AU_DOCGEN` from cloud-safe code |

## How to install only the cloud-safe set
abapGit pulls the whole repository, but because every utility is its own
sub-package you can simply **not activate / not transport** the ⚠️/❌ folders, or
copy only the cloud-safe folders listed above. Each cloud-safe module has **no**
dependency beyond `ZCX_AU_ERROR` (also cloud-safe).

> Want a single switch? Add a second `.abapgit.xml` whose `STARTING_FOLDER`/IGNORE
> excludes the on-premise folders, and point a separate abapGit repo at it for
> your cloud system (see [ARCHITECTURE.md](../ARCHITECTURE.md)).
