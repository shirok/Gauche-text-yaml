;;;
;;;  LibYAML binding for Gauche
;;;

(define-module text.yaml
  (use gauche.dictionary)
  (use gauche.native-type)
  (use gauche.ffi)
  (use gauche.record)
  (use scheme.box)
  (export yaml-get-version-string
          yaml-get-version

          yaml-fini

          <yaml-mark>

          <yaml-token>
          YAML_NO_TOKEN
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
          YAML_SCALAR_TOKEN
          yaml-token-type-name
          yaml-token-type-value
          yaml-token-scalar-value

          <yaml-event>
          YAML_NO_EVENT
          YAML_STREAM_START_EVENT
          YAML_STREAM_END_EVENT
          YAML_DOCUMENT_START_EVENT
          YAML_DOCUMENT_END_EVENT
          YAML_ALIAS_EVENT
          YAML_SCALAR_EVENT
          YAML_SEQUENCE_START_EVENT
          YAML_SEQUENCE_END_EVENT
          YAML_MAPPING_START_EVENT
          YAML_MAPPING_END_EVENT
          yaml-event-type-name
          yaml-event-type-value
          yaml-event-scalar-value
          yaml-event-anchor
          yaml-event-delete!

          <yaml-schema>
          make-yaml-schema
          yaml-schema?
          yaml-schema-name
          yaml-schema-resolvers
          yaml-schema-constructors
          yaml-schema
          yaml-1.2-core-schema
          yaml-1.1-schema
          yaml-failsafe-schema
          yaml-null-tag
          yaml-bool-tag
          yaml-int-tag
          yaml-float-tag
          yaml-str-tag
          yaml-construct-null
          yaml-1.2-construct-bool
          yaml-1.2-construct-int
          yaml-1.2-construct-float
          yaml-1.1-construct-bool
          yaml-1.1-construct-int
          yaml-1.1-construct-float

          <yaml-parser>
          yaml-parser-active?
          yaml-parser-anchor-ref
          yaml-parser-anchor-set!
          yaml-parser-anchor-clear!
          yaml-parser-set-input-string
          yaml-parser-set-input-port
          yaml-parser-scan!
          yaml-parser-parse!
          yaml-parser-parse

          yaml-parse-file)
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

(define-type yaml_char_t <uint8>)
(define-type yaml_char_t* (make-c-pointer-type yaml_char_t))

(define-type yaml_version_directive_t
  (native-type '(.struct yaml_version_directive_s
                         (major::int
                          minor::int))))

(define-native-wrapper-class <yaml-version-directive> yaml_version_directive_t)

(define-method write-object ((obj <yaml-version-directive>) port)
  (format port "#<yaml-version-directive ~a.~a>" (~ obj'major) (~ obj'minor)))

(define-type yaml_tag_directive_t
  (native-type `(.struct yaml_tag_directive_s
                         (handle::,yaml_char_t*
                          prefix::,yaml_char_t*))))

(define-type yaml_mark_t
  (native-type `(.struct yaml_mark_s
                         (index::size_t
                          line::size_t
                          column::size_t))))

(define-native-wrapper-class <yaml-mark> yaml_mark_t)

(define-method write-object ((obj <yaml-mark>) port)
  (format port "#<yaml-mark ~a:~a:~a>"
          (~ obj'index) (~ obj'line) (~ obj'column)))

(define-method object-equal? ((a <yaml-mark>) (b <yaml-mark>))
  (and (eqv? (~ a'index) (~ b'index))
       (eqv? (~ a'line) (~ b'line))
       (eqv? (~ a'column) (~ b'column))))


(define-type yaml_encoding_t <int>)          ;enum
(define-type yaml_char_style_t <int>)        ;enum
(define-type yaml_scalar_style_t <int>)      ;enum
(define-type yaml_sequence_style_t <int>)    ;enum
(define-type yaml_mapping_style_t <int>)     ;enum
(define-type yaml_token_type_t <int>)        ;enum
(define-type yaml_event_type_t <int>)        ;enum
(define-type yaml_node_type_t <int>)         ;enum
(define-type yaml_node_item_t <int>)
(define-type yaml_error_type_t <int>)        ;enum
(define-type yaml_parser_state_t <int>)      ;enum

(define-type yaml_token_t
  (native-type
   `(.struct
     yaml_token_s
     (type::,yaml_token_type_t
      data::(.union
             (stream_start::(.struct (encoding::,yaml_encoding_t))
              alias       ::(.struct (value::,yaml_char_t*))
              anchor      ::(.struct (value::,yaml_char_t*))
              tag         ::(.struct (handle::,yaml_char_t
                                      suffix::,yaml_char_t*))
              scalar      ::(.struct (value::,yaml_char_t*
                                      length::size_t
                                      style::,yaml_char_style_t))
              version_directive::(.struct (major::int
                                           minor::int))
              tag_directive::(.struct (handle::,yaml_char_t*
                                       prefix::,yaml_char_t*))))
      start_mark::,yaml_mark_t
      end_mark::,yaml_mark_t))))
(define-type yaml_token_t* (make-c-pointer-type yaml_token_t))

(define-native-wrapper-class <yaml-token> yaml_token_t)

(define *yaml-token-type-map*
  (rlet1 m (make-bimap (make-hash-table 'eqv?) (make-hash-table 'eqv?))
    (for-each (^p (bimap-put! m (car p) (cdr p)))
              `((YAML_NO_TOKEN . ,YAML_NO_TOKEN)
                (YAML_STREAM_START_TOKEN . ,YAML_STREAM_START_TOKEN)
                (YAML_STREAM_END_TOKEN . ,YAML_STREAM_END_TOKEN)
                (YAML_VERSION_DIRECTIVE_TOKEN . ,YAML_VERSION_DIRECTIVE_TOKEN)
                (YAML_TAG_DIRECTIVE_TOKEN . ,YAML_TAG_DIRECTIVE_TOKEN)
                (YAML_DOCUMENT_START_TOKEN . ,YAML_DOCUMENT_START_TOKEN)
                (YAML_DOCUMENT_END_TOKEN . ,YAML_DOCUMENT_END_TOKEN)
                (YAML_BLOCK_SEQUENCE_START_TOKEN . ,YAML_BLOCK_SEQUENCE_START_TOKEN)
                (YAML_BLOCK_MAPPING_START_TOKEN . ,YAML_BLOCK_MAPPING_START_TOKEN)
                (YAML_BLOCK_END_TOKEN . ,YAML_BLOCK_END_TOKEN)
                (YAML_FLOW_SEQUENCE_START_TOKEN . ,YAML_FLOW_SEQUENCE_START_TOKEN)
                (YAML_FLOW_SEQUENCE_END_TOKEN . ,YAML_FLOW_SEQUENCE_END_TOKEN)
                (YAML_FLOW_MAPPING_START_TOKEN . ,YAML_FLOW_MAPPING_START_TOKEN)
                (YAML_FLOW_MAPPING_END_TOKEN . ,YAML_FLOW_MAPPING_END_TOKEN)
                (YAML_BLOCK_ENTRY_TOKEN . ,YAML_BLOCK_ENTRY_TOKEN)
                (YAML_FLOW_ENTRY_TOKEN . ,YAML_FLOW_ENTRY_TOKEN)
                (YAML_KEY_TOKEN . ,YAML_KEY_TOKEN)
                (YAML_VALUE_TOKEN . ,YAML_VALUE_TOKEN)
                (YAML_ALIAS_TOKEN . ,YAML_ALIAS_TOKEN)
                (YAML_ANCHOR_TOKEN . ,YAML_ANCHOR_TOKEN)
                (YAML_TAG_TOKEN . ,YAML_TAG_TOKEN)
                (YAML_SCALAR_TOKEN . ,YAML_SCALAR_TOKEN)))))

(define (yaml-token-type-name token-type)
  (bimap-right-get *yaml-token-type-map* token-type))
(define (yaml-token-type-value token-type-name)
  (bimap-left-get *yaml-token-type-map* token-type-name))

;; Returns the scalar value of TOKEN as a string.  TOKEN must be
;; a scalar token.
(define (yaml-token-scalar-value token)
  (assume-type token <yaml-token>)
  (unless (= (~ token'type) YAML_SCALAR_TOKEN)
    (error "yaml scalar token required, but got:" token))
  (let1 h (wrapped-handle token)
    (c-char*->string (native. h 'data 'scalar 'value)
                     (native. h 'data 'scalar 'length))))

(define-type yaml_event_t
  (native-type
   `(.struct
     yaml_event_s
     (type::,yaml_event_type_t
      data::(.union
              (stream_start::(.struct (encoding::,yaml_encoding_t))
               document_start::(.struct
                                (version_directive::(,yaml_version_directive_t *)
                                 tag_directives::(.struct
                                                  (start::(,yaml_tag_directive_t *)
                                                   end::(,yaml_tag_directive_t *)))
                                 implicit::int))
               document_end::(.struct (implicit::int))
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
(define-type yaml_event_t* (make-c-pointer-type yaml_event_t))

(define-native-wrapper-class <yaml-event> yaml_event_t)

(define *yaml-event-type-map*
  (rlet1 m (make-bimap (make-hash-table 'eqv?) (make-hash-table 'eqv?))
    (for-each (^p (bimap-put! m (car p) (cdr p)))
              `((YAML_NO_EVENT . ,YAML_NO_EVENT)
                (YAML_STREAM_START_EVENT . ,YAML_STREAM_START_EVENT)
                (YAML_STREAM_END_EVENT . ,YAML_STREAM_END_EVENT)
                (YAML_DOCUMENT_START_EVENT . ,YAML_DOCUMENT_START_EVENT)
                (YAML_DOCUMENT_END_EVENT . ,YAML_DOCUMENT_END_EVENT)
                (YAML_ALIAS_EVENT . ,YAML_ALIAS_EVENT)
                (YAML_SCALAR_EVENT . ,YAML_SCALAR_EVENT)
                (YAML_SEQUENCE_START_EVENT . ,YAML_SEQUENCE_START_EVENT)
                (YAML_SEQUENCE_END_EVENT . ,YAML_SEQUENCE_END_EVENT)
                (YAML_MAPPING_START_EVENT . ,YAML_MAPPING_START_EVENT)
                (YAML_MAPPING_END_EVENT . ,YAML_MAPPING_END_EVENT)))))

(define (yaml-event-type-name event-type)
  (bimap-right-get *yaml-event-type-map* event-type))
(define (yaml-event-type-value event-type-name)
  (bimap-left-get *yaml-event-type-map* event-type-name))

;;
;; Scalar resolution
;;

;; libyaml doesn't resolve tags.  We follow PyYAML model to interpret
;; tags and convert values.
;; A <yaml-schema> holds the two tables that drive it:
;;
;;   resolvers    - ((tag . regexp) ...), consulted in order to find the
;;                  tag of an untagged plain scalar.  A scalar that
;;                  matches none of them is a string.
;;   constructors - ((tag . proc) ...), where PROC maps the scalar's
;;                  string value to a Scheme value.  A tag with no
;;                  constructor---an application-specific one, say---
;;                  leaves the value as a string.

(define yaml-null-tag "tag:yaml.org,2002:null")
(define yaml-bool-tag "tag:yaml.org,2002:bool")
(define yaml-int-tag "tag:yaml.org,2002:int")
(define yaml-float-tag "tag:yaml.org,2002:float")
(define yaml-str-tag "tag:yaml.org,2002:str")

(define-record-type <yaml-schema>
  (make-yaml-schema name resolvers constructors)
  yaml-schema?
  (name yaml-schema-name)
  (resolvers yaml-schema-resolvers)
  (constructors yaml-schema-constructors))

;; Resolution patterns of the YAML 1.2 core schema.  The int pattern
;; must be tried before the float one, for the float pattern also
;; matches an integer with neither point nor exponent.
(define *yaml-null-rx* #/^(?:~|null|Null|NULL|)$/)
(define *yaml-1.2-bool-rx* #/^(?:true|True|TRUE|false|False|FALSE)$/)
(define *yaml-1.2-int-rx* #/^(?:[-+]?[0-9]+|0o[0-7]+|0x[0-9a-fA-F]+)$/)
(define *yaml-1.2-float-rx*
  #/^(?:[-+]?(?:\.[0-9]+|[0-9]+(?:\.[0-9]*)?)(?:[eE][-+]?[0-9]+)?|[-+]?\.(?:inf|Inf|INF)|\.(?:nan|NaN|NAN))$/)

;; A constructor may also be reached through an explicit tag, which
;; bypasses the resolver, so each one validates its argument.

(define (yaml-construct-null val) 'null) ;the value, if any, is ignored

(define (yaml-1.2-construct-bool val)
  (rxmatch-case val
    [#/^(?:true|True|TRUE)$/ (#f) #t]
    [#/^(?:false|False|FALSE)$/ (#f) #f]
    [else (errorf "Invalid boolean scalar: ~s" val)]))

(define (yaml-1.2-construct-int val)
  (rxmatch-case val
    [#/^0o([0-7]+)$/ (#f digits) (string->number digits 8)]
    [#/^0x([0-9a-fA-F]+)$/ (#f digits) (string->number digits 16)]
    [#/^[-+]?[0-9]+$/ (#f) (string->number val 10)]
    [else (errorf "Invalid integer scalar: ~s" val)]))

(define (yaml-1.2-construct-float val)
  (rxmatch-case val
    [#/^([-+]?)\.(?:inf|Inf|INF)$/ (#f sign)
     (if (equal? sign "-") -inf.0 +inf.0)]
    [#/^\.(?:nan|NaN|NAN)$/ (#f) +nan.0]
    [else (or (and-let* ([n (string->number val)]) (exact->inexact n))
              (errorf "Invalid float scalar: ~s" val))]))

;; The YAML 1.2 core schema, which we use by default.
(define yaml-1.2-core-schema
  (make-yaml-schema 'core
                    `((,yaml-null-tag . ,*yaml-null-rx*)
                      (,yaml-bool-tag . ,*yaml-1.2-bool-rx*)
                      (,yaml-int-tag . ,*yaml-1.2-int-rx*)
                      (,yaml-float-tag . ,*yaml-1.2-float-rx*))
                    `((,yaml-null-tag . ,yaml-construct-null)
                      (,yaml-bool-tag . ,yaml-1.2-construct-bool)
                      (,yaml-int-tag . ,yaml-1.2-construct-int)
                      (,yaml-float-tag . ,yaml-1.2-construct-float))))

;; YAML 1.1---the type repository at yaml.org/type/---recognizes a
;; different set of plain scalars:
;;
;;   bool  - y/yes/on and n/no/off are booleans as well.
;;   int   - octal is a leading 0 rather than 0o, there's base 2 and
;;           base 60, and digits may be grouped with underscores.
;;   float - underscores again, base 60, and the exponent must carry a
;;           sign, so 1.5e3 is a *string* in 1.1.
;;
;; null is the same under both.  Two of these are silent traps when a
;; 1.2 document is read as 1.1: 014 is 12 rather than 14, and a clock
;; time like 20:03:20 is the integer 72200.
;;
;; The 1.1 repository also has the timestamp, binary, omap, set and
;; pairs types and the merge (<<) and value (=) keys, none of which we
;; resolve; timestamp is the notable omission.
(define *yaml-1.1-bool-rx*
  #/^(?:y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$/)
(define *yaml-1.1-int-rx*
  #/^(?:[-+]?0b[01_]+|[-+]?0[0-7_]+|[-+]?(?:0|[1-9][0-9_]*)|[-+]?0x[0-9a-fA-F_]+|[-+]?[1-9][0-9_]*(?::[0-5]?[0-9])+)$/)
;; The spec's own base-10 pattern makes the digits before the point
;; optional *and* allows no digits after it, so it matches a lone ".";
;; we require a digit on one side or the other.
(define *yaml-1.1-float-rx*
  #/^(?:[-+]?(?:[0-9][0-9_]*\.[0-9_]*|\.[0-9_]+)(?:[eE][-+][0-9]+)?|[-+]?[0-9][0-9_]*(?::[0-5]?[0-9])+\.[0-9_]*|[-+]?\.(?:inf|Inf|INF)|\.(?:nan|NaN|NAN))$/)

(define (%yaml-strip-underscores s) (regexp-replace-all #/_/ s ""))

(define (%yaml-signed sign n) (if (equal? sign "-") (- n) n))

;; Base 60, most significant first: 190:20:30 is 190*3600+20*60+30.
(define (%yaml-sexagesimal digits)
  (let loop ([ds (string-split digits #\:)] [n 0])
    (if (null? ds)
      n
      (loop (cdr ds) (+ (* n 60) (string->number (car ds) 10))))))

(define (yaml-1.1-construct-bool val)
  (rxmatch-case val
    [#/^(?:y|Y|yes|Yes|YES|true|True|TRUE|on|On|ON)$/ (#f) #t]
    [#/^(?:n|N|no|No|NO|false|False|FALSE|off|Off|OFF)$/ (#f) #f]
    [else (errorf "Invalid boolean scalar: ~s" val)]))

(define (yaml-1.1-construct-int val)
  (let1 s (%yaml-strip-underscores val)
    (rxmatch-case s
      [#/^([-+]?)0b([01]+)$/ (#f sign digits)
       (%yaml-signed sign (string->number digits 2))]
      [#/^([-+]?)0x([0-9a-fA-F]+)$/ (#f sign digits)
       (%yaml-signed sign (string->number digits 16))]
      [#/^([-+]?)0([0-7]+)$/ (#f sign digits)
       (%yaml-signed sign (string->number digits 8))]
      [#/^[-+]?(?:0|[1-9][0-9]*)$/ (#f) (string->number s 10)]
      [#/^([-+]?)([1-9][0-9]*(?::[0-5]?[0-9])+)$/ (#f sign digits)
       (%yaml-signed sign (%yaml-sexagesimal digits))]
      [else (errorf "Invalid integer scalar: ~s" val)])))

(define (yaml-1.1-construct-float val)
  (let1 s (%yaml-strip-underscores val)
    (rxmatch-case s
      [#/^([-+]?)\.(?:inf|Inf|INF)$/ (#f sign)
       (if (equal? sign "-") -inf.0 +inf.0)]
      [#/^\.(?:nan|NaN|NAN)$/ (#f) +nan.0]
      [#/^([-+]?)([0-9]+(?::[0-5]?[0-9])+)(\.[0-9]*)$/ (#f sign digits frac)
       (%yaml-signed sign (+ (%yaml-sexagesimal digits)
                             (string->number (string-append "0" frac))))]
      [else (or (and-let* ([n (string->number s)]) (exact->inexact n))
                (errorf "Invalid float scalar: ~s" val))])))

(define yaml-1.1-schema
  (make-yaml-schema 'yaml-1.1
                    `((,yaml-null-tag . ,*yaml-null-rx*)
                      (,yaml-bool-tag . ,*yaml-1.1-bool-rx*)
                      (,yaml-int-tag . ,*yaml-1.1-int-rx*)
                      (,yaml-float-tag . ,*yaml-1.1-float-rx*))
                    `((,yaml-null-tag . ,yaml-construct-null)
                      (,yaml-bool-tag . ,yaml-1.1-construct-bool)
                      (,yaml-int-tag . ,yaml-1.1-construct-int)
                      (,yaml-float-tag . ,yaml-1.1-construct-float))))

;; The YAML 1.2 failsafe schema, under which every scalar is a string.
(define yaml-failsafe-schema (make-yaml-schema 'failsafe '() '()))

(define yaml-schema (make-parameter yaml-1.2-core-schema))

;; Returns the tag SCHEMA resolves the plain scalar VAL to.
(define (yaml-resolve-tag schema val)
  (let loop ([rs (yaml-schema-resolvers schema)])
    (cond [(null? rs) yaml-str-tag]
          [((cdar rs) val) (caar rs)]
          [else (loop (cdr rs))])))

;; Returns the scalar value of EVENT, resolved according to the current
;; yaml-schema.  EVENT must be a scalar event.
;;
;; Only a *plain* scalar without a tag is resolved implicitly; a quoted,
;; literal or folded scalar is always a string, so "null" and '' stay
;; strings while an empty plain scalar is null.  libyaml tells them
;; apart with the plain_implicit flag, which is also 0 when the node
;; carries an explicit tag.
(define (yaml-event-scalar-value event)
  (assume-type event <yaml-event>)
  (unless (= (~ event'type) YAML_SCALAR_EVENT)
    (error "yaml scalar event required, but got:" event))
  (let* ([h (wrapped-handle event)]
         [val (c-char*->string (native. h 'data 'scalar 'value)
                               (native. h 'data 'scalar 'length))]
         [schema (yaml-schema)]
         [tag (cond [(let1 t (native. h 'data 'scalar 'tag)
                       (and (not (null-pointer-handle? t))
                            (c-char*->string t)))]
                    [(= (native. h 'data 'scalar 'plain_implicit) 1)
                     (yaml-resolve-tag schema val)]
                    [else yaml-str-tag])])
    (cond [(assoc tag (yaml-schema-constructors schema)) => (^p ((cdr p) val))]
          [else val])))

;; Returns the anchor of EVENT as a string, or #f if it has none.
;; A scalar, sequence start or mapping start event carries the anchor
;; the node is labeled with; an alias event carries the anchor it refers
;; to.  No other event has an anchor.
(define (yaml-event-anchor event)
  (assume-type event <yaml-event>)
  (let* ([type (~ event'type)]
         [h (wrapped-handle event)]
         [p (cond [(= type YAML_SCALAR_EVENT)
                   (native. h 'data 'scalar 'anchor)]
                  [(= type YAML_SEQUENCE_START_EVENT)
                   (native. h 'data 'sequence_start 'anchor)]
                  [(= type YAML_MAPPING_START_EVENT)
                   (native. h 'data 'mapping_start 'anchor)]
                  [(= type YAML_ALIAS_EVENT)
                   (native. h 'data 'alias 'anchor)]
                  [else #f])])
    (and p
         (not (null-pointer-handle? p))
         (c-char*->string p))))

;; NB: We define yaml_node and yaml_document related types, but we don't
;; really provide API to deal with it.  We can use yaml_event layer directly
;; to provide high-level API (e.g. yaml-parse-file).
(define-type yaml_node_pair_t
  (native-type
   `(.struct yaml_node_pair_s (key::int value::int))))

(define-type yaml_node_t
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
(define-type yaml_node_t* (make-c-pointer-type yaml_node_t))

(define-type yaml_document_t
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
(define-type yaml_document_t* (make-c-pointer-type yaml_document_t))

(define-type yaml_read_handler_t
  (native-type
   `(.function (void* (unsigned char*) size_t size_t*) int)))

(define-type yaml_simple_key_t
  (native-type
   `(.struct
     yaml_simple_key_s
     (possible::int
      required::int
      token_number::size_t
      mark::,yaml_mark_t))))

(define-type yaml_alias_data_t
  (native-type
   `(.struct
     yaml_alias_data_s
     (anchor::(,yaml_char_t *)
      index::int
      mark::,yaml_mark_t))))

(define-type FILE <void>) ; Just to tame native-type system

(define-type yaml_parser_t
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
(define-type yaml_parser_t* (make-c-pointer-type yaml_parser_t))

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

  ;; We don't provide yaml_parser_set_input_file and yaml_parser_set_input
  ;; Scheme-friendly yaml-parser-set-input-port is defined below

  (define-c-function %yaml-parser-set-encoding
    `(,yaml_parser_t*
      ,yaml_encoding_t) <void>)

  (define-c-function %yaml-parser-scan
    `(,yaml_parser_t*
      ,yaml_token_t*) <int>)

  (define-c-function %yaml-parser-parse
    `(,yaml_parser_t*
      ,yaml_event_t*) <int>)
  )

(define-class <yaml-parser> ()
  ((%parser :init-form #f)
   ;; Maps anchor names to Scheme objs
   (%anchors :init-form (make-hash-table 'string=?))
   ;; Keeps the input (port/string) reference to prevent it from GC-ed.
   (%input :init-form #f)))

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
    (set! (~ p'%parser) #f)
    (set! (~ p'%anchors) #f)            ;GC friendly
    (set! (~ p'%input) #f)))

;; Anchor table.  An anchor is only visible within the document that
;; defines it, so the table is cleared at each document start.
(define (yaml-parser-anchor-ref parser name :optional (fallback #f))
  (hash-table-get (%anchor-table parser) name fallback))

(define (yaml-parser-anchor-set! parser name obj)
  (hash-table-put! (%anchor-table parser) name obj))

(define (yaml-parser-anchor-clear! parser)
  (hash-table-clear! (%anchor-table parser)))

(define (%anchor-table parser)
  (assume-type parser <yaml-parser>)
  (or (~ parser'%anchors)
      (error "YAML parser has already been deleted:" parser)))

(define (%parser-handle parser)
  (assume-type parser <yaml-parser>)
  (or (~ parser'%parser)
      (error "YAML parser has already been deleted:" parser)))

(define (yaml-parser-set-input-string parser string)
  ;; NB: make-native-handle doesn't take an empty string.  We pass a dummy
  ;; buffer instead; libyaml won't look at it, for the size is zero.
  (let ([p (%parser-handle parser)]
        [h (make-native-handle (native-type '(const unsigned char*))
                               (if (equal? string "") " " string))])
    (set! (~ parser'%input) h)
    (%yaml-parser-set-input-string p h (string-size string))))

(inline-stub
 (define-cfn %yaml-parser-reader-cb (data::void*
                                     buffer::u_char*
                                     size::size_t
                                     size_read::size_t*)
   ::int
   (let* ([port::ScmPort* (cast ScmPort* data)]
          [nread::ScmSize (Scm_Getz (cast char* buffer) size port)])
     (if (== nread EOF)
       (set! (* size_read) 0)
       (set! (* size_read) nread))
     ;; TODO: probably we should catch Scheme error and return 0.
     (return 1)))
 )

(define-cproc %yaml-parser-set-input-port (parser
                                           port::<input-port>)
  ::<void>
  (let* ([p::yaml_parser_t*
          (Scm_NativeHandlePtr (SCM_NATIVE_HANDLE parser))])
    (yaml_parser_set_input p %yaml-parser-reader-cb port)))

(define (yaml-parser-set-input-port parser port)
  (assume-type port <input-port>)
  (let1 p (%parser-handle parser)
    (set! (~ parser'%input) port)
    (%yaml-parser-set-input-port p port)))

(define (yaml-parser-scan! parser token)
  (assume-type token <yaml-token>)
  (call-yaml %yaml-parser-scan
             (%parser-handle parser)
             (wrapped-handle token)))

(define (yaml-parser-parse! parser event)
  (assume-type event <yaml-event>)
  (call-yaml %yaml-parser-parse
             (%parser-handle parser)
             (wrapped-handle event)))

;; Releases the data the event holds.  The event itself can be reused.
(define (yaml-event-delete! event)
  (assume-type event <yaml-event>)
  (%yaml-event-delete (wrapped-handle event)))

;; Using anchors and aliases, YAML's data structure can form a cyclic graph.
;; To realize it, we use a box when we encounter an anchor, and after the
;; whole document is read, we walk the structure to remove intermediate
;; boxes.
(define (%yaml-splice-placeholders doc)
  (define seen (make-hash-table 'eq?))
  (define (deref x) (if (box? x) (unbox x) x))
  (define (walk x)
    (let loop ([x x])
      (cond [(pair? x)
             (unless (hash-table-contains? seen x)
               (hash-table-put! seen x #t)
               (let1 a (deref (car x)) (set-car! x a) (walk a))
               (let1 d (deref (cdr x)) (set-cdr! x d) (loop d)))]
            [(vector? x)
             (unless (hash-table-contains? seen x)
               (hash-table-put! seen x #t)
               (dotimes [i (vector-length x)]
                 (let1 v (deref (vector-ref x i))
                   (vector-set! x i v)
                   (walk v))))])))
  (rlet1 root (deref doc)
    (walk root)))

;; Reads the entire yaml stream from PARSER, and returns a list of
;; documents, each of which is an S-expression representation of the
;; document:
;;   A scalar is whatever yaml-event-scalar-value resolves it to under
;;     the current yaml-schema; with the default core schema, that is
;;     the symbol null, a boolean, a number, or a string.
;;   A sequence is a vector of its items.
;;   A mapping is an assoc list of its key and value.
(define (yaml-parser-parse parser)
  (let ([event (make <yaml-event>)]
        ;; Set when an alias hands out a box.
        [recursive? #f])
    ;; Reads the next event, and returns its type, its value if it is a
    ;; scalar event, and its anchor if it has one.  The event data is
    ;; released before returning, so the caller must not touch EVENT
    ;; itself.
    (define (next!)
      (yaml-parser-parse! parser event)
      (let* ([type (~ event'type)]
             [val (and (= type YAML_SCALAR_EVENT)
                       (yaml-event-scalar-value event))]
             [anchor (yaml-event-anchor event)])
        (yaml-event-delete! event)
        (values type val anchor)))
    (define (unexpected type)
      (errorf "Unexpected yaml event: ~a" (yaml-event-type-name type)))
    ;; Binds ANCHOR, if the node carries one, to OBJ, and returns OBJ.
    (define (anchor! anchor obj)
      (when anchor (yaml-parser-anchor-set! parser anchor obj))
      obj)
    (define (alias anchor)
      (let1 obj (yaml-parser-anchor-ref parser anchor (undefined))
        (when (undefined? obj)
          (errorf "Undefined YAML alias: *~a" anchor))
        (when (box? obj)                ;the node isn't complete yet
          (set! recursive? #t))
        obj))
    ;; A collection's anchor is bound as soon as the node begins, so that
    ;; an alias inside it has something to refer to; until the node is
    ;; complete, that something can only be a box.
    (define (collection anchor build)
      (if (not anchor)
        (build '())
        (let1 ph (box #f)
          (yaml-parser-anchor-set! parser anchor ph)
          (rlet1 obj (build '())
            (set-box! ph obj)
            ;; The node may have redefined its own anchor, in which case
            ;; the inner definition is the one a later alias should see.
            (when (eq? (yaml-parser-anchor-ref parser anchor) ph)
              (yaml-parser-anchor-set! parser anchor obj))))))
    (define (node type val anchor)
      (cond [(= type YAML_SCALAR_EVENT) (anchor! anchor val)]
            [(= type YAML_SEQUENCE_START_EVENT) (collection anchor sequence)]
            [(= type YAML_MAPPING_START_EVENT) (collection anchor mapping)]
            [(= type YAML_ALIAS_EVENT) (alias anchor)]
            [else (unexpected type)]))
    (define (sequence items)
      (receive (type val anchor) (next!)
        (if (= type YAML_SEQUENCE_END_EVENT)
          (list->vector (reverse items))
          (sequence (cons (node type val anchor) items)))))
    (define (mapping pairs)
      (receive (type val anchor) (next!)
        (if (= type YAML_MAPPING_END_EVENT)
          (reverse pairs)
          (let1 k (node type val anchor)
            (receive (type val anchor) (next!)
              (mapping (acons k (node type val anchor) pairs)))))))
    (define (documents docs)
      (receive (type val anchor) (next!)
        (cond [(= type YAML_STREAM_END_EVENT) (reverse docs)]
              [(= type YAML_DOCUMENT_START_EVENT)
               ;; An anchor is only visible within the document that
               ;; defines it.
               (yaml-parser-anchor-clear! parser)
               (set! recursive? #f)
               (let1 doc (receive (type val anchor) (next!)
                           (node type val anchor))
                 (receive (type val anchor) (next!)
                   (unless (= type YAML_DOCUMENT_END_EVENT)
                     (unexpected type))
                   (documents (cons (if recursive?
                                      (%yaml-splice-placeholders doc)
                                      doc)
                                    docs))))]
              [else (unexpected type)])))
    (receive (type val anchor) (next!)
      (unless (= type YAML_STREAM_START_EVENT)
        (unexpected type))
      (documents '()))))

;; High-level utility

(define (yaml-parse-file file)
  (let ([parser (make <yaml-parser>)])
    (unwind-protect
        (call-with-input-file file
          (^p (yaml-parser-set-input-port parser p)
              (yaml-parser-parse parser)))
      (yaml-fini parser))))

;; Local variables:
;; mode: scheme
;; end:
