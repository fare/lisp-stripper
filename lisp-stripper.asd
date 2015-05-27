(defsystem lisp-stripper
  :version "1.0.0"
  :description "Count lines of actual code in Common Lisp source"
  :author "Francois-Rene Rideau"
  :license "MIT"
  :depends-on ((:version :asdf "3.1") :cl-ppcre)
  :components ((:file "lisp-stripper")))

