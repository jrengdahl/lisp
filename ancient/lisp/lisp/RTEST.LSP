(setq q 1)

(defun rt (n r)
	(do ((x r (- x 1)))
	    ((= x 0))
	    (print (random n))))

(defun rrt (n r)
	(do ((x r (- x 1)))
	    ((= x 0))
	    (print (random n q))))
