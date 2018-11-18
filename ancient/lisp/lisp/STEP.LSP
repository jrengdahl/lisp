;Title:  step.lsp
;Author: Jonathan Engdahl (jengdahl on BIX)
;Date:   Jan-25-1987

;This file contains a simple Lisp single-step debugger. It
;started as an implementation of the "hook" example in chapter 20
;of Steele's "Common Lisp". This version was brought up on Xlisp 1.7
;for the Amiga, then on VAXLISP, and finally on (lisp).

;To invoke: (step (whatever-form with args))
;For each list (interpreted function call), the stepper prints the
;environment and the list, then enters a read-eval-print loop
;At this point the available commands are:

;    (a list)<CR> - evaluate the list in the current environment,
;                   print the result, and repeat.                 
;    <CR> - step into the called function
;    anything_else<CR> - step over the called function.

;If the stepper comes to a form that is not a list it prints the form 
;and the value, and continues on without stopping.

;Note that stepper commands are executed in the current environment.
;Since this is the case, the stepper commands can change the current
;environment. For example, a SETF will change an environment variable
;and thus can alter the course of execution.


;set the representation for an input #/newline
;the value, notation, and data type of newline may be implementation dependent
;(setf newline #\newline)   ;for VAXLISP
(setf newline 10)           ;for XLISP
;(setf lpar #\()            ;for VAXLISP
(setf lpar 40)              ;for XLISP

;define a C-like iterator.
(defmacro while (test &rest forms) `(do () ((not ,test)) ,@forms))

;create the nesting level counter.
(setf *hooklevel* 0)

;this macro invokes the stepper.
;for VAXLISP you better rename this to xstep or something, lest
;defun say nasty things to you about step already being defined

(defmacro step (form &aux val)
     `(progn
       (setf *hooklevel* 0)          ;init nesting counter
       (princ *hooklevel*)           ;print the form
       (princ "  form: ")
       (pp-prin1 ',form 8)
       (terpri)
       (setf val (evalhook ',form    ;eval, and kick off stepper
                           #'eval-hook-function
                           nil
                           nil))
       (princ *hooklevel*)           ;print returned value
       (princ " value: ")
       (pp-prin1 val 8)
       (terpri)
       val))                         ;and return it


;this is the substitute "eval" routine that gets control when
;a user form is evaluated during stepping.

(defun eval-hook-function (form env &aux val f1)
     (setf *hooklevel* (+ *hooklevel* 1))    ;inc the nesting level
     (cond ((consp form)                     ;if interpreted function 
	    (cond (env
                   (step-spaces *hooklevel*)        ;print the environment
                   (princ *hooklevel*)
                   (princ "    env: ")
                   (pp-prin1 env (+ *hooklevel* 9 (if (< *hooklevel* 10) 1)))
                   (terpri)))
            (step-spaces *hooklevel*)        ;then the form
            (princ *hooklevel*)
            (princ "   form: ")
            (pp-prin1 form (+ *hooklevel* 9 (if (< *hooklevel* 10) 1)))
            (princ " ")
            (step-flush)                     ;get rid of newline on line
            (while (eql (peek-char) lpar )   ;while a form is typed           
                   (setf f1 (read))          ;read a form
                   (step-spaces *hooklevel*) ;print out result
                   (princ *hooklevel*)
                   (princ " result: ")       ;which is evaled in env
                   (pp-prin1 (evalhook f1 nil nil env)
                   (+ *hooklevel* 9 (if (< *hooklevel* 10) 1)))
                   (princ " ")
                   (step-flush))             ;get rid of junk   
            (cond ((eql (peek-char) newline) ;if <cr> then step into
                   (setf val (evalhook form
                                       #'eval-hook-function
                                       nil
                                       env)))
                  (t (while (not (eql (peek-char) newline)) (read-char))
                     (setf val (evalhook form nil nil env)))))   ;else step over
           (t (step-spaces *hooklevel*)      ;if not interpreted func
              (princ *hooklevel*)            ;print the form
              (princ "   form: ")
              (pp-prin1 form (+ *hooklevel* 9 (if (< *hooklevel* 10) 1)))
              (terpri)
              (setf val (evalhook form nil nil env)))) ;eval it
     (step-spaces *hooklevel*)               ;in either case
     (princ *hooklevel*)                     ;print the result
     (princ "  value: ")
     (pp-prin1 val (+ *hooklevel* 9 (if (< *hooklevel* 10) 1)))
     (terpri)
     (setf *hooklevel* (- *hooklevel* 1))    ;decrement level
     val)                                    ;and return the value


;a non-recursive fn to print spaces (not as elegant, easier on the gc)
(defun step-spaces (n) (while (> n 0) (princ " ") (setf n (- n 1))))
     
;and one to clear the input buffer
(defun step-flush () (while (not (eql (read-char) newline))))

;define the prin1 function -- if it's too slow, do an ordinary print
(defun pp-prin1 (x l)
	(if *print-pretty*
 	    (pprin1 x l)
            (prin1 x)))

(princ ";step.lsp loaded") (terpri)
