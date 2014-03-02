;; Strip comments and strings, count the non-empty lines

(defpackage :lisp-stripper
  (:use :cl :uiop :cl-ppcre)
  (:export
   #:count-lisp-loc #:count-lisp-locs
   #:strip-lisp #:strip-file #:count-lines))

(in-package :lisp-stripper)

(defun count-lines (s)
  (with-input (s)
    (loop while (read-line s nil nil) sum 1)))

(defun strip-empty-lines (s)
  (cl-ppcre:regex-replace-all "(\\n[ \\t]*(\"\")?[ \\t]*)+\\n" s "
"))

(defun eolp (c)
  (and (position c #(#\linefeed #\return nil)) t))

(defun blankp (c)
  (and (find c #(#\space #\tab #\page)) t))

(defun first-line (s)
  (if-let (p (position-if #'eolp s))
    (subseq s 0 p)
    s))

(defun read-blanks (in)
  (loop :with blanks = (make-string-output-stream)
        :for c = (read-char in nil nil)
        :while (blankp c) :do (princ c blanks)
        :finally (when c (unread-char c in))
                 (return (get-output-stream-string blanks))))

(defun strip-lisp (in &key out)
  (nest
   (with-input (in))
   (with-output (out))
   (let (leading-blanks blanks-so-far))
   (labels
       ((in ()
          (read-char in nil nil))
        (unin (c)
          (unread-char c in))
        (out (x)
          (when x (princ x out)))
        (bol ()
          (setf leading-blanks (read-blanks in)
                blanks-so-far t))
        (flush-blanks! ()
          (when blanks-so-far
            (out leading-blanks)
            (setf blanks-so-far nil))))
     (bol))
   (loop for c = (in) do)
   (cond
     ((eolp c)
      (unless blanks-so-far ;; strip blank lines
        (out c))
      (if c
          (bol)
          (return)))
     ((eql c #\")
      (unin c)
      (let ((string (first-line (read-preserving-whitespace in)))
            (trailing-blanks (read-blanks in))
            (next (in)))
        (cond
          ((and blanks-so-far (eolp next)) ;; strip strings that are alone on their line
           (bol))
          (t
           (unin next)
           (flush-blanks!)
           (write string :stream out)
           (out trailing-blanks)))))
     ((eql c #\;) ;; strip comments
      (loop :for c = (in) :until (eolp c) :finally
        (unless blanks-so-far (out c))) ;; strip lines with just comments
      (bol))
     ((eql c #\#)
      (flush-blanks!)
      (out c)
      (let ((c (in)))
        (if (eql c #\\)
            (let ((d (in)))
              (out c) (out d))
            (unin c))))
     (t
      (flush-blanks!)
      (out c)))))

(defun count-lisp-loc (input)
  (with-input (input)
    (count-lines (strip-lisp input))))

(defun print-count (count &optional filename)
  (format t "~10D~@[  ~A~]~%" count filename))

(defun print-loc-count (file)
  (print-count (count-lisp-loc (ensure-pathname file :namestring :native)) file))

(defun strip-file (file &optional (out *standard-output*))
  (princ (strip-lisp (read-file-string file)) out))

