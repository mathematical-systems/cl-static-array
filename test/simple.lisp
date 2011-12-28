(in-package :static-array)

(defparameter *sa*
  (make-static-array (list 2 3) 'double-float :initial-contents '(0d0 1d0 2d0 3d0 4d0 5d0)))

(declaim (type (static-array double-float (* *)) *sa*))

(defun simple-test (array index)
  (declare (optimize speed (safety 0))
           ;; (type (simple-array double-float (* *)) array)
           (type (static-array double-float (* *)) array)
           (type fixnum index))
  (aref array 0 1)
  (aref array index index))
