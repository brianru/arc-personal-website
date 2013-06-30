; Oauth 2.0 library
; 
; ---------------------------------------------------------------------------------
;    layers        || vocabulary
; =================================================================================
;    resources     || authurl, authcreds, authtoken, targeturl, targetvalue(cached)
; ---------------------------------------------------------------------------------
;    parsers       || token, username, password, json objects
; ---------------------------------------------------------------------------------
;    http requests || get, post
; ---------------------------------------------------------------------------------


(require "lib/web.arc")

(deftem resource auth-endpoint nil
                 auth-user nil
                 auth-token (request-token auth-endpoint auth-creds)
                 value-endpoint nil
                 value (request-value value-endpoint auth-token auth-creds)) ;memoized

; am I thinking about this the right way?
; funcitonal programming means all functions should be idempotent, right?
; what does this mean for maintaining state?

;these are destructive, they update rsrc!auth-token 
(def activate-resource (rsrc)
  (do 
    (aif (no rsrc!auth-token) ;does this work?
      (set it (request-token rsrc)))
    (set rsrc!value (retrieve-resource rsrc))))

(def deactivate-resource (r) ____)

(def retrieve-resource (r) ____)

(def statusp (r) ___)

(def astatusp (r) ____) ;anaphoric, use "it" to refer to resource

(def request-token (rsrc) ___)

(def retrieve-value (rsrc)
  (parse-response (get-url (string rsrc!value-endpoint
                                   rsrc!token
                                   "etc"))))

(def parse-response (raw) ___)




