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

(test* "yaml-parser-parse!"
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

(define (parse-string str)
  (let1 p (make <yaml-parser>)
    (unwind-protect (begin
                      (yaml-parser-set-input-string p str)
                      (yaml-parser-parse p))
      (yaml-fini p))))

(test* "yaml-parser-parse (mapping)"
       '((("foo" . "3") ("bar" . "baz")))
       (parse-string "foo: 3\nbar: baz\n"))

(test* "yaml-parser-parse (sequence)"
       '(#("a" "b" "c"))
       (parse-string "- a\n- b\n- c\n"))

(test* "yaml-parser-parse (nested)"
       '(#((("foo" . "1") ("bar" . #("a" "b"))) "baz"))
       (parse-string "- foo: 1\n  bar: [a, b]\n- baz\n"))

(test* "yaml-parser-parse (multiple documents)"
       '("a" #("b"))
       (parse-string "--- a\n--- [b]\n"))

(test* "yaml-parser-parse (empty stream)"
       '()
       (parse-string ""))

(test* "yaml-parser-parse (alias)"
       (test-error <error> #/alias is not supported/)
       (parse-string "a: &x 1\nb: *x\n"))

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
