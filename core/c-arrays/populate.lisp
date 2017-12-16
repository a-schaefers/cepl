(in-package :cepl.c-arrays)

(defun+ c-populate (c-array data)
  (check-type data array)
  (assert (validate-dimensions data (c-array-dimensions c-array)) ()
          "Dimensions of array differs from that of the data:~%~a~%~a"
          c-array data)
  (let ((dimensions (c-array-dimensions c-array))
        (to (get-typed-to-foreign (c-array-element-type c-array))))
    (labels ((1d (ptr x)
               (funcall to ptr (aref data x)))
             (2d (ptr x y)
               (funcall to ptr (aref data x y)))
             (3d (ptr x y z)
               (funcall to ptr (aref data x y z)))
             (4d (ptr x y z w)
               (funcall to ptr (aref data x y z w))))
      (across-c-ptr (ecase= (length dimensions)
                      (1 #'1d)
                      (2 #'2d)
                      (3 #'3d)
                      (4 #'4d))
                    c-array)
      c-array)))

(defun+ validate-dimensions (data dimensions)
  (check-type data array)
  (let* ((dimensions (listify dimensions))
         (actual-dims (array-dimensions data)))
    (equal dimensions actual-dims)))

;;------------------------------------------------------------

(defun+ c-array-byte-size (c-array)
  (%gl-calc-byte-size (c-array-element-byte-size c-array)
                      (c-array-dimensions c-array)))

(defun+ %gl-calc-byte-size (elem-size dimensions)
  (let* ((x-size (first dimensions)) (rest (rest dimensions))
         (row-byte-size (* x-size elem-size)))
    (values (* row-byte-size (max (reduce #'* rest) 1))
            row-byte-size)))

(defun+ gl-calc-byte-size (type dimensions)
  (%gl-calc-byte-size (gl-type-size type) (listify dimensions)))
