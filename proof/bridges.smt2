; 取餘步驟的整除橋接：以原始 SMT-LIB（z3）獨立驗證其真值。
; 用法：z3 proof/bridges.smt2   → 應輸出四個 unsat（即四個否定皆不可滿足）。
(set-option :timeout 30000)
(define-fun step () Bool
  (forall ((a Int) (b Int) (d Int) (k1 Int) (k2 Int))
    (=> (and (>= a 0) (> b 0) (= a (* d k1)) (= b (* d k2)))
        (= (mod a b) (* d (- k1 (* (div a b) k2)))))))
(define-fun back () Bool
  (forall ((a Int) (b Int) (d Int) (k2 Int) (kr Int))
    (=> (and (>= a 0) (> b 0) (= b (* d k2)) (= (mod a b) (* d kr)))
        (= a (* d (+ (* k2 (div a b)) kr))))))
(define-fun modmod () Bool
  (forall ((a Int) (b Int) (d Int))
    (=> (and (>= a 0) (> b 0) (> d 0) (= (mod a d) 0) (= (mod b d) 0))
        (= (mod (mod a b) d) 0))))
(define-fun modback () Bool
  (forall ((a Int) (b Int) (d Int))
    (=> (and (>= a 0) (> b 0) (> d 0) (= (mod b d) 0) (= (mod (mod a b) d) 0))
        (= (mod a d) 0))))
(echo "step:")(assert (not step))(check-sat)
(echo "back:")(push)(assert (not back))(check-sat)(pop)
(echo "modmod:")(push)(assert (not modmod))(check-sat)(pop)
(echo "modback:")(push)(assert (not modback))(check-sat)(pop)
