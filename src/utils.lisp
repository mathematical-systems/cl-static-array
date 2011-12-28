(in-package :static-array)

(deftype pointer ()
  #+64bit `(unsigned-byte 64)
  #-64bit `(unsigned-byte 32))

(deftype array-index () `(mod #.array-dimension-limit))

(defmacro defun-speedy (name lambda-list &body body)
  `(progn
     (declaim (inline ,name))
     (defun ,name ,lambda-list
       (declare (optimize speed)
		;; #+allegro (:faslmode :immediate)
                )
       ,@body)
     #+allegro
     (define-compiler-macro ,name ,lambda-list
       `(let (,,@(loop 
                   for n in lambda-list
                   when (not (find n '(&key &optional &rest &aux)))
                     collect ``(,',n ,,n)))
	  (declare (optimize speed))
	  ,@',body))

     ',name))


(defun ensure-pointer (pointer)
  #+allegro (progn
              (check-type pointer integer)
              pointer)
  #+sbcl (etypecase pointer
           (integer (cffi-sys:make-pointer pointer))
           (sb-sys:system-area-pointer pointer)))


