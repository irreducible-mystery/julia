;;; mu4_battery.lisp — CARRIER #11: the mu4 object of julia-vs-lean/,
;;; re-carried into Common Lisp (SBCL).  Run:  sbcl --script mu4_battery.lisp
;;;
;;; The eleventh carrier, and the translation with the shortest distance to
;;; travel: Julia's own AST is an S-expression ((:call, :*, :k, :x) — see
;;; Meta.show_sexpr), its parser was written in femtolisp, and `julia --lisp`
;;; still opens that Lisp today.  This file is the family reunion: the same
;;; battery mu4_core.jl runs over its nine carriers, transcribed into the
;;; ancestor language, plus the probes only this host can pose.
;;;
;;; WHAT TRANSLATES UNCHANGED: the machinery (d3, d2, pentagon, gauge,
;;; coboundary census) written once, generic over a carrier record of
;;; first-class functions — the exact design mu4_core.jl used.  CL (mod x m)
;;; is floored like Julia's mod; the algebra carries over verbatim.
;;;
;;; WHAT THIS HOST CHANGES (each photographed below, in the act):
;;;   * "Equality is plural" gets LOUDER: Julia has ==/===/isapprox/isequal;
;;;     CL has eq/eql/equal/equalp AND numeric =.  And the plurality bites
;;;     on EXACT data here, not just floats: the matrix carrier under #'eq
;;;     stops being a group (fresh conses are never eq to stored ones),
;;;     while the symbol carrier under #'eq is fine (symbols are interned).
;;;     Same carrier, two equalities, two objects — no floats required.
;;;   * The Int64 = Z/2^64 finding DIES.  CL integers are exact bignums;
;;;     there is no wraparound to photograph.  Its death is the datum: that
;;;     julia-vs-lean finding was about the host, not the object, and
;;;     Z/2^64 is opt-in here (an explicit mod), never an ambush.
;;;   * A new collapse appears where Julia has none: (complex 1 0) IS the
;;;     integer 1 in CL (rational complexes canonicalize; CLHS 12.1.5.3).
;;;     The Gaussian-integer carrier's identity element is literally 1.
;;;     Float complexes do NOT collapse — same ring, two ontologies.
;;;
;;; ORACLE: every battery line is a kernel-verified C6_Twist.lean theorem,
;;; same as mu4_core.jl (ORACLE = true).  The float-exact carrier MUST
;;; disagree somewhere — its disagreement is a positive test.  Note the
;;; disagreement COUNT is not pinned: the els carry libm dirt
;;; (exp(i*pi/2)), and libm is a host fingerprint; Julia counted 13, this
;;; host counts what it counts.  Existence is the claim, not the census.
;;;
;;; Receipt: the pinned check count at the end, then the exit code.
;;; Exit 0 is evidence, never proof.

(defvar *exitcode* 0)
(defvar *nchecks* 0)
(defvar *check-names* nil)
(defconstant +expected-checks+ 36)

(defun check (name ok)
  (incf *nchecks*)
  (push name *check-names*)
  (unless ok (setf *exitcode* 1))
  (format t "  ~:[** FAIL **~;ok~]  ~a~%" (and ok t) name)
  ok)

;; --- soft-spot repair (audited-by-fifth, ported from the SQL carrier's
;; identical vulnerability): +expected-checks+ pins a COUNT, and a count
;; is gameable — 36 calls to (check "dummy-N" t) reproduces
;; "36/36 checks, exit 0" while checking nothing. Pin a hash of the
;; check NAMES (order-independent) too: a gutted or renamed battery now
;; fails even when the row count stays honest. Verified by construction:
;; a 36-line all-dummy battery passes the count gate and fails this one.
(defun names-digest (names)
  ;; sort then hash with SBCL's built-in sxhash composed over a sorted
  ;; list, printed as hex — no external deps, deterministic within a
  ;; run and reproducible across runs of the same input list. Masked to
  ;; 64 bits at every step so the accumulator cannot grow unboundedly
  ;; (a bignum digest is still deterministic, but an ever-widening
  ;; printed string is its own small instrument bug — avoided here).
  (let ((sorted (sort (copy-list names) #'string<))
        (mask (1- (expt 2 64))))
    (format nil "~(~16,'0x~)"
            (logand mask
                    (reduce (lambda (acc s)
                              (logand mask (logxor (* acc 1000003) (sxhash s))))
                            sorted :initial-value 0)))))
(defconstant +expected-names-digest+ "357266c49fe40fab")

;; ====================================================================
;; CARRIER RECORDS — a rep is data: first-class functions in a struct,
;; the load-bearing design decision of mu4_core.jl, native here.
;; Canonical labelling: k in 0..3 stands for i^k.
;; ====================================================================
(defstruct (rep (:conc-name rep-)) name els one mul inv sig eq)

(defun el   (r k)   (nth k (rep-els r)))
(defun req  (r x y) (funcall (rep-eq  r) x y))
(defun rmul (r x y) (funcall (rep-mul r) x y))
(defun rinv (r x)   (funcall (rep-inv r) x))
(defun rsig (r x)   (funcall (rep-sig r) x))

;; CARRIER L1 — interned symbols + literal Cayley table, compared by EQ.
;; The closest mirror of Lean's inductive U; identity equality is SOUND
;; here because symbols are interned atoms.
(defparameter *mul-tab*
  #2A((u1  ui  um1 umi) (ui  um1 umi u1) (um1 umi u1 ui) (umi u1 ui um1)))
(defparameter *conj-tab* #(u1 umi um1 ui))   ; same arms as inv — that IS conj_eq_inv
(defparameter *sym-els* '(u1 ui um1 umi))

(defun sym-rep (&key (mul-tab *mul-tab*) (conj-tab *conj-tab*)
                     (name "interned symbols + Cayley table (eq — sound on atoms)"))
  (let ((els *sym-els*))
    (flet ((pos (x) (position x els :test #'eq)))
      (make-rep :name name :els els :one 'u1
                :mul (lambda (x y) (aref mul-tab (pos x) (pos y)))
                :inv (lambda (x) (aref conj-tab (pos x)))
                :sig (lambda (x) (aref conj-tab (pos x)))
                :eq  #'eq))))

;; CARRIER L2 — native complex integers.  Julia had Complex{Int} in Base;
;; CL has the whole Gaussian ring in the numeric tower.  Fingerprint: the
;; identity element is the INTEGER 1 — (complex 1 0) canonicalizes to 1.
(defun gauss-rep ()
  (make-rep :name "native complex integers ((complex 1 0) IS 1 — see FPRINT)"
            :els (list 1 (complex 0 1) -1 (complex 0 -1)) :one 1
            :mul #'* :inv #'conjugate :sig #'conjugate :eq #'=))

;; CARRIER L3 — additive log form: mul is +, sigma is negation;
;; conj_eq_inv is definitional, exactly as in mu4_core.jl.
(defun log-rep ()
  (make-rep :name "integers mod 4 (log form — conj_eq_inv definitional)"
            :els '(0 1 2 3) :one 0
            :mul (lambda (x y) (mod (+ x y) 4))
            :inv (lambda (x) (mod (- x) 4))
            :sig (lambda (x) (mod (- x) 4))
            :eq  #'=))

;; CARRIER L4 — 2x2 integer matrices <J> as lists (a b c d);
;; sigma = transpose, inv = adjugate.  Structural equality (EQUAL).
(defun mat-mul (x y)
  (destructuring-bind (a b c d) x
    (destructuring-bind (e f g h) y
      (list (+ (* a e) (* b g)) (+ (* a f) (* b h))
            (+ (* c e) (* d g)) (+ (* c f) (* d h))))))
(defun mat-rep (&key (eq #'equal) (name "2x2 integer matrices <J> (sigma = transpose, equal)"))
  (make-rep :name name
            :els '((1 0 0 1) (0 -1 1 0) (-1 0 0 -1) (0 1 -1 0)) :one '(1 0 0 1)
            :mul #'mat-mul
            :inv (lambda (x) (destructuring-bind (a b c d) x (list d (- b) (- c) a)))
            :sig (lambda (x) (destructuring-bind (a b c d) x (list a c b d)))
            :eq  eq))

;; CARRIER L5 — permutations of 4 points (regular rep), mul = composition.
(defun perm-rep ()
  (make-rep :name "permutations of 4 points (regular rep, composition)"
            :els (loop for k below 4
                       collect (loop for j below 4 collect (mod (+ j k) 4)))
            :one '(0 1 2 3)
            :mul (lambda (p q) (loop for j below 4 collect (nth (nth j q) p)))
            :inv (lambda (p) (loop for i below 4 collect (position i p)))
            :sig (lambda (p) (loop for i below 4 collect (position i p)))
            :eq  #'equal))

;; CARRIER L6 — one-hot bitmasks: mul = bit rotation, sigma = xor-swap #x0A.
(defun bit-rep ()
  (flet ((bitk (x) (1- (integer-length x)))
         (swap (x) (if (or (= x 2) (= x 8)) (logxor x #x0A) x)))
    (make-rep :name "one-hot bitmasks (mul = bit rotation, sigma = xor #x0A)"
              :els '(1 2 4 8) :one 1
              :mul (lambda (x y) (ash 1 (mod (+ (bitk x) (bitk y)) 4)))
              :inv #'swap :sig #'swap :eq #'=)))

;; CARRIER L7 — exact rational angles mod 1: native rationals, no package.
(defun rat-rep ()
  (make-rep :name "rational angles mod 1 (native rationals: 0 1/4 1/2 3/4)"
            :els '(0 1/4 1/2 3/4) :one 0
            :mul (lambda (x y) (mod (+ x y) 1))
            :inv (lambda (x) (mod (- x) 1))
            :sig (lambda (x) (mod (- x) 1))
            :eq  #'=))

;; CARRIERS L8/L9 — the same double-float els under two equalities.
;; els = exp(i k pi/2) carry libm dirt, exactly as F64els did in Julia.
(defparameter *f64-els*
  (loop for k below 4 collect (exp (complex 0d0 (* k (/ pi 2))))))
(defun float-exact-rep ()
  (make-rep :name "complex doubles under exact = (MUST disagree)"
            :els *f64-els* :one (complex 1d0 0d0)
            :mul #'* :inv #'conjugate :sig #'conjugate :eq #'=))
(defun float-approx-rep ()
  (make-rep :name "same els under tolerant equality (must agree)"
            :els *f64-els* :one (complex 1d0 0d0)
            :mul #'* :inv #'conjugate :sig #'conjugate
            :eq  (lambda (x y) (< (abs (- x y)) 1d-9))))

;; ====================================================================
;; THE MACHINERY — transcribed 1:1 from mu4_core.jl (itself transcribed
;; 1:1 from C6_Twist.lean).  Written once, generic over the carrier.
;; Sym has 8 cells (0-based here), Gge has 4.
;; ====================================================================
(defun b2i (b) (if b 1 0))
(defun bxor (a b) (if a (not b) b))
(defun i3 (a b c) (+ (* 4 (b2i a)) (* 2 (b2i b)) (b2i c)))
(defun i2 (a b) (+ (* 2 (b2i a)) (b2i b)))
(defparameter +bools+ '(nil t))

(defun act (r tw a x) (if (and tw a) (rsig r x) x))

(defun d3 (r tw F a b c d)
  (rmul r (rmul r (rmul r (rmul r (act r tw a (svref F (i3 b c d)))
                                  (rinv r (svref F (i3 (bxor a b) c d))))
                          (svref F (i3 a (bxor b c) d)))
                  (rinv r (svref F (i3 a b (bxor c d)))))
          (svref F (i3 a b c))))

(defun d2 (r tw g a b c)
  (rmul r (rmul r (act r tw a (svref g (i2 b c)))
                  (rinv r (svref g (i2 (bxor a b) c))))
          (rmul r (svref g (i2 a (bxor b c)))
                  (rinv r (svref g (i2 a b))))))

(defmacro for-all-abcd (bindings &body body)
  (declare (ignore bindings))
  `(loop for a in +bools+ always
     (loop for b in +bools+ always
       (loop for c in +bools+ always
         (loop for d in +bools+ always (progn ,@body))))))

(defun cocyclep (r tw F)
  (for-all-abcd () (req r (d3 r tw F a b c d) (rep-one r))))

(defun pentagonp (r F)
  (for-all-abcd ()
    (req r (rmul r (rmul r (svref F (i3 a b c)) (svref F (i3 a (bxor b c) d)))
                 (svref F (i3 b c d)))
          (rmul r (svref F (i3 (bxor a b) c d)) (svref F (i3 a b (bxor c d)))))))

(defun gauge (r n)
  (let ((g (make-array 4)))
    (loop for w in '(1 4 16 64) for idx from 0
          do (setf (svref g idx) (el r (mod (floor n w) 4))))
    g))

(defun d2image (r tw g)
  (let ((out (make-array 8)))
    (loop for a in +bools+ do
      (loop for b in +bools+ do
        (loop for c in +bools+ do
          (setf (svref out (i3 a b c)) (d2 r tw g a b c)))))
    out))

(defun symeq (r F G) (loop for i below 8 always (req r (svref F i) (svref G i))))

(defun coboundaryp (r tw F)
  (loop for n below 256 thereis (symeq r (d2image r tw (gauge r n)) F)))

(defun count-b (r tw)
  (let ((reps nil))
    (loop for n below 256
          for img = (d2image r tw (gauge r n))
          do (unless (find-if (lambda (s) (symeq r img s)) reps)
               (push img reps)))
    (length reps)))

(defun one-vec (r) (make-array 8 :initial-element (rep-one r)))

(defun count-ker (r tw)
  (loop for n below 256 count (symeq r (d2image r tw (gauge r n)) (one-vec r))))

(defun cob-are-cocycles (r tw)
  (loop for n below 256 always (cocyclep r tw (d2image r tw (gauge r n)))))

(defun topcell (r u)
  (let ((F (one-vec r))) (setf (svref F 7) u) F))

(defun twisted-boson (r)
  (let ((F (one-vec r)))
    (loop for a in +bools+ do
      (loop for b in +bools+ do
        (loop for c in +bools+ do
          (setf (svref F (i3 a b c))
                (if c (if b (el r 1) (el r 3)) (el r 0))))))
    F))

(defun fake-cocycle (r)
  (let ((F (one-vec r)))
    (loop for a in +bools+ do
      (loop for b in +bools+ do
        (loop for c in +bools+ do
          (setf (svref F (i3 a b c))
                (if (and (not a) (not b) c) (el r 1) (el r 0))))))
    F))

(defun g-fermion-g (r)
  (let ((g (make-array 4)))
    (loop for a in +bools+ do
      (loop for b in +bools+ do
        (setf (svref g (i2 a b)) (if (and a b) (el r 1) (el r 0)))))
    g))

(defun realp-el (r x) (or (req r x (el r 0)) (req r x (el r 2))))

(defun twist-vanishes-on-reals (r)
  (loop for code below 256 always
    (let ((F (make-array 8)))
      (loop for i below 8
            do (setf (svref F i) (if (logbitp i code) (el r 2) (el r 0))))
      (for-all-abcd () (req r (d3 r t F a b c d) (d3 r nil F a b c d))))))

;; ====================================================================
;; THE BATTERY — the C6_Twist theorem list, names verbatim from mu4_core.jl.
;; ====================================================================
(defun battery (r)
  (let ((B (topcell r (el r 0))) (S (topcell r (el r 1)))
        (I (topcell r (el r 2))) (M (topcell r (el r 3)))
        (N (twisted-boson r)) (K (fake-cocycle r)) (gF (g-fermion-g r)))
    (list
     (cons "conj_eq_inv"
           (loop for x in (rep-els r) always (req r (rsig r x) (rinv r x))))
     (cons "conj_is_the_inverse"
           (loop for x in (rep-els r) always (req r (rmul r x (rsig r x)) (rep-one r))))
     (cons "sigma_ne_id"
           (loop for x in (rep-els r) thereis (not (req r (rsig r x) x))))
     (cons "row_one_untwisted"  (and (cocyclep r nil B) (coboundaryp r nil B)))
     (cons "row_one_twisted"    (and (cocyclep r t   B) (coboundaryp r t   B)))
     (cons "row_i_untwisted"    (not (cocyclep r nil S)))
     (cons "row_i_twisted"      (and (cocyclep r t S) (not (coboundaryp r t S))))
     (cons "row_neg1_untwisted" (and (cocyclep r nil I) (not (coboundaryp r nil I))))
     (cons "row_neg1_twisted"   (and (cocyclep r t   I) (coboundaryp r t I)))
     (cons "row_negi_untwisted" (not (cocyclep r nil M)))
     (cons "row_negi_twisted"   (and (cocyclep r t M) (not (coboundaryp r t M))))
     (cons "fermion_is_sigma_coboundary" (symeq r (d2image r t gF) I))
     (cons "fermion_not_untwisted_cob"   (not (coboundaryp r nil I)))
     (cons "twistedBoson_pentagon"          (pentagonp r N))
     (cons "twistedBoson_not_sigma_cocycle" (not (cocyclep r t N)))
     (cons "twistedBoson_untwisted_cocycle" (cocyclep r nil N))
     (cons "twistedBoson_gauge_trivial"     (coboundaryp r nil N))
     (cons "sliceI_fails_pentagon"       (not (pentagonp r S)))
     (cons "sliceI_is_sigma_cocycle"     (cocyclep r t S))
     (cons "sliceI_not_sigma_coboundary" (not (coboundaryp r t S)))
     (cons "fakeCocycle_fails_both"
           (and (not (pentagonp r K)) (not (cocyclep r t K))))
     (cons "conj_fixes_reals"
           (loop for x in (rep-els r)
                 always (or (not (realp-el r x)) (req r (rsig r x) x))))
     (cons "twist_vanishes_on_reals(256 F)" (twist-vanishes-on-reals r))
     (cons "B3_untwisted == 16"  (= (count-b r nil) 16))
     (cons "B3_twisted == 32"    (= (count-b r t)   32))
     (cons "ker_untwisted == 16" (= (count-ker r nil) 16))
     (cons "ker_twisted == 8"    (= (count-ker r t)    8))
     (cons "cob_subset_cocycles_untw" (cob-are-cocycles r nil))
     (cons "cob_subset_cocycles_tw"   (cob-are-cocycles r t)))))

(defun battery-bad (r)
  (loop for (name . v) in (battery r) unless v collect name))

;; iso to canonical Z/4 — Lean's four bridge theorems, checked by running.
(defun iso-ok-p (r)
  (let ((sigk #(0 3 2 1)))
    (and (loop for x below 4 always
           (loop for y below 4 always
             (req r (el r (mod (+ x y) 4)) (rmul r (el r x) (el r y)))))
         (loop for x below 4 always (req r (el r (aref sigk x)) (rsig r (el r x))))
         (loop for x below 4 always (req r (el r (mod (- x) 4)) (rinv r (el r x))))
         (req r (el r 0) (rep-one r))
         (loop for i below 4 always
           (loop for j below 4 always
             (or (= i j) (not (req r (el r i) (el r j)))))))))

;; ====================================================================
;; PART A — one object, seven exact Lisp carriers
;; ====================================================================
(format t "~%=== A. one Lean object, seven exact Lisp carriers ===~%")
(dolist (r (list (sym-rep) (gauss-rep) (log-rep) (mat-rep) (perm-rep)
                 (bit-rep) (rat-rep)))
  (format t "--- ~a~%" (rep-name r))
  (check "  bridge to canonical Z/4 holds" (iso-ok-p r))
  (let ((bad (battery-bad r)))
    (check (format nil "  battery 29/29 agree with the Lean kernel~@[  (bad: ~a)~]" bad)
           (null bad))))

;; ====================================================================
;; PART B — same carrier, different equality (the julia-vs-lean row 8/9
;; experiment, and this host's sharper version of it)
;; ====================================================================
(format t "~%=== B. same carrier, different equality ===~%")
(let* ((bad (battery-bad (float-exact-rep)))
       (z (nth 1 *f64-els*)))
  (format t "--- float exact =: disagrees on ~d lines: ~a~%" (length bad) bad)
  (format t "    because i*i = ~a  (/= -1 exactly; libm dirt is host-specific)~%" (* z z))
  (check "float-exact MUST disagree somewhere" (not (null bad))))
(check "float-approx agrees everywhere" (null (battery-bad (float-approx-rep))))

;; The Lisp escalation: equality plurality bites EXACT data.  The matrix
;; carrier under #'eq stops being a group — mat-mul conses fresh lists,
;; and no fresh list is ever eq to a stored one.  The symbol carrier
;; passed under #'eq in Part A because symbols are interned.  Same
;; elements, same tables, two equalities, two objects — no floats needed.
(let ((bad (battery-bad (mat-rep :eq #'eq :name "matrices under eq"))))
  (format t "--- matrices under eq: disagrees on ~d of 29 lines~%" (length bad))
  (check "matrix carrier under eq MUST disagree (fresh conses)" (not (null bad))))

;; ====================================================================
;; PART C — equality is MORE plural here: five predicates, five verdicts
;; ====================================================================
(format t "~%=== C. eq / eql / equal / equalp / = on the same data ===~%")
(let ((s (copy-seq "ab")))
  (check "eq: fresh structurally-equal strings are NOT eq" (not (eq s (copy-seq s))))
  (check "equal: the same strings ARE equal" (equal s (copy-seq s))))
(check "eql: 1 and 1.0d0 differ (type-strict)" (not (eql 1 1.0d0)))
(check "equalp: 1 and 1.0d0 agree (coercing)" (equalp 1 1.0d0))
(check "=: 1 and 1.0d0 agree (numeric)" (= 1 1.0d0))

;; ====================================================================
;; PART D — the machine-integer court: the Z/2^64 finding dies here.
;; julia-vs-lean Part E photographed typemax(Int64)+1 wrapping silently.
;; This host has nothing to photograph: integers are exact bignums, and
;; the ring you didn't order cannot be delivered.  Z/2^64 is opt-in.
;; ====================================================================
(format t "~%=== D. machine integers: the wraparound finding has no analogue ===~%")
(check "(expt 2 64) is exact (no wrap exists)"
       (= (expt 2 64) 18446744073709551616))
(check "most-positive-fixnum + 1 promotes to bignum, does not wrap"
       (and (> (+ most-positive-fixnum 1) most-positive-fixnum)
            (not (typep (+ most-positive-fixnum 1) 'fixnum))))
(check "Z/2^64 is opt-in: explicit (mod _ (expt 2 64)) wraps on request"
       (zerop (mod (+ (1- (expt 2 64)) 1) (expt 2 64))))

;; ====================================================================
;; PART E — THE EXTENSION, re-run: the 4^8 = 65536-symbol sweep the Lean
;; kernel could not survive (log form, floored mod, as in run_all.jl).
;; ====================================================================
(format t "~%=== E. the 65536-symbol sweep (Lean's kernel died; carriers don't) ===~%")
(defun gi3 (a b c) (+ (* 4 a) (* 2 b) c))
(defun d3full (tw F a b c d)
  (let ((lead (svref F (gi3 b c d))))
    (when (and tw (= a 1)) (setf lead (mod (- lead) 4)))
    (mod (+ lead (- (svref F (gi3 (logxor a b) c d)))
            (svref F (gi3 a (logxor b c) d))
            (- (svref F (gi3 a b (logxor c d))))
            (svref F (gi3 a b c)))
         4)))
(defun cocN (tw F)
  (loop for a below 2 always (loop for b below 2 always
    (loop for c below 2 always (loop for d below 2 always
      (zerop (d3full tw F a b c d)))))))
(defun pentN (F)
  (loop for a below 2 always (loop for b below 2 always
    (loop for c below 2 always (loop for d below 2 always
      (zerop (mod (+ (svref F (gi3 a b c)) (svref F (gi3 a (logxor b c) d))
                     (svref F (gi3 b c d)) (- (svref F (gi3 (logxor a b) c d)))
                     (- (svref F (gi3 a b (logxor c d)))))
                  4)))))))
(let ((zu 0) (zt 0) (shared 0) (piff t) (F (make-array 8)))
  (loop for code below 65536 do
    (let ((cc code))
      (loop for i below 8 do (setf (svref F i) (logand cc 3) cc (ash cc -2))))
    (let ((cu (cocN nil F)) (ct (cocN t F)))
      (when cu (incf zu)) (when ct (incf zt))
      (when (and cu ct) (incf shared))
      (unless (eq (pentN F) cu) (setf piff nil))))
  (format t "    |Z3| untwisted=~d  twisted=~d  shared=~d~%" zu zt shared)
  (check "|Z3| untwisted = 32" (= zu 32))
  (check "|Z3| twisted   = 64" (= zt 64))
  (check "shared         =  8" (= shared 8))
  (check "pentagon <-> untwisted-cocycle over ALL 65536" piff))

;; ====================================================================
;; PART F — gd3, the fully generic form, as a higher-order function at
;; Z/6 (untouched by Lean).  Twist invisible on the fixed locus {0,3}
;; of negation mod 6; sharp off it.
;; ====================================================================
(format t "~%=== F. generic gd3 at Z/6: twist invisible on the fixed locus ===~%")
(defun gd3 (mul inv sig tw F a b c d)
  (funcall mul
    (funcall mul
      (funcall mul
        (funcall mul
          (if (and tw a) (funcall sig (funcall F b c d)) (funcall F b c d))
          (funcall inv (funcall F (bxor a b) c d)))
        (funcall F a (bxor b c) d))
      (funcall inv (funcall F a b (bxor c d))))
    (funcall F a b c)))
(let ((mul6 (lambda (x y) (mod (+ x y) 6)))
      (inv6 (lambda (x) (mod (- x) 6))))
  (flet ((agreep (m)
           (let ((F (lambda (a b c) (declare (ignore a b c)) m)))
             (for-all-abcd ()
               (= (gd3 mul6 inv6 inv6 t   F a b c d)
                  (gd3 mul6 inv6 inv6 nil F a b c d))))))
    (check "fixed locus {0,3}: twisted = untwisted" (and (agreep 0) (agreep 3)))
    (check "off the fixed locus (m=1) the readings differ" (not (agreep 1)))))

;; ====================================================================
;; PART G — FALSIFICATION CONTROLS: mutants that MUST fire.  An
;; instrument that cannot say no proves nothing (_07's discipline).
;; ====================================================================
(format t "~%=== G. controls: corrupted tables must be convicted ===~%")
(let ((tab (make-array '(4 4))))                 ; Cayley mutant: ui*ui := ui
  (dotimes (i 4) (dotimes (j 4) (setf (aref tab i j) (aref *mul-tab* i j))))
  (setf (aref tab 1 1) 'ui)
  (check "corrupted Cayley table breaks the Z/4 bridge"
         (not (iso-ok-p (sym-rep :mul-tab tab :name "mutant mul")))))
(let ((ctab (copy-seq *conj-tab*)))              ; sigma mutant: sig(ui) := ui
  (setf (aref ctab 1) 'ui)
  (check "corrupted sigma table breaks the battery"
         (not (null (battery-bad (sym-rep :conj-tab ctab :name "mutant sigma"))))))

;; ====================================================================
;; PART H — FINGERPRINTS unique to this host, photographed.
;; ====================================================================
(format t "~%=== H. this host's fingerprints ===~%")
(check "FPRINT: (complex 1 0) collapses to the integer 1 (CLHS 12.1.5.3)"
       (eql (complex 1 0) 1))
(check "FPRINT: (complex 1d0 0d0) does NOT collapse (floats keep ontology)"
       (complexp (complex 1d0 0d0)))
(check "FPRINT: float i*i carries libm dirt (/= -1 exactly)"
       (not (= (* (nth 1 *f64-els*) (nth 1 *f64-els*)) -1)))

;; ====================================================================
;; RECEIPT — pinned count first: a truncated run must not pass
;; (the flag that couldn't fail, remembered). Then pinned NAME DIGEST:
;; a count-only receipt is gameable (see the repair note at `check`'s
;; definition) — 36 vacuous (check "dummy-N" t) calls reproduce
;; "36/36, exit 0". The digest catches what the count cannot.
;; ====================================================================
(format t "~%")
(unless (= *nchecks* +expected-checks+)
  (setf *exitcode* 1)
  (format t "** FAIL ** ran ~d checks, pinned ~d~%" *nchecks* +expected-checks+))
(let ((digest (names-digest *check-names*)))
  (if (string= +expected-names-digest+ "SET-AFTER-FIRST-CORRECT-RUN")
      (format t "~%NAME-DIGEST (first run, not yet pinned): ~a~%" digest)
      (unless (string= digest +expected-names-digest+)
        (setf *exitcode* 1)
        (format t "** FAIL ** name-digest ~a != pinned ~a (battery gutted or renamed)~%"
                digest +expected-names-digest+))))
(format t "~a — ~d/~d checks; read the exit code, not the text~%"
        (if (zerop *exitcode*) "ALL LISP CHECKS PASSED" "SOMETHING FAILED")
        *nchecks* +expected-checks+)
(finish-output)
#+sbcl  (sb-ext:exit :code *exitcode*)
#+clisp (ext:exit *exitcode*)
#-(or sbcl clisp) (error "no exit for this implementation; exitcode=~d" *exitcode*)
