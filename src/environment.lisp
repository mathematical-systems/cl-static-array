;;;;; Portable environment wrapper

(in-package :static-array)

(defun variable-type-information (symbol &optional environment all-declarations)
  #+allegro (second (find 'cl:type (nth-value 2 (sys:variable-information symbol environment all-declarations)) :key #'first))
  #+sbcl (cdr (find 'cl:type (nth-value 2 (sb-cltl2:variable-information symbol environment)) :key #'first)))


