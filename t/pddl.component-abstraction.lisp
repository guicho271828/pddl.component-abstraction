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

(cleanup-pddlfasl)
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
          ("woodworking" "p01.pddl")
          ("logistics" "domain.pddl")
          ("logistics" "p01.pddl")
          ("depot" "domain.pddl")
          ("depot" "p01.pddl"))))

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

    (is-true (abstract-type=/fast ac0 ac1))

    #+nil
    (progn
      (is-true (abstract-type= ac0 ac1))
      (is-true (abstract-type<= ac0 ac1))
      (is-true (abstract-type<= ac1 ac0))
      (is-true (abstract-type<=> ac1 ac0))
      (is-false (abstract-type< ac1 ac0))
      (is-false (abstract-type< ac0 ac1)))

    (is-false (abstract-type=/fast ac0 ac2))
    ;; after the addition, ac0 > ac2
    #+nil
    (progn
      (is-false (abstract-type= ac0 ac2))
      (is-true (abstract-type<= ac2 ac0))
      (is-false (abstract-type<= ac0 ac2))
      (is-true (abstract-type<=> ac2 ac0))
      (is-false (abstract-type< ac0 ac2))
      (is-true (abstract-type< ac2 ac0)))

 
    (is-false (abstract-type=/fast ac3 ac2))
    #+nil
    (progn
      (is-false (abstract-type= ac3 ac2))
      (is-false (abstract-type<= ac3 ac2))
      (is-false (abstract-type<= ac2 ac3))
      (is-false (abstract-type<=> ac2 ac3))
      (is-false (abstract-type< ac2 ac3))
      (is-false (abstract-type< ac3 ac2)))))

;; integration tests
(test :cluster-objects
  ;; preparation
  (let ((*problem* roverprob03)
        (*domain* rover))
    (finishes
      (cluster-objects (static-facts roverprob03)
                       (static-predicates roverprob03)))
    ;; main function

    #+nil
    (finishes
      (abstract-components roverprob03))
    #+nil
    (finishes
      (best-abstract-components roverprob03)))

  #+nil
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

  #+nil
  (finishes
    (abstract-tasks roverprob03 :rover))

  ;; (finishes
  ;;   (mapcar (rcurry #'categorize-tasks :loose)
  ;;           (abstract-tasks roverprob03 :rover)))


  ;; regression test : what if :passenger has no static edges??
  #+nil
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

(defun typenum (prob dom typename)
  (length (remove-if-not
           (lambda (ot)
             (pddl-supertype-p (query-type dom typename) ot))
           (objects prob)
           :key #'type)))

(test :type-predicate
  (is (= 6 (length (type-predicates logistics))))
  (is (= 17 (length (type-facts logistics-4-0))))
  ;;
  (is (= 30 (length (init logistics-4-0))))
  (is (= 15 (length (objects logistics-4-0))))
  (multiple-value-bind
      (lp-typed log-typed) (add-types logistics-4-0)
    (is (= 6 (length (types log-typed))))
    (is (= 3 (length (predicates log-typed)))) 
    (is (= 15 (length (init lp-typed))))
    ;;
    (is (= 6 (typenum lp-typed log-typed :package)))
    (is (= 2 (typenum lp-typed log-typed :truck)))
    ;; 2 of 4 are mixins with airport
    (is (= 2 (typenum lp-typed log-typed :location)))
    (is (= 1 (typenum lp-typed log-typed :airplane)))
    (is (= 2 (typenum lp-typed log-typed :airport)))
    (is (= 2 (typenum lp-typed log-typed :city)))
    ;; (print-pddl-object log-typed *standard-output*)
    ;; (print-pddl-object lp-typed *standard-output*)
    )

  ;; types thats truely informative is only 5:
  ;; truck, place, hoist, crate, surface
  (is (= 15 (length (predicates depot))))
  (is (= 5 (length (type-predicates depot))))
  (is (= 15 (length (type-facts depotprob1818))))
  ;;
  (is (= 36 (length (init depotprob1818))))
  (is (= 13 (length (objects depotprob1818))))
  (multiple-value-bind
      (dp-typed d-typed) (add-types depotprob1818)
    (is (= 5 (length (types d-typed))))
    (is (= (- 15 5) (length (predicates d-typed))))
    (is (= (- 36 13) (length (init dp-typed))))
    ;;
    (is (= 2 (typenum dp-typed d-typed :truck)))
    (is (= 3 (typenum dp-typed d-typed :place)))
    (is (= 3 (typenum dp-typed d-typed :hoist)))
    (is (= 0 (typenum dp-typed d-typed :crate))) ;; mixin with surface
    (is (= 5 (typenum dp-typed d-typed :surface)))
    ;; (print-pddl-object d-typed *standard-output*)
    ;; (print-pddl-object dp-typed *standard-output*)
    ))

