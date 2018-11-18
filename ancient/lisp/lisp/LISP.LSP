(setf *gc-verbose* nil)

(put-sym-fun 'defmacro 
             '(macro (name &rest body)
     (list 'put-sym-fun
           (list 'quote name) 
           (list 'quote (cons 'macro body)))))

(defmacro defun (name &rest body)
	(list 'put-sym-fun
           (list 'quote name) 
           (list 'quote (cons 'lambda body))))


(defun backquote (xxxform)
	(cond ((null xxxform) nil)
	      ((not (consp xxxform)) xxxform)
	      ((eq 'comma (car xxxform))
	       (eval (cadr xxxform)))
	      ((and (consp (car xxxform))
		    (eq 'commaat (caar xxxform)))
	       (append (eval (cadar xxxform))
		       (backquote (cdr xxxform))))
	      (t
	       (cons (backquote (car xxxform))
		     (backquote (cdr xxxform))))))


(defmacro function (fn)
	(cond ((symbolp fn) `(symbol-function ',fn))
	      (t `',fn)))

(defun get (sym prop)
	(do ((pl (symbol-plist sym) (cddr pl)))
	    ((or (null pl)
		 (eq prop (car pl)))
	     (cadr pl))))

(setf \newline 10)
(setf \space 32)
(setf \tab 9)
(setf *print-pretty* nil)

(princ ";lisp.lsp loaded") (terpri)
(load "pprint.lsp")
(load "step.lsp")
