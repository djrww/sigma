///|
/// spec 黑箱測試：FFT、卷積、循環對角化、伴隨、辛、超矩陣、極化。
test "fft-roundtrip" {
  let p = @spec.fermat_p()
  let v : Array[Int64] = [1L, 2L, 3L, 4L]
  let w = @spec.nth_root(4, p)
  assert_true(@spec.verify_fft_roundtrip(v, w, p))
  let v8 : Array[Int64] = [1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L]
  assert_true(@spec.verify_fft_roundtrip(v8, @spec.nth_root(8, p), p))
}

///|
test "convolution-theorem" {
  let p = @spec.fermat_p()
  let a : Array[Int64] = [1L, 2L, 3L]
  let b : Array[Int64] = [4L, 5L]
  assert_true(@spec.verify_convolution_theorem(a, b, p))
  let c : Array[Int64] = [3L, 1L, 4L, 1L, 5L, 9L, 2L, 6L]
  let d : Array[Int64] = [2L, 7L, 1L, 8L]
  assert_true(@spec.verify_convolution_theorem(c, d, p))
}

///|
test "circulant-diagonalization" {
  let p = @spec.fermat_p()
  assert_true(@spec.verify_circulant_diagonalization([1L, 2L, 3L, 4L], p))
  assert_true(@spec.verify_circulant_diagonalization([5L, 0L, 1L, 0L], p))
}

///|
test "adjoint-and-symplectic" {
  let p = @spec.fermat_p()
  let a = @core.Mat::of_rows([[1L, 2L], [3L, 4L]])
  assert_true(@spec.verify_adjoint(a, [1L, 2L], [3L, 4L], p))
  // 辛矩陣 S = [[A,0],[0,(A^T)^{-1}]]，取 det A = 1 以使 (A^T)^{-1} 為整數
  let s = @core.Mat::of_rows([
    [1L, 2L, 0L, 0L],
    [1L, 3L, 0L, 0L],
    [0L, 0L, 3L, -1L],
    [0L, 0L, -2L, 1L],
  ])
  assert_true(@spec.verify_symplectic(s, 2))
}

///|
test "supermatrix" {
  let p = @spec.fermat_p()
  // 齊次（even）與奇（odd）超矩陣
  let m = @core.Mat::of_rows([
    [1L, 0L, 0L, 0L],
    [0L, 3L, 0L, 0L],
    [0L, 0L, 5L, 0L],
    [0L, 0L, 0L, 6L],
  ])
  let n = @core.Mat::of_rows([
    [0L, 0L, 5L, 6L],
    [0L, 0L, 7L, 8L],
    [9L, 1L, 0L, 0L],
    [2L, 3L, 0L, 0L],
  ])
  assert_true(@spec.verify_supertrace_vanishes(m, n, 2))
  assert_true(@spec.verify_supertrace_vanishes(n, n, 2))
  // 塊上三角超矩陣（奇部只在 B 位置）——交換環上 Berezinian 乘法性成立的情形
  let m2 = @core.Mat::of_rows([
    [2L, 1L, 3L, 4L],
    [1L, 3L, 5L, 6L],
    [0L, 0L, 5L, 2L],
    [0L, 0L, 1L, 7L],
  ])
  let n2 = @core.Mat::of_rows([
    [3L, 0L, 2L, 1L],
    [1L, 2L, 0L, 1L],
    [0L, 0L, 4L, 0L],
    [0L, 0L, 1L, 3L],
  ])
  assert_true(@spec.verify_berezinian_multiplicative(m2, n2, 2, p))
}

///|
test "polarization" {
  let p = @spec.fermat_p()
  let a = @core.Mat::of_rows([[2L, 1L], [1L, 3L]])
  assert_true(@spec.verify_polarization_identity(a, [1L, 2L], [3L, 5L], p))
  assert_true(
    @spec.verify_polarization_cubic([1L, 2L, 3L, 4L], [1L, 2L], [3L, 4L], [
      5L, 6L,
    ]),
  )
  assert_true(@spec.verify_polar_diagonal([1L, 2L, 3L, 4L], [2L, 3L]))
}
