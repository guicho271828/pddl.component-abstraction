
(in-package :pddl.component-abstraction)
(cl-syntax:use-syntax :annot)

;;; extracting static predicates

(defun all-instantiated-types (problem)
  (remove-duplicates (mapcar #'type (objects problem))))

(defun all-instantiated-predicates (*problem*)
  (let ((*domain* (domain *problem*)))
    (iter (for pred in (predicates *domain*))
          (for parameters
               = (mapcar
                  (lambda (p)
                    (remove-if-not
                     (rcurry #'pddl-supertype-p (type p))
                     (all-instantiated-types *problem*)))
                  (parameters pred)))
          (when parameters
            ;; note: when parameters are nil,
            ;; map-product throws an error 10/25
            (appending
             (apply
              #'map-product
              (lambda (&rest args)
                (pddl-predicate
                 :name (name pred)
                 :parameters
                 (mapcar (lambda (type)
                           (pddl-variable :name (gensym (symbol-name (symbolicate '? (name type))))
                                          :type type))
                         args)))
              parameters))))))

(defun fluent-predicate-p (predicate)
  (let ((*domain* (domain predicate)))
    (flet ((match (effect)
             (and (eqname predicate effect)
                  (predicate-more-specific-p predicate effect))))
      (some (lambda (action)
              (or (some #'match (add-list action))
                  (some #'match (delete-list action))))
            (actions *domain*)))))

(defun predicate-ignored-p-JAIR-2415 (predicate)
  "Ignores unary or 0-ary predicates"
  (match predicate
    ((pddl-atomic-state parameters)
     (or (< (length parameters) 2)
         (some-pair #'eq (mapcar #'type parameters))))
    ((pddl-function-state parameters)
     (or (< (length parameters) 1)
         (and (<= 2 (length parameters))
              (some-pair #'eq (mapcar #'type parameters)))))))

(defun static-facts (problem)
  (remove-if (disjoin ;; (rcurry #'typep 'pddl-function-state)
                      #'fluent-predicate-p
                      #'predicate-ignored-p-JAIR-2415)
             (init problem)))

(defun static-predicates (problem)
  (remove-if (disjoin #'fluent-predicate-p
                      #'predicate-ignored-p-JAIR-2415
                      ;; (lambda (pred)
                      ;;   (some (curry (conjoin #'eqname #'predicate-agrees-p) pred)
                      ;;         (static-facts problem)))
                      )
             (all-instantiated-predicates problem)))
