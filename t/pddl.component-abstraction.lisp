#|
  This file is a part of pddl.component-abstraction project.
  Copyright (c) 2013 Masataro Asai
|#

(in-package :cl-user)
(defpackage pddl.component-abstraction-test
  (:use :cl
        :pddl
        :pddl.component-abstraction
        :guicho-utilities
        :alexandria
        :iterate
        :fiveam)
  (:shadowing-import-from :pddl :minimize :maximize))
(in-package :pddl.component-abstraction-test)

(def-suite :pddl.component-abstraction)
(in-suite :pddl.component-abstraction)

(let ((*default-pathname-defaults*
       (asdf:system-relative-pathname
        :pddl.component-abstraction-test "t/")))
  (mapc (lambda (list)
          (destructuring-bind (dir pddl) list
            (handler-bind ((warning #'muffle-warning))
              (let ((path (merge-pathnames (format nil "~A/~A" dir pddl))))
                (print path)
                (multiple-value-bind (name val) (parse-file path)
                  (print name)
                  (print val)
                  (print (symbol-value name)))))))
        '(("cell-assembly-each" "domain.pddl")
          ("cell-assembly-each" "p0002.pddl")
          ("elevators" "domain.pddl")
          ("elevators" "p20.pddl")
          ("rover" "domain.pddl")
          ("rover" "p03.pddl")
          ("rover" "p10.pddl")
          ("woodworking" "domain.pddl")
          ("woodworking" "p01.pddl"))))

(test :predicate-connects-components
  (let* ((*domain* rover)
         (*problem* roverprob10)
         (waypoint (object *problem* :waypoint0))

         (c0 (object *problem* :camera0))
         (r0 (object *problem* :rover0))
         (s0 (object *problem* :rover0store))
         (rc0 (pddl-atomic-state :name 'rc :parameters (list c0 r0)))
         (sr0 (pddl-atomic-state :name 'sr :parameters (list s0 r0)))
         (rw0 (pddl-atomic-state :name 'rw :parameters (list r0 waypoint)))
         (ac0 (make-abstract-component :components (list r0)))
         
         (c1 (object *problem* :camera1))
         (r1 (object *problem* :rover1))
         (s1 (object *problem* :rover1store))
         (rc1 (pddl-atomic-state :name 'rc :parameters (list c1 r1)))
         (sr1 (pddl-atomic-state :name 'sr :parameters (list s1 r1)))
         (rw1 (pddl-atomic-state :name 'rw :parameters (list r1 waypoint)))
         (ac1 (make-abstract-component :components (list r1)))
         
         (c2 (object *problem* :camera2))
         (r2 (object *problem* :rover2))
         (s2 (object *problem* :rover2store))
         (rc2 (pddl-atomic-state :name 'rc :parameters (list c2 r2)))
         (sr2 (pddl-atomic-state :name 'sr :parameters (list s2 r2)))
         ;;(rw2 (pddl-atomic-state :name 'rw :parameters (list r2 waypoint)))
         (ac2 (make-abstract-component :facts (list sr2) :components (list r2 s2)))
         (ac3 (make-abstract-component :facts (list rc2) :components (list r2 c2)))
         
         (ac (list ac0 ac1)))

    (is-false (predicates-connect-components
               (list rc0 rc1) ac))

    ;; regression test
    (is-false (predicates-connect-components
               nil ac))
    ;; refression test
    (is-false (predicates-connect-components
               (list sr0 sr1) nil))
    (is-false (predicates-connect-components
               nil nil))

    (is-false (predicates-connect-components
               (list sr0 sr1) ac))
    
    (is-true (predicates-connect-components
               (list rw0 rw1) ac))

    (push c0 (parameters ac0))
    (push rc0 (abstract-component-facts ac0))
    (push c1 (parameters ac1))
    (push rc1 (abstract-component-facts ac1))
    
    (is-false (predicates-connect-components
               (list sr0 sr1) ac))
    
    (is-true (predicates-connect-components
               (list rw0 rw1) ac))

    (push s0 (parameters ac0))
    (push sr0 (abstract-component-facts ac0))
    (push s1 (parameters ac1))
    (push sr1 (abstract-component-facts ac1))
    
    (is-true (predicates-connect-components
              (list rw0 rw1) ac))

    (is-true (abstract-type= ac0 ac1))
    (is-true (abstract-type=/fast ac0 ac1))
    (is-true (abstract-type<= ac0 ac1))
    (is-true (abstract-type<= ac1 ac0))
    (is-true (abstract-type<=> ac1 ac0))
    (is-false (abstract-type< ac1 ac0))
    (is-false (abstract-type< ac0 ac1))

    ;; after the addition, ac0 > ac2
    (is-false (abstract-type= ac0 ac2))
    (is-false (abstract-type=/fast ac0 ac2))
    (is-true (abstract-type<= ac2 ac0))
    (is-false (abstract-type<= ac0 ac2))
    (is-true (abstract-type<=> ac2 ac0))
    (is-false (abstract-type< ac0 ac2))
    (is-true (abstract-type< ac2 ac0))


    (is-false (abstract-type= ac3 ac2))
    (is-false (abstract-type=/fast ac3 ac2))
    (is-false (abstract-type<= ac3 ac2))
    (is-false (abstract-type<= ac2 ac3))
    (is-false (abstract-type<=> ac2 ac3))
    (is-false (abstract-type< ac2 ac3))
    (is-false (abstract-type< ac3 ac2))
    ))

;; integration tests
(test :cluster-objects
  ;; preparation
  (finishes
    (cluster-objects (static-facts roverprob03)
                     (static-predicates roverprob03)))
  ;; main function
  (finishes
    (abstract-components roverprob03))
  (finishes
    (best-abstract-components roverprob03))

  (finishes
    (abstract-components-with-seed
     wood-prob-opt-1
     (query-type woodworking :part))
    (abstract-components-with-seed
     roverprob03
     (query-type rover :rover))
    (abstract-components-with-seed
     cell-assembly-model2a-each-2
     (query-type cell-assembly-eachparts :base)))

  (finishes
    (abstract-tasks roverprob03 :rover))

  ;; (finishes
  ;;   (mapcar (rcurry #'categorize-tasks :loose)
  ;;           (abstract-tasks roverprob03 :rover)))


  ;; regression test : what if :passenger has no static edges??
  (let ((passenger-type
         (query-type elevators-sequencedstrips :passenger)))
    (is (some
         (lambda (comp-bucket)
           (every (lambda (comp)
                    (eq passenger-type
                        (type (abstract-component-seed comp))))
                  comp-bucket))
         (abstract-components-with-seed
          ELEVATORS-SEQUENCEDSTRIPS-P40_60_1
          passenger-type)))))

