;TITLE: pprint.lsp
;AUTHOR: Jonathan Engdahl (jengdahl on BIX)
;DATE: 2-1-87
;Runs on: AMIGA XLISP 1.7
;         VAX COMMON LISP
;         AMIGA (lisp)

;This is a pretty printer for Lisp functions. It tends to
;print out functions the way I type them in, although not
;perfectly. Sorry it's so slow. It didn't do quite so bad
;when it was compiled under VAXLISP, but for XLISP, well...

;to call: (pprint <form>)


;a function to determine the length of a string
(put-sym-fun 'pp-str-len (symbol-function 'length)) ;faster for (lisp)
;(defun pp-str-len (s) (length s)) ;for VAXLISP
;(defun pp-str-len (s) (flatc s))   ;for XLISP

;a function to determine the printsize of a thing
(defun pp-printlen (thing) (vax-pp-printlen thing)) ;for VAXLISP
;(defun pp-printlen (thing) (flatsize thing))         ;for XLISP


(defun pp-spaces (n) (do ((n n (- n 1))) ((= n 0)) (princ " ")))

;the width of s when printed
;since there is no "stringp" in XLISP, assume the 
;arg is a string if it isn't anything else

(defun vax-pp-printlen (s)
    (cond ((null s) 3)                               ;nil
          ((symbolp s) (pp-str-len (symbol-name s))) ;symbol
          ((and (consp s) (eq (car s) 'quote))       ;anything quoted
           (+ 1 (vax-pp-printlen (cadr s))))
          ((consp s)                                 ;a list
           (+ 1
              (vax-pp-printlen (car s)) 
              (if (null (cdr s))
                  1
                  (+ (vax-pp-printlen (cdr s))
                     (if (atom (cdr s)) 3 1)))))   
       ((numberp s)                               ;a number
           (if (> 10 s) 1 (+ 1 (vax-pp-printlen (/ s 10)))))
          (t (+ 2 (pp-str-len s)))))                 ;string (I guess)



(defun pp-printlist (x lev down)
    (pp-print (car x) lev 'first) 
    (cond ((null (cdr x)))
          ((atom (cdr x))
           (princ " . ")
           (princ (cdr x)))
          (down
           (terpri)
           (pp-spaces lev)
           (pp-printlist (cdr x) lev down))
          (t (princ " ")
             (pp-printlist (cdr x) lev down))))

(defun pp-print (x lev first) 
    (cond ((null x) (princ "nil"))
          ((atom x) (prin1 x))
          ((and (consp x) (eq (car x) 'quote))
           (princ "'")
           (pp-print (cadr x) lev 'first))
          ((consp x)
           (if first (princ "("))
           (cond ((< (countatoms x) 6)
                  (pp-printlist x (+ lev (if first 1 0)) nil))
                 ((not (consp (car x)))
                  (pp-print (car x) lev t)
                  (princ " ")
                  (pp-print (cdr x)
                           (+ lev
                              (if first 2 1)
                              (pp-printlen (car x)))
                            nil))
                 (t (pp-printlist x (+ lev (if first 1 0)) t)))
           (if first (princ ")")))
          (t (princ "???"))))

(defun pprint (x) 
    (pp-print x 0 'first)
    (terpri))

(defun pprin1 (x lev) 
    (pp-print x lev 'first))


(princ ";pprint.lsp loaded") (terpri)
