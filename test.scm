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
         (YAML_SCALAR_EVENT . 3)
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

(define (parse-port port)
  (let1 p (make <yaml-parser>)
    (unwind-protect (begin
                      (yaml-parser-set-input-port p port)
                      (yaml-parser-parse p))
      (yaml-fini p))))

(test* "yaml-parser-parse (mapping)"
       '((("foo" . 3) ("bar" . "baz")))
       (parse-string "foo: 3\nbar: baz\n"))

(test* "yaml-parser-parse (sequence)"
       '(#("a" "b" "c"))
       (parse-string "- a\n- b\n- c\n"))

(test* "yaml-parser-parse (nested)"
       '(#((("foo" . 1) ("bar" . #("a" "b"))) "baz"))
       (parse-string "- foo: 1\n  bar: [a, b]\n- baz\n"))

(test* "yaml-parser-parse (multiple documents)"
       '("a" #("b"))
       (parse-string "--- a\n--- [b]\n"))

(test* "yaml-parser-parse (empty stream)"
       '()
       (parse-string ""))

;; Ensure memory associated to the input is retained across GC.
;; The pointers passed to yaml API won't be scanned; if we don't hold
;; the reference to the handle/port in <yaml-parser>, the memory would
;; be reclaimed while parser is running.
(let* ([n 5000]
       [src (string-join (map (^i #"k~|i|: ~i") (iota n)) "\n")])
  (test* "yaml-parser-parse (input larger than libyaml's buffer)"
         `(5000 ("k0" . 0) ("k4999" . 4999))
         (let1 doc (car (parse-string src))
           (list (length doc) (car doc) (last doc))))
  (test* "yaml-parser-parse (large input, from a port)"
         `(5000 ("k0" . 0) ("k4999" . 4999))
         (let1 doc (car (parse-port (open-input-string src)))
           (list (length doc) (car doc) (last doc)))))

(test-section "aliases")

(test* "alias (scalar)"
       '((("a" . 1) ("b" . 1)))
       (parse-string "a: &x 1\nb: *x\n"))

(test* "alias (empty scalar)"
       '((("a" . null) ("b" . null)))
       (parse-string "a: &n\nb: *n\n"))

(test* "alias (sequence)"
       '((("a" . #(1 2)) ("b" . #(1 2))))
       (parse-string "a: &x [1, 2]\nb: *x\n"))

(test* "alias (mapping)"
       '((("a" ("x" . 1)) ("b" ("x" . 1))))
       (parse-string "a: &x {x: 1}\nb: *x\n"))

;; The aliased node is shared, not copied.
(test* "alias (shares the node)" #t
       (let1 doc (car (parse-string "a: &x [1, 2]\nb: *x\n"))
         (eq? (cdr (assoc "a" doc)) (cdr (assoc "b" doc)))))

(test* "alias (as a mapping key)"
       '((("key" . 1) ("key" . 2)))
       (parse-string "&k key: 1\n? *k\n: 2\n"))

;; An anchor may be redefined; an alias refers to the most recent one.
(test* "alias (anchor redefined)"
       '(#(1 1 2 2))
       (parse-string "[&a 1, *a, &a 2, *a]"))

(test* "alias (undefined anchor)"
       (test-error <error> #/Undefined YAML alias/)
       (parse-string "a: *nope\n"))

;; An anchor is only visible within the document that defines it.
(test* "alias (anchor doesn't cross documents)"
       (test-error <error> #/Undefined YAML alias/)
       (parse-string "--- &a 1\n--- *a\n"))

;; An alias only has to refer to an anchor that occurs earlier, not to one
;; whose node is complete, so a node may be its own descendant.  The result
;; is circular, and neither `equal?' nor the test log's `write' can be let
;; near it, so these compare with `eq?' and report a boolean.

(test* "alias (recursive sequence)" #t
       (let1 v (car (parse-string "&a [*a]"))
         (and (vector? v)
              (= (vector-length v) 1)
              (eq? (vector-ref v 0) v))))

(test* "alias (recursive mapping)" #t
       (let1 m (car (parse-string "&a {x: *a}"))
         (eq? (cdr (assoc "x" m)) m)))

(test* "alias (recursive, one level down)" #t
       (let1 v (car (parse-string "&a [[*a]]"))
         (eq? (vector-ref (vector-ref v 0) 0) v)))

;; A recursive node as a mapping key is fine here---we don't hash keys.
(test* "alias (recursive mapping key)" #t
       (let1 m (car (parse-string "&a {*a: 1}"))
         (eq? (caar m) m)))

;; *b's node is complete by the time it's referred to, while *a's isn't.
(test* "alias (recursion through an inner anchor)" #t
       (let1 v (car (parse-string "&a [&b [*a], *b]"))
         (and (eq? (vector-ref v 0) (vector-ref v 1))
              (eq? (vector-ref (vector-ref v 0) 0) v))))

;; The mutual case: neither node is complete when it's referred to.
(test* "alias (mutual recursion)" #t
       (let1 m (car (parse-string "&a {b: &b {a: *a}}"))
         (let1 b (cdr (assoc "b" m))
           (eq? (cdr (assoc "a" b)) m))))

;; A recursive node in one document mustn't disturb the next one.
(test* "alias (recursion doesn't leak into the next document)"
       '#("x")
       (cadr (parse-string "--- &a [*a]\n--- [x]\n")))

(test-section "scalar resolution")

(test* "null (implicit)"
       '((("a" . null) ("b" . null) ("c" . null) ("d" . null) ("e" . null)))
       (parse-string "a:\nb: ~\nc: null\nd: Null\ne: NULL\n"))

(test* "null (explicit tag)"
       '((("a" . null) ("b" . null)))
       (parse-string "a: !!null\nb: !!null ignored\n"))

;; Only a plain scalar is resolved implicitly.
(test* "not null"
       '((("a" . "") ("b" . "") ("c" . "null") ("d" . "~") ("e" . "")))
       (parse-string "a: ''\nb: \"\"\nc: 'null'\nd: \"~\"\ne: !!str\n"))

(test* "boolean (implicit)"
       '((("a" . #t) ("b" . #t) ("c" . #t) ("d" . #f) ("e" . #f) ("f" . #f)))
       (parse-string "a: true\nb: True\nc: TRUE\nd: false\ne: False\nf: FALSE\n"))

(test* "boolean (explicit tag)"
       '((("a" . #t) ("b" . #f)))
       (parse-string "a: !!bool true\nb: !!bool FALSE\n"))

(test* "boolean (invalid)"
       (test-error <error> #/Invalid boolean scalar/)
       (parse-string "a: !!bool maybe\n"))

;; yes/no/on/off are YAML 1.1 booleans; the 1.2 core schema drops them.
(test* "not boolean"
       '((("a" . "yes") ("b" . "no") ("c" . "on")
          ("d" . "true") ("e" . "true")))
       (parse-string "a: yes\nb: no\nc: on\nd: 'true'\ne: \"true\"\n"))

(test* "integer (implicit)"
       '((("a" . 0) ("b" . 12345) ("c" . 12345) ("d" . -3)
          ("e" . 12) ("f" . 12)))
       (parse-string "a: 0\nb: 12345\nc: +12345\nd: -3\ne: 0o14\nf: 0xC\n"))

(test* "float (implicit)"
       '((("a" . 1230.15) ("b" . 1230.15) ("c" . 0.5) ("d" . 1.0)
          ("e" . +inf.0) ("f" . -inf.0)))
       (parse-string "a: 1.23015e+3\nb: 12.3015e+02\nc: .5\nd: 1.\n\
                      e: .inf\nf: -.inf\n"))

;; +nan.0 isn't equal? to itself, so check it apart from the rest.
(test* "float (nan)" #t
       (nan? (cdar (car (parse-string "a: .nan\n")))))

(test* "number (explicit tag)"
       '((("a" . 5) ("b" . 5.0) ("c" . "5")))
       (parse-string "a: !!int 5\nb: !!float 5\nc: !!str 5\n"))

(test* "number (invalid explicit tag)"
       (test-error <error> #/Invalid integer scalar/)
       (parse-string "a: !!int 1.5\n"))

;; 0b1010, 12_345 and 1,234 are YAML 1.1 integers the core schema
;; doesn't take.  014 is the nastier case: 1.1 reads it as octal 12,
;; the core schema as plain decimal 14.
(test* "not a number"
       '((("a" . "0b1010") ("b" . "12_345") ("c" . 14) ("d" . "1,234")
          ("e" . "5")))
       (parse-string "a: 0b1010\nb: 12_345\nc: 014\nd: 1,234\ne: '5'\n"))

;; Tags we don't resolve, and the non-specific tag "!".
(test* "other tags stay strings"
       '((("a" . "eA==") ("b" . "x") ("c" . "1")))
       (parse-string "a: !!binary eA==\nb: !custom x\nc: ! 1\n"))

(test-section "schemas")

(test* "core schema is the default" 'core (yaml-schema-name (yaml-schema)))

(test* "failsafe schema"
       '((("a" . "1") ("b" . "true") ("c" . "") ("d" . "1.5") ("e" . "x")))
       (parameterize ([yaml-schema yaml-failsafe-schema])
         (parse-string "a: 1\nb: true\nc:\nd: 1.5\ne: !!null x\n")))

(test* "1.1 schema (booleans)"
       '((("a" . #t) ("b" . #f) ("c" . #t) ("d" . #f) ("e" . #t) ("f" . #f)))
       (parameterize ([yaml-schema yaml-1.1-schema])
         (parse-string "a: yes\nb: no\nc: on\nd: off\ne: y\nf: N\n")))

(test* "1.1 schema (integers)"
       '((("a" . 10) ("b" . 12345) ("c" . 255) ("d" . 685230)))
       (parameterize ([yaml-schema yaml-1.1-schema])
         (parse-string "a: 0b1010\nb: 12_345\nc: 0xF_F\nd: 190:20:30\n")))

(test* "1.1 schema (floats)"
       '((("a" . 1000.5) ("b" . 1500.0) ("c" . 685230.15)))
       (parameterize ([yaml-schema yaml-1.1-schema])
         (parse-string "a: 1_000.5\nb: 1.5e+3\nc: 190:20:30.15\n")))

;; The two schemas read these four scalars differently, and only the
;; 0o14 case is loud about it: 014 and 20:03:20 quietly change value.
(let1 doc "a: 014\nb: 0o14\nc: 20:03:20\nd: yes\ne: 1.5e3\n"
  (test* "1.1 schema (divergence from 1.2)"
         '((("a" . 12) ("b" . "0o14") ("c" . 72200) ("d" . #t)
            ("e" . "1.5e3")))
         (parameterize ([yaml-schema yaml-1.1-schema]) (parse-string doc)))
  (test* "1.2 core schema (divergence from 1.1)"
         '((("a" . 14) ("b" . 12) ("c" . "20:03:20") ("d" . "yes")
            ("e" . 1500.0)))
         (parse-string doc)))

;; A schema is extended by adding to its two tables: a resolver to give
;; a plain scalar a tag, and a constructor to turn a tagged scalar into
;; a Scheme value.
(define my-schema
  (make-yaml-schema 'my
                    (cons '("!date" . #/^\d{4}-\d{2}-\d{2}$/)
                          (yaml-schema-resolvers yaml-1.2-core-schema))
                    (acons "!date"
                           (^v (map string->number (string-split v #\-)))
                           (acons "!sym" string->symbol
                                  (yaml-schema-constructors
                                   yaml-1.2-core-schema)))))

(test* "custom schema"
       '((("a" 2002 12 14) ("b" . foo) ("c" . 1)))
       (parameterize ([yaml-schema my-schema])
         (parse-string "a: 2002-12-14\nb: !sym foo\nc: 1\n")))

(test* "custom schema doesn't leak"
       '((("a" . "2002-12-14")))
       (parse-string "a: 2002-12-14\n"))

(test* "block scalars stay strings"
       '((("a" . "x\n") ("b" . "") ("c" . "")))
       (parse-string "a: |\n  x\nb: >\nc: |\n"))

(test* "resolution in keys and sequences"
       '(((null . "a") (#t . "b")) #(null #t))
       (parse-string "--- \n~: a\ntrue: b\n--- [null, true]\n"))

(test-section "yaml-parse-file")

(use file.util)

(define *example-dir*
  (build-path (sys-dirname (current-load-path)) "data" "examples"))

;; The examples from the YAML 1.2 spec (data/examples/*.yaml), paired with
;; the result yaml-parse-file is expected to return.
(define *examples*
  '(("2.1.yaml"
     (#("Mark McGwire" "Sammy Sosa" "Ken Griffey")))
    ("2.2.yaml"
     ((("hr" . 65) ("avg" . 0.278) ("rbi" . 147))))
    ("2.3.yaml"
     ((("american" . #("Boston Red Sox" "Detroit Tigers" "New York Yankees"))
       ("national" . #("New York Mets" "Chicago Cubs" "Atlanta Braves")))))
    ("2.4.yaml"
     (#((("name" . "Mark McGwire") ("hr" . 65) ("avg" . 0.278))
        (("name" . "Sammy Sosa") ("hr" . 63) ("avg" . 0.288)))))
    ("2.5.yaml"
     (#(#("name" "hr" "avg")
        #("Mark McGwire" 65 0.278)
        #("Sammy Sosa" 63 0.288))))
    ("2.6.yaml"
     ((("Mark McGwire" ("hr" . 65) ("avg" . 0.278))
       ("Sammy Sosa" ("hr" . 63) ("avg" . 0.288)))))
    ("2.7.yaml"
     (#("Mark McGwire" "Sammy Sosa" "Ken Griffey")
      #("Chicago Cubs" "St Louis Cardinals")))
    ("2.8.yaml"
     ((("time" . "20:03:20") ("player" . "Sammy Sosa")
       ("action" . "strike (miss)"))
      (("time" . "20:03:47") ("player" . "Sammy Sosa")
       ("action" . "grand slam"))))
    ("2.9.yaml"
     ((("hr" . #("Mark McGwire" "Sammy Sosa"))
       ("rbi" . #("Sammy Sosa" "Ken Griffey")))))
    ("2.10.yaml"
     ((("hr" . #("Mark McGwire" "Sammy Sosa"))
       ("rbi" . #("Sammy Sosa" "Ken Griffey")))))
    ("2.11.yaml"
     (((#("Detroit Tigers" "Chicago cubs") . #("2001-07-23"))
       (#("New York Yankees" "Atlanta Braves")
        . #("2001-07-02" "2001-08-12" "2001-08-14")))))
    ("2.12.yaml"
     (#((("item" . "Super Hoop") ("quantity" . 1))
        (("item" . "Basketball") ("quantity" . 4))
        (("item" . "Big Shoes") ("quantity" . 1)))))
    ("2.13.yaml"
     ("\\//||\\/||\n// ||  ||__\n"))
    ("2.14.yaml"
     ("Mark McGwire's year was crippled by a knee injury.\n"))
    ("2.15.yaml"
     ("Sammy Sosa completed another fine season with great stats.\n\n  63 Home Runs\n  0.288 Batting Average\n\nWhat a year!\n"))
    ("2.16.yaml"
     ((("name" . "Mark McGwire")
       ("accomplishment" . "Mark set a major league home run record in 1998.\n")
       ("stats" . "65 Home Runs\n0.278 Batting Average\n"))))
    ("2.17.yaml"
     ((("unicode" . "Sosa did fine.☺")
       ("control" . "\x08;1998\t1999\t2000\n")
       ("hex esc" . "\r\n is \r\n")
       ("single" . "\"Howdy!\" he cried.")
       ("quoted" . " # Not a 'comment'.")
       ("tie-fighter" . "|\\-*-/|"))))
    ("2.18.yaml"
     ((("plain" . "This unquoted scalar spans many lines.")
       ("quoted" . "So does this quoted scalar.\n"))))
    ("2.19.yaml"
     ((("canonical" . 12345) ("decimal" . 12345)
       ("octal" . 12) ("hexadecimal" . 12))))
    ("2.20.yaml"
     ((("canonical" . 1230.15) ("exponential" . 1230.15)
       ("fixed" . 1230.15) ("negative infinity" . -inf.0)
       ("not a number" . +nan.0))))
    ("2.21.yaml"
     (((null . null) ("booleans" . #(#t #f)) ("string" . "012345"))))
    ("2.22.yaml"
     ((("canonical" . "2001-12-15T02:59:43.1Z")
       ("iso8601" . "2001-12-14t21:59:43.10-05:00")
       ("spaced" . "2001-12-14 21:59:43.10 -5")
       ("date" . "2002-12-14"))))
    ("2.23.yaml"
     ((("not-date" . "2002-04-28")
       ("picture" . "R0lGODlhDAAMAIQAAP//9/X\n17unp5WZmZgAAAOfn515eXv\n\
                     Pz7Y6OjuDg4J+fn5OTk6enp\n56enmleECcgggoBADs=\n")
       ("application specific tag"
        . "The semantics of the tag\nabove may be different for\n\
           different documents.\n"))))
    ("2.24.yaml"
     (#((("center" ("x" . 73) ("y" . 129)) ("radius" . 7))
        (("start" ("x" . 73) ("y" . 129))
         ("finish" ("x" . 89) ("y" . 102)))
        (("start" ("x" . 73) ("y" . 129)) ("color" . 16772795)
         ("text" . "Pretty vector drawing.")))))
    ("2.25.yaml"
     ((("Mark McGwire" . null) ("Sammy Sosa" . null) ("Ken Griffey" . null))))
    ("2.26.yaml"
     (#((("Mark McGwire" . 65)) (("Sammy Sosa" . 63))
        (("Ken Griffey" . 58)))))
    ("2.27.yaml"
     ((("invoice" . 34843)
       ("date" . "2001-01-23")
       ("bill-to" ("given" . "Chris") ("family" . "Dumars")
                  ("address" ("lines" . "458 Walkman Dr.\nSuite #292\n")
                             ("city" . "Royal Oak") ("state" . "MI")
                             ("postal" . 48046)))
       ("ship-to" ("given" . "Chris") ("family" . "Dumars")
                  ("address" ("lines" . "458 Walkman Dr.\nSuite #292\n")
                             ("city" . "Royal Oak") ("state" . "MI")
                             ("postal" . 48046)))
       ("product" . #((("sku" . "BL394D") ("quantity" . 4)
                       ("description" . "Basketball") ("price" . 450.0))
                      (("sku" . "BL4438H") ("quantity" . 1)
                       ("description" . "Super Hoop") ("price" . 2392.0))))
       ("tax" . 251.42)
       ("total" . 4443.52)
       ("comments" . "Late afternoon is best. \
                      Backup contact is Nancy Billsmer @ 338-4338."))))
    ("2.28.yaml"
     ((("Time" . "2001-11-23 15:01:42 -5") ("User" . "ed")
       ("Warning" . "This is an error message for the log file"))
      (("Time" . "2001-11-23 15:02:31 -5") ("User" . "ed")
       ("Warning" . "A slightly different error message."))
      (("Date" . "2001-11-23 15:03:17 -5") ("User" . "ed")
       ("Fatal" . "Unknown variable \"bar\"")
       ("Stack" . #((("file" . "TopClass.py") ("line" . 23)
                     ("code" . "x = MoreObject(\"345\\n\")\n"))
                    (("file" . "MoreClass.py") ("line" . 58)
                     ("code" . "foo = bar")))))))
    ))

(dolist [e *examples*]
  (test* #"yaml-parse-file ~(car e)" (cadr e)
         (yaml-parse-file (build-path *example-dir* (car e)))))

;; Guard against an example file that's not tested.
(test* "all example files are accounted for" '()
       (let1 covered (map car *examples*)
         (filter (^f (not (member f covered)))
                 (sort (map sys-basename
                            (glob (build-path *example-dir* "*.yaml")))))))

;; 2.27 aliases a mapping twice; the alias must yield the very node the
;; anchor labels, not a copy of it.
(test* "yaml-parse-file 2.27.yaml (alias shares the node)" #t
       (let1 doc (car (yaml-parse-file
                       (build-path *example-dir* "2.27.yaml")))
         (eq? (cdr (assoc "bill-to" doc)) (cdr (assoc "ship-to" doc)))))

(test-end :exit-on-failure #t)
