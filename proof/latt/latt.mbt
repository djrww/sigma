///|
/// 程式側（.mbt）：族 C（C1–C5）、H7 與 `latt` 格論套件之經形式化驗證演算法核。

///|
/// 1. `latt::gram`：2×2 格基底 Gram 矩陣 G = B·Bᵀ 對稱性與對角線非負驗證。
pub fn gram2_sym_nonneg_synth(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => gram2_sym_nonneg_ok(x1, y1, x2, y2, r),
} {
  let g11 = x1 * x1 + y1 * y1
  let g12 = x1 * x2 + y1 * y2
  let g21 = x2 * x1 + y2 * y1
  let g22 = x2 * x2 + y2 * y2
  (g11, g12, g21, g22)
}

///|
/// 2. `latt::covolume_sq`：Lagrange 二維恆等式 det(B·Bᵀ) = (det B)² ≥ 0 與 Cauchy–Schwarz 不等式。
pub fn gram2_covolume_lagrange_synth(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> (Int, Int) where {
  proof_ensure: r => gram2_covolume_ok(x1, y1, x2, y2, r),
} {
  let g11 = x1 * x1 + y1 * y1
  let g12 = x1 * x2 + y1 * y2
  let g22 = x2 * x2 + y2 * y2
  let det_gram = g11 * g22 - g12 * g12
  let det_b = x1 * y2 - y1 * x2
  (det_gram, det_b * det_b)
}

///|
/// 3. C1 義務與 `latt::lll_reduce`：於 [[1,0],[k,1]] 上構造么模約化 U = [[1,0],[-k,1]] 得標準正交基 I₂。
pub fn lll_shear2_reduce_synth(
  k : Int,
) -> (Int, Int, Int, Int, Int, Int, Int) where {
  proof_ensure: r => lll_shear2_ok(k, r),
} {
  let u21 = -k
  let bp11 = 1
  let bp12 = 0
  let bp21 = u21 * 1 + 1 * k
  let bp22 = u21 * 0 + 1 * 1
  let det_u = 1 * 1 - 0 * u21
  let norm2_before = k * k + 1
  let norm2_after = bp21 * bp21 + bp22 * bp22
  (bp11, bp12, bp21, bp22, det_u, norm2_before, norm2_after)
}

///|
/// 4. C2 義務與三維 LLL 核：於 [[1,0,0],[i,1,0],[j,k,1]] 上構造精確么模逆元 U = [[1,0,0],[-i,1,0],[ik-j,-k,1]]。
pub fn lll_unit_lower3_reduce_synth(
  i : Int,
  j : Int,
  k : Int,
) -> (Int, Int, Int, Int, Int, Int) where {
  proof_ensure: r => lll_unit_lower3_ok(i, j, k, r),
} {
  let u21 = -i
  let u31 = i * k - j
  let u32 = -k
  let p21 = u21 + i
  let p31 = u31 + u32 * i + j
  let p32 = u32 + k
  (u21, u31, u32, p21, p31, p32)
}

///|
/// 5. `latt::lll_reduce` 尺寸約化單步不變式：b₂' = b₂ - q·b₁ 保持行列式並線性消減內積。
pub fn lll_size_reduce_step2_synth(
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  q : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => lll_size_step2_ok(x1, y1, x2, y2, q, r),
} {
  let nx2 = x2 - q * x1
  let ny2 = y2 - q * y1
  let det_new = x1 * ny2 - y1 * nx2
  let dot_new = x1 * nx2 + y1 * ny2
  (nx2, ny2, det_new, dot_new)
}

///|
/// 6. C3 定理與 `latt::dual_basis`：對偶格雙正交關係 B · (D_scaled)ᵀ = det(B) · I₂。
pub fn dual_lattice2_biorthogonal_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int, Int, Int, Int) where {
  proof_ensure: r => dual_lattice2_ok(a, b, c, d, r),
} {
  let d11 = d
  let d12 = -c
  let d21 = -b
  let d22 = a
  let p11 = a * d11 + b * d12
  let p12 = a * d21 + b * d22
  let p21 = c * d11 + d * d12
  let p22 = c * d21 + d * d22
  let det_b = a * d - b * c
  (p11, p12, p21, p22, det_b)
}

///|
/// 7. C3 具體族 [[2,0],[k,3]]：驗證行列式恆為 6 且雙正交內積矩陣為 6·I₂。
pub fn dual_lower_tri2_det_synth(
  k : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => dual_lower_tri2_ok(k, r),
} {
  let det_b = 2 * 3 - 0 * k
  let p11 = 2 * 3 + 0 * -k
  let p12 = 2 * 0 + 0 * 2
  let p22 = k * 0 + 3 * 2
  (det_b, p11, p12, p22)
}

///|
/// 8. C4 算式與 `latt::verify_lll_bound`：驗證 2D LLL 約化基底滿足 ‖b₁'‖² ≤ 2^{2-1} λ₁²。
pub fn svp_lll_hermite_bound2_synth(
  k : Int,
) -> (Int, Int, Int) where {
  proof_ensure: r => svp_lll_bound2_ok(k, r),
} {
  let _ = k
  let norm_b1_sq = 1
  let lambda1_sq = 1
  let rhs_bound = 2 * lambda1_sq
  (norm_b1_sq, lambda1_sq, rhs_bound)
}

///|
/// 9. C5 算式與 `latt::cvp_box`：對角格 diag(2,3) 上目標點 (t₁,t₂) 與候選格點之歐氏距離平方非負與對稱性。
pub fn cvp_diag2_distance_synth(
  t1 : Int,
  t2 : Int,
  c1 : Int,
  c2 : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => cvp_diag2_dist_ok(t1, t2, c1, c2, r),
} {
  let v1 = 2 * c1
  let v2 = 3 * c2
  let d2_fwd = (t1 - v1) * (t1 - v1) + (t2 - v2) * (t2 - v2)
  let d2_rev = (v1 - t1) * (v1 - t1) + (v2 - t2) * (v2 - t2)
  (v1, v2, d2_fwd, d2_rev)
}

///|
/// 10. 格向量範數之平行四邊形恆等式：‖u+v‖² + ‖u-v‖² = 2(‖u‖² + ‖v‖²)。
pub fn parallelogram_norm_law2_synth(
  u1 : Int,
  u2 : Int,
  v1 : Int,
  v2 : Int,
) -> (Int, Int) where {
  proof_ensure: r => parallelogram2_ok(u1, u2, v1, v2, r),
} {
  let lhs = (u1 + v1) * (u1 + v1) +
    (u2 + v2) * (u2 + v2) +
    (u1 - v1) * (u1 - v1) +
    (u2 - v2) * (u2 - v2)
  let rhs = 2 * (u1 * u1 + u2 * u2 + v1 * v1 + v2 * v2)
  (lhs, rhs)
}

///|
/// 11. H7 義務：么模變換 B' = U·B 保持行列式與 Gram 協體積平方 (det B')² = (det B)²。
pub fn unimodular_gram_det_invariance_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  k : Int,
) -> (Int, Int) where {
  proof_ensure: r => unimodular_gram_inv_ok(a, b, c, d, k, r),
} {
  let det_b = a * d - b * c
  let r11 = a + k * c
  let r12 = b + k * d
  let det_ub = r11 * d - r12 * c
  (det_b, det_ub)
}
