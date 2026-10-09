///|
/// mat2_test.mbt —— 第二代矩陣體系與第一代矩陣對照測試。
test "mat2/grassmann berezinian multiplicativity vs mat1 defect" {
  let (ok, defect, lhs1, rhs1) = @mat2.compare_berezinian_mat1_vs_mat2(
    2, 3, 5, 7, 11, 13,
  )
  inspect(ok, content="true")
  inspect(lhs1 == rhs1, content="true")
  // 在第一代交換矩陣中，defect = -2*2*5*7*11 = -1540 != 0！
  inspect(defect, content="-1540")
}

///|
test "mat2/polymat operator separation vs mat1 snf blindness" {
  let (ok, tid, tsh, thy) = @mat2.compare_polymat_vs_mat1(17L)
  inspect(ok, content="true")
  inspect(tid != tsh && tsh != thy, content="true")
}

///|
test "mat2/kronecker hierarchical tree vs dense mat1" {
  let a = @core.Mat::of_rows([[2L, 1L], [1L, 3L]])
  let b = @core.Mat::of_rows([[3L, 2L], [1L, 2L]])
  let c = @core.Mat::of_rows([[1L, 4L], [2L, 9L]])
  let (ok, w1, w2, op1, op2) = @mat2.compare_kron_mat2_vs_mat1(a, b, c)
  inspect(ok, content="true")
  inspect(w1 == 64 && w2 == 12, content="true")
  inspect(op1 == 512 && op2 == 24, content="true")
}

///|
test "mat2/tropical geodesic and p-adic newton bound" {
  let (ok, geo, ring_sum) = @mat2.compare_tropical_geodesic_vs_mat1()
  inspect(ok, content="true")
  inspect(geo, content="5")
  inspect(ring_sum, content="24")
  let m = @core.Mat::of_rows([[9L, 3L], [6L, 5L]])
  let (nb_ok, tdet, vdet) = @mat2.verify_tropical_padic_newton_bound(m, 3L)
  inspect(nb_ok && tdet <= vdet, content="true")
}
