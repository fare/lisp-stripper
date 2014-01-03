(defsystem lisp-stripper
  :depends-on (#-asdf3 :uiop :cl-ppcre)
  :components ((:file "lisp-stripper")))

