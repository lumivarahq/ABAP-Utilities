interface zif_au_runnable
  public.

  "! A unit of work that ZCL_AU_RETRY can execute. Implement run( ) with the code
  "! that might transiently fail (an HTTP call, a lock, an RFC). Raise ANY
  "! exception to signal that the attempt failed and should be retried; return
  "! normally to signal success.

  methods run
    raising
      cx_static_check.

endinterface.
