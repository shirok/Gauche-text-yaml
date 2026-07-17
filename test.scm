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

(test* "yaml-parser-load"
       (list (make <yaml-mark> :index 0 :line 0 :column 0)
             (make <yaml-mark> :index 6 :line 1 :column 0))
       (let1 p (make <yaml-parser>)
         (yaml-parser-set-input-string p "foo: 3")
         (let1 d (yaml-parser-load p)
           (yaml-fini p)
           (and (is-a? d <yaml-document>)
                (list (~ d'start-mark)
                      (~ d'end-mark))))))

(test-end :exit-on-failure #t)
