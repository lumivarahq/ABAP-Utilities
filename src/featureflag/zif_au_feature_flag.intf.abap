interface zif_au_feature_flag
  public.

  "! Feature-toggle abstraction so that "deploy" and "release" are decoupled:
  "! code ships dark and is switched on by configuration, not a transport.
  "! Depend on this interface and inject it; in tests inject a fixed set.
  "! (cf. Martin Fowler's Feature Toggles.)
  methods is_enabled
    importing
      !iv_feature       type csequence
    returning
      value(rv_enabled) type abap_bool.

endinterface.
