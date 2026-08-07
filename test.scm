;;;
;;; Test text.yaml
;;;

(use gauche.test)

(test-start "text.yaml")
(use text.yaml)
(test-module 'text.yaml)

(test-section "version string")

(test* "ymml-get-version"
       (yaml-get-version-string)
       (string-join (map number->string (yaml-get-version)) "."))

(test-section "parser")

(let1 p (make <yaml-parser>)
  (test* "parser creation" #t (yaml-parser-active? p))
  (test* "finish" #f
         (begin
           (yaml-fini p)
           (yaml-parser-active? p)))
  )

(test* "yaml-parser-scan"
       '(YAML_STREAM_START_TOKEN
         YAML_BLOCK_MAPPING_START_TOKEN
         YAML_KEY_TOKEN
         (YAML_SCALAR_TOKEN . "foo")
         YAML_VALUE_TOKEN
         (YAML_SCALAR_TOKEN . "3")
         YAML_BLOCK_END_TOKEN
         YAML_STREAM_END_TOKEN
         YAML_NO_TOKEN)
       (let ([p (make <yaml-parser>)]
             [t (make <yaml-token>)]
             [r '()])
         (yaml-parser-set-input-string p "foo: 3")
         (let loop ()
           (yaml-parser-scan! p t)
           (push! r (if (= (~ t'type) YAML_SCALAR_TOKEN)
                      (cons (yaml-token-type-name (~ t'type))
                            (yaml-token-scalar-value t))
                      (yaml-token-type-name (~ t'type))))
           (unless (= (~ t'type) YAML_NO_TOKEN)
             (loop)))
         (reverse r)))

(test* "yaml-parser-parse"
       '(YAML_STREAM_START_EVENT
         YAML_DOCUMENT_START_EVENT
         YAML_MAPPING_START_EVENT
         (YAML_SCALAR_EVENT . "foo")
         (YAML_SCALAR_EVENT . "3")
         YAML_MAPPING_END_EVENT
         YAML_DOCUMENT_END_EVENT
         YAML_STREAM_END_EVENT)
       (let ([p (make <yaml-parser>)]
             [e (make <yaml-event>)]
             [r '()])
         (yaml-parser-set-input-string p "foo: 3")
         (let loop ()
           (yaml-parser-parse! p e)
           (push! r (if (= (~ e'type) YAML_SCALAR_EVENT)
                      (cons (yaml-event-type-name (~ e'type))
                            (yaml-event-scalar-value e))
                      (yaml-event-type-name (~ e'type))))
           (let1 last? (= (~ e'type) YAML_STREAM_END_EVENT)
             (yaml-event-delete! e)
             (unless last? (loop))))
         (yaml-fini p)
         (reverse r)))

(test* "yaml-parser-load"
       (list (make <yaml-mark> :index 0 :line 0 :column 0)
             (make <yaml-mark> :index 6 :line 1 :column 0))
       (let1 p (make <yaml-parser>)
         (yaml-parser-set-input-string p "foo: 3")
         (let1 d (yaml-parser-load p)
           (yaml-fini p)
           (and (is-a? d <yaml-document>)
                (list (~ d'start_mark)
                      (~ d'end_mark))))))

(test-end :exit-on-failure #t)
