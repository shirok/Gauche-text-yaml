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
  (.include <gauche/extend.h>)

  (define-ctype YamlParser
    ::(.struct (alive::_Bool
                parser::yaml_parser_t))))

 (define-cstruct <yaml-parser> "YamlParser"
   ())                                  ;no publicly accessible slot
 )


;;

(define-cfn yaml-parser-fini (p::YamlParser*) ::void :static
  (when (-> p alive)
    (set! (-> p alive) FALSE)
    (yaml_parser_delete (& (-> p parser)))))

(define-cfn yaml-parser-finalize (obj _::void*) ::void :static
  (when (SCM_YAML_PARSER_P obj)
    (yaml-parser-fini (SCM_YAML_PARSER obj))))

(define-cproc make-yaml-parser ()
  (let* ([z::Scm_yaml_parser_Rec* (SCM_NEW Scm_yaml_parser_Rec)])
    (yaml_parser_initialize (& (ref (-> z data) parser)))
    (set! (ref (-> z data) alive) TRUE)
    (Scm_RegisterFinalizer (SCM_OBJ z) yaml-parser-finalize NULL)
    (return (SCM_OBJ z))))

(define-cproc yaml-parser-delete (p::<yaml-parser>)
  (yaml-parser-fini p))



;; Local variables:
;; mode: scheme
;; end:
