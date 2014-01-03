(defsystem lisp-stripper
  :description "Count lines of actual code in Common Lisp source"
  :license "MIT"
  :depends-on (#-asdf3 :uiop :cl-ppcre)
  :components ((:file "lisp-stripper")))

