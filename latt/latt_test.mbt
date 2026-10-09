///|
/// latt 黑箱測試：Gram、協體積、LLL、對偶、SVP/CVP 的義務自證。
test "gram-and-covolume" {
  // 標準 Z^2：covol = 1
  let z2 = @core.Mat::of_rows([[1L, 0L], [0L, 1L]])
  assert_eq(@latt.covolume_sq(z2), 1L)
  assert_eq(@latt.gram(z2).to_text(), "[1 0; 0 1]")
  // 非正交基 (1,0),(1,1) 也生成 Z^2
  let b = @core.Mat::of_rows([[1L, 0L], [1L, 1L]])
  assert_eq(@latt.covolume_sq(b), 1L)
  // A2 根格（縮放版）：det(Gram) = 3
  // A2 根格的 Gram 矩陣本身：[[2,-1],[-1,2]]，det = 3
  let a2 = @core.Mat::of_rows([[2L, -1L], [-1L, 2L]])
  assert_eq(a2.det(), 3L)
}

///|
test "lll-certificate" {
  let cases : Array[Array[Array[Int64]]] = [
    [[1L, 0L, 0L], [0L, 1L, 0L], [0L, 0L, 1L]],
    [[1L, 0L], [12L, 1L]],
    [[201L, 37L], [1648L, 297L]],
    [[1L, 1L, 1L], [-1L, 0L, 2L], [3L, 5L, 6L]],
  ]
  for c in cases {
    let b = @core.Mat::of_rows(c)
    let (bp, u) = @latt.lll_reduce(b)
    assert_true(@latt.verify_lll(b, bp, u))
    assert_eq(@latt.covolume_sq(b), @latt.covolume_sq(bp))
  }
}

///|
test "dual-lattice" {
  let b = @core.Mat::of_rows([[2L, 0L], [0L, 2L]])
  let d = @latt.dual_basis(b)
  assert_true(@latt.verify_dual(b, d))
  assert_true(@latt.verify_duality_det(b))
  let c = @core.Mat::of_rows([[1L, 1L], [0L, 3L]])
  assert_true(@latt.verify_dual(c, @latt.dual_basis(c)))
  assert_true(@latt.verify_duality_det(c))
  let e = @core.Mat::of_rows([[2L, 1L], [1L, 2L]])
  assert_true(@latt.verify_dual(e, @latt.dual_basis(e)))
  assert_true(@latt.verify_duality_det(e))
}

///|
test "svp-cvp" {
  let b = @core.Mat::of_rows([[2L, 0L], [0L, 3L]])
  let (_c, v, ns) = @latt.svp_box(b, 2)
  assert_eq(ns, 4L)
  assert_eq(@latt.norm_sq(v), 4L)
  let t : Array[Int64] = [1L, 1L]
  let (_cc, cv, d2) = @latt.cvp_box(b, t, 2)
  assert_eq(d2, 2L)
  // 最近點候選 (0,0) 與 (2,0) 距離平方皆為 2（盒內最小值）
  assert_true(@latt.norm_sq([cv[0] - 1L, cv[1] - 1L]) == 2L)
}

///|
test "lll-bound" {
  let b = @core.Mat::of_rows([[1L, 0L], [12L, 1L]])
  let (bp, _u) = @latt.lll_reduce(b)
  let (_c, _v, ns) = @latt.svp_box(b, 2)
  assert_true(@latt.verify_lll_bound(bp, ns))
  assert_true(@latt.density_report(b, ns) > 0.0)
}
