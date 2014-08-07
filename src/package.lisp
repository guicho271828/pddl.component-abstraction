#|
  This file is a part of pddl.component-abstraction project.
  Copyright (c) 2013 Masataro Asai
|#
(in-package :cl-user)
(defpackage pddl.component-abstraction
  (:use :cl :pddl :optima :alexandria :iterate
        :pddl.plan-optimizer
        :eazylazy
        :guicho-utilities)
  (:import-from :function-cache :defcached)
  (:shadow :minimize :maximize)
  (:export
   :predicates-connect-components
   :static-facts
   :static-predicates
   :cluster-objects))
