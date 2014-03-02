(defsystem lisp-stripper
  :description "Count lines of actual code in Common Lisp source"
  :license "MIT"
  :depends-on ((:version :asdf "3.1") :cl-ppcre)
  :components ((:file "lisp-stripper")))

