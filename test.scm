;;;
;;; Test text.yaml
;;;

(use gauche.test)

(test-start "text.yaml")
(use text.yaml)
(test-module 'text.yaml)

;; The following is a dummy test code.
;; Replace it for your tests.
(test* "test-gauche_text_yaml" "gauche_text_yaml is working"
       (test-gauche_text_yaml))

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)
