;;
;; Package Gauche-text-yaml
;;

(define-gauche-package "Gauche-text-yaml"
  ;;
  :version "1.0"

  ;; Description of the package.  The first line is used as a short
  ;; summary.
  :description "Parse/generate yaml.\n\
                Using libyaml."

  ;; List of dependencies.
  :require (("Gauche" (>= "0.9.11-p1")))

  ;; List of providing modules
  :providing-modules (text.yaml)

  ;; List name and contact info of authors.
  :authors ("Shiro Kawai <shiro@acm.org>")

  ;; List name and contact info of package maintainers, if they differ
  :maintainers ()

  ;; List licenses
  :licenses ("BSD")

  ;; Homepage URL, if any.
  ; :homepage "http://example.com/Gauche-text-yaml/"

  ;; Repository URL, e.g. github
  :repository "https://github.com/shirok/Gauche-text-yaml.git"
  )
