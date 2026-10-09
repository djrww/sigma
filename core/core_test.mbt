///|
/// core 黑箱測試：算術、行列式、秩、SNF、HNF、核、求解的義務自證。
test "zu-arithmetic" {
  assert_eq(@core.igcd(12L, 18L), 6L)
  assert_eq(@core.igcd(-12L, 18L), 6L)
  let (g, s, t) = @core.egcd(240L, 46L)
  assert_eq(g, 2L)
  assert_eq(s * 240L + t * 46L, 2L)
  assert_eq(@core.zmod(-7L, 5L), 3L)
  assert_eq(@core.zdiv(-7L, 5L), -2L)
  assert_eq(@core.zdiv(-7L, 5L) * 5L + @core.zmod(-7L, 5L), -7L)
  assert_eq(@core.zdiv(-7L, -5L) * -5L + @core.zmod(-7L, -5L), -7L)
  assert_eq(@core.powmod(3L, 100L, 7L), 4L)
  assert_eq(@core.zmod(@core.invmod(3L, 7L) * 3L, 7L), 1L)
  assert_eq(@core.ipow(2L, 10), 1024L)
}

///|
test "det-and-rank" {
  let a = @core.Mat::of_rows([[1L, 2L], [3L, 4L]])
  assert_eq(a.det(), -2L)
  assert_eq(a.rank(), 2)
  assert_true(a.verify_cayley_hamilton2())
  let i3 = @core.Mat::ident(3)
  assert_eq(i3.det(), 1L)
  let z = @core.Mat::of_rows([[1L, 2L], [2L, 4L]])
  assert_eq(z.det(), 0L)
  assert_eq(z.rank(), 1)
  let b = @core.Mat::of_rows([[2L, 0L, 1L], [1L, 3L, 2L], [1L, 6L, 4L]])
  assert_eq(b.det(), 3L)
  assert_eq(b.rank(), 3)
  assert_true(b.is_unimodular() == false)
}

///|
test "unimodular-inverse" {
  let s = @core.Mat::of_rows([[1L, 1L], [0L, 1L]])
  assert_true(s.is_unimodular())
  match s.inverse_unimodular() {
    None => abort("expected inverse")
    Some(t) => {
      assert_true(s.mul(t).eq(@core.Mat::ident(2)))
      assert_true(t.mul(s).eq(@core.Mat::ident(2)))
    }
  }
}

///|
test "snf-certificate" {
  let cases : Array[Array[Array[Int64]]] = [
    [[2L, 0L], [0L, 4L]],
    [[1L, 2L], [3L, 4L]],
    [[2L, 4L], [6L, 8L]],
    [[3L, 0L, 1L], [0L, 6L, 2L]],
  ]
  for c in cases {
    let a = @core.Mat::of_rows(c)
    let (u, d, v) = @core.snf_full(a)
    assert_true(@core.verify_snf_full(a, u, d, v))
  }
  let a = @core.Mat::of_rows([[2L, 4L], [6L, 8L]])
  let (u, d, v) = @core.snf_full(a)
  assert_true(@core.verify_snf(a, u, d, v))
  assert_true(@core.verify_smith_shape(d))
  // 驗證 D = diag(2, 4)：Z^2 / A 的撓為 Z/2 + Z/4
  assert_true(d.eq(@core.Mat::diag([2L, 4L])))
  assert_eq(@core.invariant_factors(a).length(), 2)
}

///|
test "snf-invariants" {
  let a = @core.Mat::of_rows([[4L, 0L], [0L, 6L]])
  let inv = @core.invariant_factors(a)
  assert_eq(inv[0], 2L)
  assert_eq(inv[1], 12L)
  let tor = @core.torsion_invariants(a)
  assert_eq(tor.length(), 2)
  let ed = @core.elementary_divisors(a)
  assert_eq(ed.length(), 3)
  let img = @core.image_basis(a)
  assert_eq(img.length(), 2)
}

///|
test "hnf-certificate" {
  let cases : Array[Array[Array[Int64]]] = [
    [[3L, 1L, 4L], [1L, 5L, 9L]],
    [[2L, 4L, 6L], [1L, 3L, 5L]],
    [[5L, 0L, 0L], [0L, 7L, 0L], [1L, 1L, 1L]],
  ]
  for c in cases {
    let a = @core.Mat::of_rows(c)
    let (h, u) = @core.hnf_full(a)
    assert_true(@core.verify_hnf(a, h, u))
  }
}

///|
test "kernel-and-solve" {
  let a = @core.Mat::of_rows([[1L, 2L, 3L], [4L, 5L, 6L]])
  let k = @core.kernel_basis(a)
  assert_true(@core.verify_kernel(a, k))
  let a2 = @core.Mat::of_rows([[2L, 4L], [6L, 8L]])
  let b = @core.Mat::of_rows([[6L], [14L]])
  match @core.solve_integer(a2, b) {
    None => abort("expected solvable")
    Some(x) => assert_true(@core.verify_solution(a2, b, x))
  }
}

///|
test "mat-string" {
  let a = @core.Mat::of_rows([[1L, -2L], [3L, 4L]])
  assert_eq(a.to_text(), "[1 -2; 3 4]")
  assert_eq(@core.Mat::diag([2L, 4L]).diag_text(), "(2,4)")
}
