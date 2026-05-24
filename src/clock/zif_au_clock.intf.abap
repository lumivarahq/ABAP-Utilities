interface zif_au_clock
  public.

  "! Abstraction over "the current moment" so that time becomes an injected
  "! dependency instead of a hard-coded call to GET TIME STAMP / sy-datum.
  "!
  "! Why: code that reads the system clock directly is hard to test (you cannot
  "! assert behaviour "at month end" or "after the cut-off") and is flagged by
  "! Clean Core checks (sy-datum). Depend on ZIF_AU_CLOCK, take it in the
  "! constructor, and in unit tests inject ZCL_AU_CLOCK=>fixed( ... ).
  "!
  "! All values are UTC and derived from the same time stamp, so a fixed clock is
  "! fully deterministic. For user-local dates use ZCL_AU_CONTEXT / ZCL_AU_DATE.
  "!
  "! (Equivalent to java.time.Clock / .NET TimeProvider.)

  "! Current moment as a high-resolution UTC time stamp.
  methods now_timestamp
    returning
      value(rv_timestamp) type timestampl.

  "! Current UTC date.
  methods now_date
    returning
      value(rv_date) type d.

  "! Current UTC time.
  methods now_time
    returning
      value(rv_time) type t.

endinterface.
