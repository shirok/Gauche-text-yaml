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

 ;; Enums

 (define-cenum <yaml-event-type> "yaml_event_type_t"
   (YAML_NO_EVENT
    YAML_STREAM_START_EVENT
    YAML_STREAM_END_EVENT
    YAML_DOCUMENT_START_EVENT
    YAML_DOCUMENT_END_EVENT
    YAML_ALIAS_EVENT
    YAML_SCALAR_EVENT
    YAML_SEQUENCE_START_EVENT
    YAML_SEQUENCE_END_EVENT
    YAML_MAPPING_START_EVENT
    YAML_MAPPING_END_EVENT))

 (define-cenum <yaml-encoding> "yaml_encoding_t"
   (YAML_ANY_ENCODING
    YAML_UTF8_ENCODING
    YAML_UTF16LE_ENCODING
    YAML_UTF16BE_ENCODING))

 (define-cenum <yaml-break> "yaml_break_t"
   (YAML_ANY_BREAK
    YAML_CR_BREAK
    YAML_LN_BREAK
    YAML_CRLN_BREAK))

 (define-cenum <yaml-scalar-style> "yaml_scalar_style_t"
   (YAML_ANY_SCALAR_STYLE
    YAML_PLAIN_SCALAR_STYLE
    YAML_SINGLE_QUOTED_SCALAR_STYLE
    YAML_DOUBLE_QUOTED_SCALAR_STYLE
    YAML_LITERAL_SCALAR_STYLE
    YAML_FOLDED_SCALAR_STYLE))

 (define-cenum <yaml-sequence-style> "yaml_sequence_style_t"
   (YAML_ANY_SEQUENCE_STYLE
    YAML_BLOCK_SEQUENCE_STYLE
    YAML_FLOW_SEQUENCE_STYLE))

 (define-cenum <yaml-mapping-style> "yaml_mapping_style_t"
   (YAML_ANY_MAPPING_STYLE
    YAML_BLOCK_MAPPING_STYLE
    YAML_FLOW_MAPPING_STYLE))

 (define-cenum <yaml-token-type> "yaml_token_type_t"
   (YAML_NO_TOKEN
    YAML_STREAM_START_TOKEN
    YAML_STREAM_END_TOKEN
    YAML_VERSION_DIRECTIVE_TOKEN
    YAML_TAG_DIRECTIVE_TOKEN
    YAML_DOCUMENT_START_TOKEN
    YAML_DOCUMENT_END_TOKEN
    YAML_BLOCK_SEQUENCE_START_TOKEN
    YAML_BLOCK_MAPPING_START_TOKEN
    YAML_BLOCK_END_TOKEN
    YAML_FLOW_SEQUENCE_START_TOKEN
    YAML_FLOW_SEQUENCE_END_TOKEN
    YAML_FLOW_MAPPING_START_TOKEN
    YAML_FLOW_MAPPING_END_TOKEN
    YAML_BLOCK_ENTRY_TOKEN
    YAML_FLOW_ENTRY_TOKEN
    YAML_KEY_TOKEN
    YAML_VALUE_TOKEN
    YAML_ALIAS_TOKEN
    YAML_ANCHOR_TOKEN
    YAML_TAG_TOKEN
    YAML_SCALAR_TOKEN))

 ;;
 ;; <yaml-mark>
 ;;
 (define-cstruct <yaml-mark> "yaml_mark_t"
   (index::<size_t>
    line::<size_t>
    column::<size_t>))

 ;;
 ;; <yaml-token>
 ;;
 (define-cclass <yaml-token> :base :private
   "yaml_token_t*" "YamlTokenClass" ()
   ((type :type <yaml-token-type>)))

 ;;
 ;; <yaml-parser>
 ;;
 (declcode
  (define-ctype YamlParser
    ::(.struct (alive::_Bool
                parser::yaml_parser_t)))
  )

 (define-cstruct <yaml-parser> "YamlParser"
   ())                                  ;no publicly accessible slot

 ;;
 ;; <yaml-event>
 ;;
 ;; We show each type of yaml_event as a separate subclass in Scheme world.
 ;;

 (define-cclass <yaml-event> :base :private
   "yaml_event_t*" "YamlEventClass" ()
   ((type       :type <yaml-event-type>)
    (start-mark :type <yaml-mark>
                :getter "return Scm_Make_yaml_mark(&obj->start_mark);"
                :setter #f)
    (end-mark   :type <yaml-mark>
                :getter "return Scm_Make_yaml_mark(&obj->end_mark);"
                :setter #f)))

 (define-cclass <yaml-stream-start-event> :private
   "yaml_event_t*" "YamlStreamStartEventClass" (YamlEventClass)
   ((enoding :type <yaml-encoding>
             :c-name "data.stream_start.encoding")))

 (define-cclass <yaml-stream-end-event> :private
   "yaml_event_t*" "YamlStreamEndEventClass" (YamlEventClass)
   ())

 (define-cclass <yaml-document-start-event> :private
   "yaml_event_t*" "YamlDocumentStartClass" (YamlEventClass)
   ((version-minor :type <int>
                   :c-name "data.document_start.version_directive->minor")
    (version-major :type <int>
                   :c-name "data.document_start.version_directive->major")
    ))
 )


;;

(define-cfn yaml-parser-fini (p::YamlParser*) ::void :static
  (when (-> p alive)
    (set! (-> p alive) FALSE)
    (yaml_parser_delete (& (-> p parser)))))

(define-cfn yaml-parser-finalize (obj _::void*) ::void :static
  (when (SCM_YAML_PARSER_P obj)
    (yaml-parser-fini (SCM_YAML_PARSER obj))))

;; API
(define-cproc make-yaml-parser ()
  (let* ([z::Scm_yaml_parser_Rec* (SCM_NEW Scm_yaml_parser_Rec)])
    (yaml_parser_initialize (& (ref (-> z data) parser)))
    (set! (ref (-> z data) alive) TRUE)
    (Scm_RegisterFinalizer (SCM_OBJ z) yaml-parser-finalize NULL)
    (return (SCM_OBJ z))))

;; API
(define-cproc yaml-parser-delete (p::<yaml-parser>)
  (yaml-parser-fini p))

;; Canonical handler
;; NB: It is supposed to return 0 on error.  In our case, Scm_Getz
;; throws a Scheme error so this one never returns 0.  Should we
;; capture Scheme error here and return 0?
(define-cfn yaml-read-handler (data::void* ; ScmPort*
                               buffer::u_char* ; buffer to write out
                               size::size_t   ; buffer size
                               size_read::size_t*) ;actual bytes read
  ::int :static
  (let* ([r::ScmSize (Scm_Getz (cast char* buffer) size
                               (SCM_PORT data))])
    (cond [(== r EOF) (set! (* size_read) 0)]
          [else (set! (* size_read) r)])
    (return 1)))

;; API
(define-cproc yaml-parser-set-input (p::<yaml-parser> in::<port>) ::<void>
  (yaml_parser_set_input (& (-> p parser))
                         yaml-read-handler
                         (cast void* in)))

;; API
(define-cproc yaml-parser-set-encoding (p::<yaml-parser>
                                        encoding::<yaml-encoding>)
  ::<void>
  (yaml_parser_set_encoding (& (-> p parser)) encoding))

;; Local variables:
;; mode: scheme
;; end:
