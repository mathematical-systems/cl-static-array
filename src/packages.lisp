(in-package :cl-user)

(defpackage :static-array
    (:use :cl)
  (:nicknames :sa)
  (:shadow :aref
           )
  (:export :static-array
           ))

