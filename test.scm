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

(test* "yaml-parser-load" #t
       (let1 p (make <yaml-parser>)
         (yaml-parser-set-input-string p "foo: 3")
         (let1 d (yaml-parser-load p)
           (yaml-fini p)
           (is-a? d <yaml-document>))))

(test-end :exit-on-failure #t)
