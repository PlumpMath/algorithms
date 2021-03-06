#lang racket
(define PI 3.14159265359)
(provide (all-defined-out))
;#####################
; Problem 1
;#####################

(define (integral func num-steps x1 x2)
  ; define a step for each movement. 
  (define step (/ (- x2 x1) num-steps))
  ; define the sum.
  (define sum 0)
  ; the sum of the function value times the small step
  (define (func-rect x1 x2) (* ( - x2 x1) (func x1)))
  
  (for([i num-steps])
    (set! sum (+ sum (func-rect (+ x1 (* i step)) (+ x1 (* (add1 i) step))))))
  (+ sum 0))



;######################
; Problem 2
;######################

(define (approx-pi num-steps)
  (integral (lambda (x) (* 4 (sqrt (- 1 (expt x 2))))) num-steps 0 1)
  )

;######################
; Problem 3
;######################

(define (rectangle func x1 x2)
  (* ( - x2 x1) (func x1)))

(define (trapezoid func x1 x2)
  (/ (* ( - x2 x1) (+ (func x1) (func x2))) 2))

(define (integral-with piece func num-steps x1 x2)
  ; define a step for each movement. 
  (define step (/ (- x2 x1) num-steps))
  ; define the sum.
  (define sum 0)
  
  (for([i num-steps])
    (set! sum (+ sum (piece func (+ x1 (* i step)) (+ x1 (* (add1 i) step))))))
  (+ sum 0))

;###################
;Problem 4
;###################
(define (better-pi num-steps)
  (integral-with trapezoid (lambda (x) (* 4 (sqrt (- 1 (expt x 2))))) num-steps 0 1)
  )

;###################
;Problem 5
;###################
(define (deriv-constant constant wrt)
  0)

(define (deriv-variable var wrt)
  (if (eq? var wrt) 1 0)
  )


;###################
;Problem 6
;###################
(define (derivative expr wrt)
  
  (cond
    [(not (symbol? wrt)) (error "Don't know how to differentiate" expr)]
    [else ( cond
             [(and (list? expr) (equal? (list-ref expr 0) '+)) (deriv-sum expr wrt)]
             [(and (list? expr) (equal? (list-ref expr 0) '*)) (deriv-sum expr wrt)]
             [(symbol? expr) (deriv-variable expr wrt)]
             [(number? expr) (deriv-constant expr wrt)]
             [else (error "Don't know how to differentiate" expr)])]))


;###################
;Problem 7
;##################
(define (deriv-sum expr wrt)
  (quasiquote (+ (unquote (derivative (list-ref expr 1) wrt)) (unquote (derivative (list-ref expr 2) wrt)))))

;###################
;Problem 8
;###################
(define (deriv-product expr wrt)
  (quasiquote (+ (* (unquote(list-ref expr 1)) (unquote (derivative (list-ref expr 2) wrt)))
                 ( * (unquote (derivative (list-ref expr 1) wrt)) (unquote(list-ref expr 2))))))


(module+ test
  (require rackunit/text-ui)
  (require rackunit)
  (define-test-suite p1-test (
                              " Test Suite for Problem set p1 of SICP"
                              
                              (test-suite
                               " tests for Problem 1 "
                               (test-eq? "x^2 integral with 1 step" (integral (lambda (x) (expt x 2)) 1 3 5) 18)
                               (test-eq? "x^2 integral with 2 steps" (integral (lambda (x) (expt x 2)) 2 3 5) 25)
                               (test-eq? "x^3 integral with 2 steps" (integral (lambda (x) (expt x 3)) 2 3 5) 91))
                              
                              
                              
                              (test-suite
                               " tests for Problem 2 "
                               (test-eq? "approx pi with a single step " (approx-pi 1) 4)
                               (test-= "test approx-pi with 600 steps should be Pi with a two decimal precision "
                                       (approx-pi 600) 3.14 0.01))
                              
                              
                              
                              (test-suite
                               " tests for Problem 3 "
                               (test-eq? "test a rectangle piece function of x^2 should be (1)^2 times the length(3)"
                                         (rectangle (lambda(x) (expt x 2)) 1 4) 3)
                               (test-eq? "test a rectangle function of x^2 should be (2)^2 times the length(5)"
                                         (rectangle (lambda(x) (expt x 2)) 2 7) 20)
                               (test-= "test a trapezoid function of x^2 should be [(1)^2 + (4)^2 times the length(3)]/ 2"
                                       (trapezoid (lambda(x) (expt x 2)) 1 4) 25.5 0.001)
                               (test-= "test a trapezoid function of x^2 should be [(2)^2 + (7)^2 times the length(5)] / 2"
                                       (trapezoid (lambda(x) (expt x 2)) 2 7) 132.5 0.001))
                              
                              
                              
                              (test-suite
                               " tests for Problem 4 "
                               (test-true "test that better-pi gives a closer approx. to pi,  then approx-pi "
                                          ( < (abs (- PI (better-pi 600))) (abs (- PI (approx-pi 600))))))
                              
                              
                              
                              (test-suite
                               " tests for Problem 5 "
                               (test-eq? "test for derivation using same var. " (deriv-variable 'x 'x) 1)
                               (test-eq? "test for derivation using different var. " (deriv-variable 'x 'y) 0))
                              
                              
                              
                              (test-suite
                               " tests for Problem 7 "
                               (test-equal? "test for sum derivation" (deriv-sum '(+ x 2) 'x) '(+ 1 0))
                               (test-equal? "test for sum derivation" (derivative '(+ x 2) 'x) '(+ 1 0)))
                              
                              
                              
                              (test-suite
                               " tests for Problem 8 "
                               (test-true "test for product derivation" (or (equal? (deriv-product '(* x 3) 'x) '(+ (* x 0) (* 1 3)))
                                                                            (equal? (eval (deriv-product '(* x 3) 'x)) 3))))))
  )