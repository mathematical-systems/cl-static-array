(in-package :cl-user)

(asdf:defsystem cl-static-array
  :description "Native static array support for CL implementations"
  :author "MSI"
  :version "0.1.20100426"
  :depends-on (:alexandria :cffi)
  :components
  ((:module src
	    :components ((:file "packages")
                         (:file "environment")
                         (:file "utils")
                         (:file "type" :depends-on ("utils"))
			 (:file "array" :depends-on ("type"))
                         (:file "sequence" :depends-on ("array")))
	    :serial t
	    )))

