///|
/// synth_test.mbt —— 形式化驅動代碼與演算法生成引擎之單元測試。
test "synth/bezout and diophantine witness extraction" {
  let c = @synth.synth_bezout_cert(270, 192)
  inspect(c.g, content="6")
  inspect(@synth.verify_bezout_cert(270, 192, c), content="true")
  let d_yes = @synth.synth_diophantine(270, 192, 18)
  inspect(@synth.verify_diophantine_synth(270, 192, 18, d_yes), content="true")
  let d_no = @synth.synth_diophantine(270, 192, 7)
  inspect(@synth.verify_diophantine_synth(270, 192, 7, d_no), content="true")
}

///|
test "synth/egraph algebraic superoptimization" {
  let e1 = @synth.AlgExpr::Add(
    @synth.AlgExpr::Pow2(
      @synth.AlgExpr::Dual(@synth.AlgExpr::Dual(@synth.AlgExpr::VarA)),
    ),
    @synth.AlgExpr::Mul(
      @synth.AlgExpr::Circulant2(3, 5),
      @synth.AlgExpr::Mul(
        @synth.AlgExpr::Neg(@synth.AlgExpr::SymplecticJ2),
        @synth.AlgExpr::Mul(@synth.AlgExpr::SymplecticJ2, @synth.AlgExpr::VarB),
      ),
    ),
  )
  let rep = @synth.superoptimize(e1)
  inspect(rep.cost_after < rep.cost_before, content="true")
  inspect(@synth.verify_superopt(e1), content="true")
  let e2 = @synth.AlgExpr::TraceMat(
    @synth.AlgExpr::Mul(@synth.AlgExpr::VarA, @synth.AlgExpr::VarB),
  )
  let rep2 = @synth.superoptimize(e2)
  inspect(rep2.cost_after < rep2.cost_before, content="true")
  inspect(@synth.verify_superopt(e2), content="true")
}

///|
test "synth/cegis and guard repair" {
  let k = @synth.cegis_synth_karatsuba_im()
  inspect(k.verified, content="true")
  let (a, b, _r, ok) = @synth.cegis_synth_cayley_hamilton_coeffs()
  inspect(a == 1 && b == -1 && ok, content="true")
  for x = -25; x <= 25; x = x + 1 {
    for d = 1; d <= 9; d = d + 1 {
      if !@synth.verify_cegis_guard_repair(x, d) {
        fail("guard repair failed")
      }
    }
  }
}

///|
test "synth/cvec rule mining and pareto lowering" {
  let (tot, cls, pairs) = @synth.cvec_mine_equivalences()
  inspect(tot == 10 && cls == 5 && pairs == 5, content="true")
  let p = @synth.pareto_lower_poly3(3, -2, 5, -7, 6)
  inspect(p.all_agree, content="true")
  inspect(@synth.verify_metamorphic_oracles(4L, 6L, 2L, 8L), content="true")
}
