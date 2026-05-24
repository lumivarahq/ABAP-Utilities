# API Usage Cookbook — released replacements for everyday calls

The most common "Usage of API" findings are calls to objects that are **not
released** for ABAP Cloud / Clean Core. This is a quick lookup of released
replacements, plus the pattern to use when there is no replacement yet.

> Source: [ABAP Extensibility Guide – Clean Core (SAP, 2025)](https://community.sap.com/t5/technology-blog-posts-by-sap/abap-extensibility-guide-clean-core-for-sap-s-4hana-cloud-august-2025/ba-p/14175399)

## How to check if something is released
- In **ADT**: open the object ➜ *Properties / API State* tab ➜ "Released".
- Code completion in an ABAP Cloud project only offers released objects.
- ATC check **"Usage of released APIs"** flags the rest.

## Released replacements (cheat sheet)

| Classic / not released | Released replacement |
|------------------------|----------------------|
| `sy-uname`, `sy-datum`, `sy-langu` | `cl_abap_context_info=>get_user_technical_name/ get_system_date/ get_user_language` |
| `GUI_UPLOAD` / `GUI_DOWNLOAD`, `cl_gui_frontend_services` | (cloud) Fiori upload/download via OData; (file) `cl_abap_file_utilities` / app-server I/O |
| `/UI2/CL_JSON` | `xco_cp_json` (XCO) or [ajson](https://github.com/sbcgua/ajson) |
| `cl_bcs` (email) | `cl_bcs_mail` |
| `NUMBER_GET_NEXT` | `cl_numberrange_runtime=>number_get( )` |
| `cl_salv_table` full screen | CDS + RAP + Fiori Elements |
| `BAL_LOG_*` FMs | `cl_bali_log` / released Application Log API |
| `GUID_CREATE` / `SYSTEM_UUID*` FMs | `cl_system_uuid` (see `ZCL_AU_GUID`) |
| classic `CALL TRANSFORMATION` to GUI | `xco_cp_json` / `cl_sxml_*` |
| `cl_http_client` (by destination string) | `cl_http_destination_provider` + `cl_web_http_client_manager` (see `ZCL_AU_HTTP`) |
| `CONVERT_OTF` / SAPscript print | Adobe Forms / released output management |
| code page conversion FMs | `cl_abap_conv_codepage=>create_in/out( )` |

## When there is no released replacement: the wrapper pattern
Clean Core's official guidance — isolate the non-released call behind a small
released facade in your namespace, so only one object needs an exemption:

```abap
"! Released facade around a non-released capability.
class zcl_legacy_facade definition public final create public.
  public section.
    class-methods do_it importing iv_in type ... returning value(rv) type ... .
endclass.
class zcl_legacy_facade implementation.
  method do_it.
    " the single, ATC-exempted call lives here only
    call function 'SOME_UNRELEASED_FM' ... .
  endmethod.
endclass.
```
Benefits: one exemption instead of many; swappable when SAP releases an API;
unit-testable (mock the facade interface).

## Escaping & safety (frequent correctness findings)
- Dynamic ABAP SQL: use host variables `@lv_x` and `cl_abap_dyn_prg=>...` to
  sanitise dynamic WHERE/column names — never concatenate user input into SQL.
- Open SQL `IN @itab` instead of building `for all entries` where possible.
- `cl_abap_conv_codepage` for byte/string conversion (replaces obsolete
  `SCMS_*` / `SX_OBJECT_CONVERT_*`).
