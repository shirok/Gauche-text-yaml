;;;
;;;  LibYAML binding for Gauche
;;;

(define-module text.yaml
  (use gauche.native-type)
  (use gauche.ffi)
  (export yaml-get-version-string
          yaml-get-version)
  )
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

 (define-cenum <yaml_node_type> "yaml_node_type_t"
   (YAML_NO_NODE
    YAML_SCALAR_NODE
    YAML_SEQUENCE_NODE
    YAML_MAPPING_NODE))
 )

(define yaml_char_t <uint8>)
(define yaml_char_t* (make-c-pointer-type yaml_char_t))

(define yaml_version_directive_t
  (native-type '(.struct yaml_version_directive_s
                         (major::int
                          minor::int))))

(define yaml_tag_directive_t
  (native-type `(.struct yaml_tag_directive_s
                         (handle::,yaml_char_t*
                          prefix::,yaml_char_t*))))

(define yaml_mark_t
  (native-type `(.struct yaml_mark_s
                         (index::size_t
                          line::size_t
                          column::size_t))))


(define yaml_encoding_t <int>)          ;enum
(define yaml_char_style_t <int>)        ;enum
(define yaml_scalar_style_t <int>)      ;enum
(define yaml_sequence_style_t <int>)    ;enum
(define yaml_mapping_style_t <int>)     ;enum
(define yaml_node_type_t <int>)         ;enum
(define yaml_node_item_t <int>)

(define yaml_token_t
  (native-type
   `(.struct
     yaml_token_s
     (data::(.union
             (stream_start::(.struct (encoding::,yaml_encoding_t))
              alias       ::(.struct (value::,yaml_char_t*))
              anchor      ::(.struct (value::,yaml_char_t*))
              tag         ::(.struct (handle::,yaml_char_t
                                      suffix::,yaml_char_t*))
              scalar      ::(.struct (value::,yaml_char_t*
                                      length::size_t
                                      style::,yaml_char_style_t))
              version_directiev::(.struct (major::int
                                           minor::int))
              tag_directive::(.struct (handle::,yaml_char_t*
                                       prefix::,yaml_char_t*))))
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))

(define yaml_event_t
  (native-type
   `(.struct
     yaml_event_s
     (data::(.union
             (stream_start::(.struct (encoding::,yaml_encoding_t))
              document_start::(.struct
                               (version_directive::(,yaml_version_directive_t *)
                                tag_directives::(.struct
                                                 (start::(,yaml_tag_directive_t *)
                                                  end::(,yaml_tag_directive_t *)))
                                implicit::int))
              docuemnt_end::(.struct (implicit::int))
              alias::(.struct (anchor::,yaml_char_t*))
              scalar::(.struct
                       (anchor::,yaml_char_t*
                        tag::,yaml_char_t*
                        value::,yaml_char_t*
                        length::size_t
                        plain_implicit::int
                        quoted_implicit::int
                        style::,yaml_scalar_style_t))
              sequence_start::(.struct
                               (anchor::,yaml_char_t*
                                tag::,yaml_char_t*
                                implicit::int
                                style::,yaml_sequence_style_t))
              mapping_start::(.struct
                              (anchor::,yaml_char_t*
                               tag::,yaml_char_t*
                               implicit::int
                               style::,yaml_mapping_style_t))))
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))

(define yaml_node_pair_t
  (native-type
   `(.struct yaml_node_pair_s (key::int value::int))))

(define yaml_node_t
  (native-type
   `(.struct
     yaml_node_s
     (type::,yaml_node_type_t
      tag::,yaml_char_t*
      data::(.union
             (scalar::(.struct (value::,yaml_char_t*
                                length::size_t
                                style::,yaml_scalar_style_t))
              sequence::(.struct (start::(,yaml_node_item_t *)
                                  end::(,yaml_node_item_t *)
                                  top::(,yaml_node_item_t *)))
              mapping::(.struct (pairs::(.struct
                                         (start::(,yaml_node_pair_t *)
                                          end::(,yaml_node_pair_t *)
                                          top::(,yaml_node_pair_t *)))
                                 style::,yaml_mapping_style_t))))
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))

(define yaml_document_t
  (native-type
   `(.struct
     yaml_document_s
     (nodes::(.struct (start::(,yaml_node_t *)
                       end::(,yaml_node_t *)
                       top::(,yaml_node_t *)))
      version_directive::(,yaml_version_directive_t *)
      tag_directives::(.struct (start::(,yaml_tag_directive_t *)
                                end::(,yaml_tag_directive_t *)))
      start_implicit::int
      end_implicit::int
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))

(with-ffi (dlopen "libyaml") ()
  ;; Version Information
  (define-c-function yaml-get-version-string '() <c-string>)
  (define-c-function %yaml-get-version '(int* int* int*) <void>)

  (define-c-function %yaml-token-delete `((,yaml_token_t *)) <void>)

  (define-c-function %yaml-stream-start-event-initialize
    `((,yaml_event_t *) ,yaml_encoding_t) <int>)
  (define-c-function %yaml-stream-end-event-initialize
    `((,yaml_event_t *)) <int>)
  (define-c-function %yaml-document-start-event-initialize
    `((,yaml_event_t *)
      (,yaml_version_directive_t *)
      (,yaml_tag_directive_t *)
      (,yaml_tag_directive_t *)
      int) <int>)
  (define-c-function %yaml-document-end-event-initialize
    `((,yaml_event_t *)) <int>)
  (define-c-function %yaml-alias-event-initialize
    `((,yaml_event_t *) (const ,yaml_char_t *)) <int>)
  (define-c-function %yaml-scalar-event-initialize
    `((,yaml_event_t *)
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int int int ,yaml_scalar_style_t) <int>)
  (define-c-function %yaml-sequence-start-event-initialize
    `((,yaml_event_t *)
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int ,yaml_sequence_style_t) <int>)
  (define-c-function %yaml-sequence-end-event-initialize
    `((,yaml_event_t *)) <int>)
  (define-c-function %yaml-mapping-start-event-initialize
    `((,yaml_event_t *)
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int ,yaml_sequence_style_t) <int>)
  (define-c-function %yaml-mapping-end-event-initialize
    `((,yaml_event_t *)) <int>)
  (define-c-function %yaml-event-delete
    `((,yaml_event_t *)) <void>)
  )

(define (yaml-get-version)
  (let1 buf (make-native-handle (native-type '(.array int (3))))
    (%yaml-get-version buf
                       (native-pointer+ buf 1)
                       (native-pointer+ buf 2))
    (list (native-aref buf 0) (native-aref buf 1) (native-aref buf 2))))

;; Local variables:
;; mode: scheme
;; end:
