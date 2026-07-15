;;;
;;;  LibYAML binding for Gauche
;;;

(define-module text.yaml
  (use gauche.native-type)
  (use gauche.ffi)
  (export yaml-get-version-string
          yaml-get-version

          yaml-fini

          <yaml-document>

          <yaml-parser>
          yaml-parser-active?
          yaml-parser-set-input-string
          yaml-parser-load)
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

 (define-cenum <yaml_parser_state> "yaml_parser_state_t"
   (YAML_PARSE_STREAM_START_STATE
    YAML_PARSE_IMPLICIT_DOCUMENT_START_STATE
    YAML_PARSE_DOCUMENT_START_STATE
    YAML_PARSE_DOCUMENT_CONTENT_STATE
    YAML_PARSE_DOCUMENT_END_STATE

    YAML_PARSE_BLOCK_NODE_STATE
    YAML_PARSE_BLOCK_NODE_OR_INDENTLESS_SEQUENCE_STATE
    YAML_PARSE_FLOW_NODE_STATE
    YAML_PARSE_BLOCK_SEQUENCE_FIRST_ENTRY_STATE
    YAML_PARSE_BLOCK_SEQUENCE_ENTRY_STATE

    YAML_PARSE_INDENTLESS_SEQUENCE_ENTRY_STATE
    YAML_PARSE_BLOCK_MAPPING_FIRST_KEY_STATE
    YAML_PARSE_BLOCK_MAPPING_KEY_STATE
    YAML_PARSE_BLOCK_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_SEQUENCE_FIRST_ENTRY_STATE

    YAML_PARSE_FLOW_SEQUENCE_ENTRY_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_KEY_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_END_STATE
    YAML_PARSE_FLOW_MAPPING_FIRST_KEY_STATE

    YAML_PARSE_FLOW_MAPPING_KEY_STATE
    YAML_PARSE_FLOW_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_MAPPING_EMPTY_VALUE_STATE
    YAML_PARSE_END_STATE))

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
(define yaml_error_type_t <int>)        ;enum
(define yaml_parser_state_t <int>)      ;enum

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
(define yaml_token_t* (make-c-pointer-type yaml_token_t))

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
(define yaml_event_t* (make-c-pointer-type yaml_event_t))

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
(define yaml_node_t* (make-c-pointer-type yaml_node_t))

(define yaml_document_t
  (native-type
   `(.struct
     yaml_document_s
     (nodes::(.struct (start::,yaml_node_t*
                       end::,yaml_node_t*
                       top::,yaml_node_t*))
      version_directive::(,yaml_version_directive_t *)
      tag_directives::(.struct (start::(,yaml_tag_directive_t *)
                                end::(,yaml_tag_directive_t *)))
      start_implicit::int
      end_implicit::int
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))
(define yaml_document_t* (make-c-pointer-type yaml_document_t))

(define yaml_read_handler_t
  (native-type
   `(.function (void* (unsigned char*) size_t size_t*) int)))

(define yaml_simple_key_t
  (native-type
   `(.struct
     yaml_simple_key_s
     (possible::int
      required::int
      token_number::size_t
      mark::,yaml_mark_t))))

(define yaml_alias_data_t
  (native-type
   `(.struct
     yaml_alias_data_s
     (anchor::(,yaml_char_t *)
      index::int
      mark::,yaml_mark_t))))

(define FILE <void>) ; Just to tame native-type system

(define yaml_parser_t
  (native-type
   `(.struct
     yaml_parser_s
     (;; Error handling
      error::,yaml_error_type_t
      problem::(const char*)
      problem_offset::size_t
      problem_value::int
      problem_mark::,yaml_mark_t
      context::(const char*)
      context_mark::,yaml_mark_t

      ;; Reader stuff
      read_handler::(,yaml_read_handler_t *)
      read_handler_data::void*
      input::(.union
              (string::(.struct (start::(const unsigned char*)
                                 end::(const unsigned char*)
                                 current::(const unsigned char*)))
               file::(,FILE *)))
      eof::int
      buffer::(.struct
               (start::(,yaml_char_t *)
                end::(,yaml_char_t *)
                pointer::(,yaml_char_t *)
                last::(,yaml_char_t *)))
      unread::size_t
      raw_buffer::(.struct
                   (start::(,yaml_char_t *)
                    end::(,yaml_char_t *)
                    pointer::(,yaml_char_t *)
                    last::(,yaml_char_t *)))
      encoding::,yaml_encoding_t
      offset::size_t
      mark::,yaml_mark_t

      ;; Scanner
      stream_start_produced::int
      stream_end_produced::int
      flow_level::int
      tokens::(.struct
               (start::,yaml_token_t*
                end::,yaml_token_t*
                head::,yaml_token_t*
                tail::,yaml_token_t*))
      tokens_parsed::size_t
      token_available::int
      indents::(.struct (start::int* end::int* top::int*))
      indent::int
      simple_key_allowed::int
      simple_keys::(.struct
                    (start::(,yaml_simple_key_t *)
                     end::(,yaml_simple_key_t *)
                     top::(,yaml_simple_key_t *)))

      ;; Parser
      states::(.struct
               (start::(,yaml_parser_state_t *)
                end::(,yaml_parser_state_t *)
                top::(,yaml_parser_state_t *)))
      state::,yaml_parser_state_t
      marks::(.struct
              (start::(,yaml_mark_t *)
               end::(,yaml_mark_t *)
               top::(,yaml_mark_t *)))
      tag_directives::(.struct
                       (start::(,yaml_tag_directive_t *)
                        end::(,yaml_tag_directive_t *)
                        top::(,yaml_tag_directive_t *)))

      ;; Dumper
      aliases::(.struct
                (start::(,yaml_alias_data_t *)
                 end::(,yaml_alias_data_t *)
                 top::(,yaml_alias_data_t *)))
      document::,yaml_document_t*
      ))))
(define yaml_parser_t* (make-c-pointer-type yaml_parser_t))

(define *libyaml* (dlopen "libyaml"))

;; Many yaml CAPI returns 1 on success, 0 on error.
(define-syntax call-yaml
  (syntax-rules ()
    [(_ fn args ...)
     (let* ((as (list args ...))
            (r (apply fn as)))
       (when (zero? r)
         (errorf "~a failed with args: ~s" 'fn as))
       r)]))

;;;
;;;   Version information
;;;

(with-ffi *libyaml* ()
  (define-c-function yaml-get-version-string '() <c-string>)
  (define-c-function %yaml-get-version '(int* int* int*) <void>)
  )

(define (yaml-get-version)
  (let1 buf (make-native-handle (native-type '(.array int (3))))
    (%yaml-get-version buf
                       (native-pointer+ buf 1)
                       (native-pointer+ buf 2))
    (list (native-aref buf 0) (native-aref buf 1) (native-aref buf 2))))

;;;
;;;  Event
;;;

(with-ffi *libyaml* ()
  ;; Token
  (define-c-function %yaml-token-delete `(,yaml_token_t*) <void>)

  ;; Event
  (define-c-function %yaml-stream-start-event-initialize
    `(,yaml_event_t* ,yaml_encoding_t) <int>)
  (define-c-function %yaml-stream-end-event-initialize
    `(,yaml_event_t*) <int>)
  (define-c-function %yaml-document-start-event-initialize
    `(,yaml_event_t*
      (,yaml_version_directive_t *)
      (,yaml_tag_directive_t *)
      (,yaml_tag_directive_t *)
      int) <int>)
  (define-c-function %yaml-document-end-event-initialize
    `(,yaml_event_t*) <int>)
  (define-c-function %yaml-alias-event-initialize
    `(,yaml_event_t* (const ,yaml_char_t *)) <int>)
  (define-c-function %yaml-scalar-event-initialize
    `(,yaml_event_t*
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int int int ,yaml_scalar_style_t) <int>)
  (define-c-function %yaml-sequence-start-event-initialize
    `(,yaml_event_t*
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int ,yaml_sequence_style_t) <int>)
  (define-c-function %yaml-sequence-end-event-initialize
    `(,yaml_event_t*) <int>)
  (define-c-function %yaml-mapping-start-event-initialize
    `(,yaml_event_t*
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int ,yaml_sequence_style_t) <int>)
  (define-c-function %yaml-mapping-end-event-initialize
    `(,yaml_event_t*) <int>)
  (define-c-function %yaml-event-delete
    `(,yaml_event_t*) <void>)
  )

;;;
;;;  Document
;;;

(with-ffi *libyaml* ()
  (define-c-function %yaml-document-initialize
    `(,yaml_document_t*
      (,yaml_version_directive_t *)
      (,yaml_tag_directive_t *)
      (,yaml_tag_directive_t *)
      int int) <int>)
  (define-c-function %yaml-document-delete `(,yaml_document_t*) <void>)

  (define-c-function %yaml-document-get-node
    `(,yaml_document_t* int)
    `,yaml_node_t*)
  (define-c-function %yaml-document-add-scalar
    `(,yaml_document_t*
      (const ,yaml_char_t *)
      (const ,yaml_char_t *)
      int ,yaml_scalar_style_t)
    <int>)
  (define-c-function %yaml-document-add-sequence
    `(,yaml_document_t*
      (const ,yaml_char_t *)
      ,yaml_sequence_style_t)
    <int>)
  (define-c-function %yaml-document-add-mapping
    `(,yaml_document_t*
      (const ,yaml_char_t *)
      ,yaml_mapping_style_t)
    <int>)
  (define-c-function %yaml-document-append-sequence-item
    `(,yaml_document_t* int int)
    <int>)
  (define-c-function %yaml-document-append-mapping-pair
    `(,yaml_document_t* int int int)
    <int>)
  )

(define-class <yaml-document> ()
  ((%doc :init-value #f)))

(define (%wrap-yaml-document handle)
  (of-type? handle yaml_document_t*)
  (rlet1 doc (make <yaml-document>)
    (set! (~ doc'%doc) handle)))

;;;
;;;  Parser
;;;

(with-ffi *libyaml* ()
  (define-c-function %yaml-parser-initialize
    `(,yaml_parser_t*) <int>)
  (define-c-function %yaml-parser-delete
    `(,yaml_parser_t*) <void>)

  (define-c-function %yaml-parser-set-input-string
    `(,yaml_parser_t*
      (const unsigned char*)
      size_t) <void>)

  (define-c-function %yaml-parser-set-input-file
    `(,yaml_parser_t*
      (,FILE *)) <void>)  ;; NB: not sure how we expose FILE*.

  (define-c-function %yaml-parser-set-input
    `(,yaml_parser_t*
      (,yaml_read_handler_t *)
      void*) <void>)

  (define-c-function %yaml-parser-set-encoding
    `(,yaml_parser_t*
      ,yaml_encoding_t) <void>)

  (define-c-function %yaml-parser-scan
    `(,yaml_parser_t*
      ,yaml_token_t*) <int>)

  (define-c-function %yaml-parser-parse
    `(,yaml_parser_t*
      ,yaml_event_t*) <int>)

  (define-c-function %yaml-parser-load
    `(,yaml_parser_t*
      ,yaml_document_t*) <int>)
  )

(define-class <yaml-parser> ()
  ((%parser :init-form #f)))

(define-method initialize ((p <yaml-parser>) initargs)
  (next-method)
  (let1 handle (make-native-handle yaml_parser_t)
    (call-yaml %yaml-parser-initialize handle)
    (set! (~ p'%parser) handle)))

(define (yaml-parser-active? parser)
  (assume-type parser <yaml-parser>)
  (boolean (~ parser'%parser)))

(define-method yaml-fini ((p <yaml-parser>))
  (and-let1 handle (~ p'%parser)
    (%yaml-parser-delete handle)
    (set! (~ p'%parser) #f)))

(define (%parser-handle parser)
  (assume-type parser <yaml-parser>)
  (or (~ parser'%parser)
      (error "YAML parser has already deleted:" parser)))

(define (yaml-parser-set-input-string parser string)
  (let1 h (make-native-handle (native-type '(const unsigned char*)) string)
    (%yaml-parser-set-input-string (%parser-handle parser)
                                   h
                                   (string-size string))))


(define (yaml-parser-load parser)
  (let ([doc (make-native-handle yaml_parser_t)]
        [p (%parser-handle parser)])
    (call-yaml %yaml-parser-load p doc)
    (%wrap-yaml-document doc)))

;; Local variables:
;; mode: scheme
;; end:
