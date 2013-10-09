#|
  This file is a part of pddl.component-abstraction project.
  Copyright (c) 2013 Masataro Asai
|#

(in-package :cl-user)
(defpackage pddl.component-abstraction-test-asd
  (:use :cl :asdf))
(in-package :pddl.component-abstraction-test-asd)

(defsystem pddl.component-abstraction-test
  :author "Masataro Asai"
  :license ""
  :depends-on (:pddl.component-abstraction
               :pddl.instances
               :pddl.instances.cell-assembly-eachparts
               :pddl.instances.rover
               :pddl.instances.woodworking
               :guicho-utilities
               :repl-utilities
               :fiveam)
  :components ((:module "t"
                :components
                ((:file "pddl.component-abstraction"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
