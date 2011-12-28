(in-package :static-array)

(defstruct (static-array-object
             (:conc-name sa-))
  pointer
  length
  size ; just for the convenience of passing size to foreign functions
  dimensions
  element-type
  foreign-type)

(defun make-static-array-from-pointer (pointer dimensions element-type)
  (assert (find element-type +element-type-foreign-type-table+ :test 'equalp :key #'first))
  (let* ((pointer (ensure-pointer pointer))
         (dimensions (alexandria:ensure-list dimensions)))
    (assert (> (length dimensions) 0)
            nil
            ":dimensions must be an integer or a list of integers. Current value: ~a"
            dimensions)
    (destructuring-bind (foreign-type element-size)
        (cdr (assoc element-type +element-type-foreign-type-table+ :test #'equal))
      (let* ((length (reduce #'* dimensions)))
        (make-static-array-object :pointer pointer
                                  :length length
                                  :size (* element-size length)
                                  :dimensions dimensions
                                  :element-type element-type
                                  :foreign-type foreign-type)))))

(defun make-static-array (dimensions element-type
                          &key (initial-element nil initial-element-p)
                          initial-contents null-terminated-p)
  (assert (find element-type +element-type-foreign-type-table+ :test 'equalp :key #'first))
  (let* ((dimensions (alexandria:ensure-list dimensions))
         (foreign-type (second (assoc element-type +element-type-foreign-type-table+ :test #'equal)))
         (length (reduce #'* dimensions))
         (ptr (if initial-element-p
                  (cffi:foreign-alloc
                   foreign-type
                   :count length
                   :initial-element initial-element
                   :null-terminated-p null-terminated-p)
                  (cffi:foreign-alloc
                   foreign-type
                   :count length
                   :initial-contents initial-contents
                   :null-terminated-p null-terminated-p))))
    (assert (> (length dimensions) 0))
    (make-static-array-from-pointer ptr dimensions element-type)))

(defun compute-offset (static-array indices)
  (assert (= (length (sa-dimensions static-array))
             (length indices)))
  (with-slots (dimensions) static-array
    (let ((offset 0))
      (declare (type array-index offset))
      (loop for s in (sa-dimensions static-array)
            for i in indices
            do
         (setf offset (+ (* offset s) i)))
      offset)))

(defun sa-aref (static-array &rest indices)
  (declare (dynamic-extent indices))
  (cffi:mem-aref (sa-pointer static-array)
                 (sa-foreign-type static-array)
                 (compute-offset static-array indices)))

(defun (setf sa-aref) (newval static-array &rest indices)
  (declare (dynamic-extent indices))
  (setf (cffi:mem-aref (sa-pointer static-array)
                       (sa-foreign-type static-array)
                       (compute-offset static-array indices))
        newval))


;;; CL standard array function wrapper

#+nil
(defparameter +sa-type-object+
  (let ((type (excl::type-canonicalize 'static-array-object)))
    (assert (not (eq type t)))
    type))

(defun aref (array &rest indices)
  (declare (dynamic-extent indices))
  (typecase array
    (static-array-object
       (apply #'sa-aref array indices))
    (otherwise
       (apply #'cl:aref array indices))))

(define-compiler-macro aref (&whole form array &rest indices &environment env)
  (let* ((type (variable-type-information array env t)))
    (setf foo type)
    (cond ((eq type nil)
           `(sa-aref ,array ,@indices))
          ((subtypep type 'cl:array)
           `(cl:aref ,array ,@indices))
          (t
           form))))

