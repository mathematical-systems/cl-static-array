(in-package :static-array)


;; NOTE: The following array element-types are supported.
;; (lisp-type cffi-type bytes)
(defconstant +element-type-foreign-type-table+
  '((single-float :float 4)
    (double-float :double 8)
    ;; (complex single-float 8)
    ;; (complex double-float 16)
    
    ((unsigned-byte 8) :uint8 1)
    ((unsigned-byte 16) :uint16 2)
    ((unsigned-byte 32) :uint32 4)
    ((unsigned-byte 64) :uint64 8)
    
    ((signed-byte 8) :int8 1)
    ((signed-byte 16) :int16 2)
    ((signed-byte 32) :int32 4)
    ((signed-byte 64) :int64 8)
    ))

(defun ensure-element-type (element-type)
  (find element-type +element-type-foreign-type-table+ :test #'equalp :key #'first))

#+nil
(deftype static-array (&optional element-type dimensions)
  (assert (or (eq element-type '*) (ensure-element-type element-type)))
  (etypecase dimensions
    (atom 'static-array-object)
    (list
       (assert (every #'(lambda (d) (or (eq d '*) (integerp d))) dimensions))
       'static-array-object)))

