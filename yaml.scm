;;;
;;;  LibYAML binding for Gauche
;;;

(define-module text.yaml
  (export <yaml-parser>
          make-yaml-parser))
(select-module text.yaml)

(inline-stub
 (declcode
  (.include <yaml.h>)
  (.include <gauche/extend.h>))
 (define-cstruct <yaml-parser> "yaml_parser_t"
   ())                                  ;no publicly accessible slot
 )

(define-cproc make-yaml-parser () ::<yaml-parser>
  (let* ([z::yaml_parser_t* (SCM_NEW_ATOMIC yaml_parser_t)])
    (yaml_parser_initialize z)
    (return z)))

;; Local variables:
;; mode: scheme
;; end:
