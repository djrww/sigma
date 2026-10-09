///|
/// 程式側（.mbt）：族 A（A1–A4）、族 B（B1–B6）、H6、H8 以及 `core` 與 `fga` 套件
/// 之經形式化驗證演算法核。

///|
/// 1. A1 定理與 `core::snf_full` 對角核：構造 SNF(diag(a,b)) = diag(gcd, lcm) 並證明 d₁|d₂ 及 d₁·d₂ = a·b。
pub fn snf_diag_gcd_lcm_synth(
  a : Int,
  b : Int,
  g : Int,
  ua : Int,
  ub : Int,
) -> (Int, Int, Int) where {
  proof_require: p_snf_diag_hyp(a, b, g, ua, ub),
  proof_ensure: r => snf_diag_ok(a, b, g, ua, ub, r),
} {
  let _ = a + b
  let d1 = g
  let k_div = ua * ub
  let d2 = g * k_div
  (d1, d2, k_div)
}

///|
/// 2. `core::verify_snf_full` 雙邊變換憑證核：證明 det(U·A) = det(U)·det(A)。
pub fn snf_bilateral_cert2_synth(
  u11 : Int,
  u12 : Int,
  u21 : Int,
  u22 : Int,
  a11 : Int,
  a12 : Int,
  a21 : Int,
  a22 : Int,
) -> (Int, Int) where {
  proof_ensure: r => {
    snf_bilateral2_ok(u11, u12, u21, u22, a11, a12, a21, a22, r)
  },
} {
  let m11 = u11 * a11 + u12 * a21
  let m12 = u11 * a12 + u12 * a22
  let m21 = u21 * a11 + u22 * a21
  let m22 = u21 * a12 + u22 * a22
  let det_ua = m11 * m22 - m12 * m21
  let det_prod = (u11 * u22 - u12 * u21) * (a11 * a22 - a12 * a21)
  (det_ua, det_prod)
}

///|
/// 3. `core::Mat::add_row` 演算法單步不變式：基本列倍加 R₂ ← R₂ + k·R₁ 嚴格保持行列式。
pub fn elem_row_add_det2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  k : Int,
) -> (Int, Int, Int, Int, Int) where {
  proof_ensure: r => elem_row_add_ok(a, b, c, d, k, r),
} {
  let r11 = a
  let r12 = b
  let r21 = c + k * a
  let r22 = d + k * b
  let det_new = r11 * r22 - r12 * r21
  (r11, r12, r21, r22, det_new)
}

///|
/// 4. `core::Mat::add_col` 演算法單步不變式：基本行倍加 C₂ ← C₂ + k·C₁ 嚴格保持行列式。
pub fn elem_col_add_det2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  k : Int,
) -> (Int, Int, Int, Int, Int) where {
  proof_ensure: r => elem_col_add_ok(a, b, c, d, k, r),
} {
  let r11 = a
  let r12 = b + k * a
  let r21 = c
  let r22 = d + k * c
  let det_new = r11 * r22 - r12 * r21
  (r11, r12, r21, r22, det_new)
}

///|
/// 5. `core::Mat::swap_rows` 演算法單步不變式：交換兩列使行列式變號且平方守恆。
pub fn elem_row_swap_det2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int) where {
  proof_ensure: r => elem_row_swap_ok(a, b, c, d, r),
} {
  (a * d - b * c, c * b - d * a)
}

///|
/// 6. `core::Mat::inverse_unimodular` 演算法：2×2 么模矩陣逆元構造與雙邊單位矩陣驗證。
pub fn unimodular_inv2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_unimodular2_hyp(a, b, c, d),
  proof_ensure: r => unimodular_inv2_ok(a, b, c, d, r),
} {
  (d, -b, -c, a)
}

///|
/// 7. `core::hnf` 與 H7 定理：HNF 變換 H = U·A 之主對角乘積減副對角項嚴格等於 det(U)·det(A)。
/// （註：若不顯式給出副對角零化橋接項 h₁₂·h₂₁ 而令 SMT 在 11 變數非線性方程組中做隱式 Gröbner 消去，
///   Z3/CVC5 會在 2s 內超時——已收錄入超時定理目錄 T-TO-01。）
pub fn hnf_upper_det2_synth(
  u11 : Int,
  u12 : Int,
  u21 : Int,
  u22 : Int,
  a11 : Int,
  a12 : Int,
  a21 : Int,
  a22 : Int,
) -> (Int, Int, Int) where {
  proof_ensure: r => {
    hnf_upper_det2_ok(u11, u12, u21, u22, a11, a12, a21, a22, r)
  },
} {
  let h11 = u11 * a11 + u12 * a21
  let h12 = u11 * a12 + u12 * a22
  let h21 = u21 * a11 + u22 * a21
  let h22 = u21 * a12 + u22 * a22
  let det_h = h11 * h22 - h12 * h21
  (h11, h22, det_h)
}

///|
/// 8. B1 有限生成 Z-模結構定理與核-像秩守恆（`fga::verify_structure_theorem` / `core::kernel_basis`）。
pub fn rank_nullity_structure_synth(
  m : Int,
  n : Int,
  r : Int,
) -> (Int, Int) where {
  proof_require: p_rank_nullity_hyp(m, n, r),
  proof_ensure: res => rank_nullity_ok(m, n, r, res),
} {
  (m - r, n - r)
}

///|
/// 9. A2/A3/A4/H8：循環群之 Hom, Ext¹, Tor₁, Tensor 四大函子同構於 Z/gcd(a,b)。
pub fn hom_ext_tor_tensor_cyclic_synth(
  a : Int,
  b : Int,
  g : Int,
  ua : Int,
  ub : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_snf_diag_hyp(a, b, g, ua, ub),
  proof_ensure: r => hom_ext_tor_tensor_ok(a, b, g, ua, ub, r),
} {
  let _ = a + b + ua + ub
  (g, g, g, g)
}

///|
/// 10. B5/H8/H10：Pontryagin 對偶 Ĝ 與雙對偶 Ĝ̂ 典範同構及階數守恆（`fga::verify_bidual`）。
pub fn pontryagin_bidual_invariants_synth(
  d1 : Int,
  d2 : Int,
  k : Int,
) -> ((Int, Int), (Int, Int), Int) where {
  proof_require: p_ab2_hyp(d1, d2, k),
  proof_ensure: r => pontryagin_bidual_ok(d1, d2, r),
} {
  let _ = k
  let dual1 = d1
  let dual2 = d2
  let bidual1 = dual1
  let bidual2 = dual2
  ((dual1, dual2), (bidual1, bidual2), d1 * d2)
}

///|
/// 11. B4/B6：Lagrange 定理與混合商群 G/H 階數整除律（`fga::verify_lagrange`）。
pub fn lagrange_quotient_order_synth(
  d1 : Int,
  d2 : Int,
  h1 : Int,
  h2 : Int,
  q1 : Int,
  q2 : Int,
) -> (Int, Int, Int) where {
  proof_require: p_lagrange_hyp(d1, d2, h1, h2, q1, q2),
  proof_ensure: r => lagrange_quotient_ok(d1, d2, h1, h2, q1, q2, r),
} {
  (d1 * d2, h1 * h2, q1 * q2)
}

///|
/// 12. B2/B3：p^k-撓子群指數截斷律（`fga::p_n_torsion`）。
pub fn p_torsion_exponent_synth(
  k : Int,
  a : Int,
  b : Int,
) -> (Int, Int, Int) where {
  proof_require: p_torsion_hyp(k, a, b),
  proof_ensure: r => p_torsion_exp_ok(k, a, b, r),
} {
  let ea = if k <= a { k } else { a }
  let eb = if k <= b { k } else { b }
  (ea, eb, ea + eb)
}

///|
/// 13. H6：初等貝爾 p-群 (Z/p)³ 階數 p³ 與純量 p-零化律（`fga::elementary_abelian`）。
pub fn elementary_abelian_p_group_synth(
  p : Int,
  x1 : Int,
  x2 : Int,
  x3 : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_prime_hyp(p),
  proof_ensure: r => elem_abelian_p3_ok(p, x1, x2, x3, r),
} {
  (p * p * p, p * x1, p * x2, p * x3)
}

///|
/// 14. `fga::verify_crt`：中國剩餘定理（CRT）由 Bézout 見證 m·u + n·v = 1 構造雙同餘解。
pub fn crt_isomorphism_recon_synth(
  m : Int,
  n : Int,
  u : Int,
  v : Int,
  rm : Int,
  rn : Int,
) -> (Int, Int, Int) where {
  proof_require: p_crt_bezout_hyp(m, n, u, v),
  proof_ensure: r => crt_recon_ok(m, n, rm, rn, r),
} {
  let x = rm * (n * v) + rn * (m * u)
  let km = u * (rn - rm)
  let kn = v * (rm - rn)
  (x, km, kn)
}

///|
/// 15. `core::Frac`：有理數通分加法交換律與加法逆元零化核。
pub fn frac_ring_laws_synth(
  n1 : Int,
  d1 : Int,
  n2 : Int,
  d2 : Int,
) -> ((Int, Int), (Int, Int), (Int, Int)) where {
  proof_require: p_frac2_hyp(d1, d2),
  proof_ensure: r => frac_add_laws_ok(n1, d1, n2, d2, r),
} {
  let ab = (n1 * d2 + n2 * d1, d1 * d2)
  let ba = (n2 * d1 + n1 * d2, d2 * d1)
  let zero = (n1 * d1 + -n1 * d1, d1 * d1)
  (ab, ba, zero)
}

///|
/// 16. `core::solve_integer` / `verify_solution`：SNF 對角空間整數解憑證驗證核。
pub fn integer_linear_solve_cert_synth(
  d1 : Int,
  d2 : Int,
  c1 : Int,
  c2 : Int,
  y1 : Int,
  y2 : Int,
) -> (Int, Int) where {
  proof_require: p_snf_solve_hyp(d1, d2, c1, c2, y1, y2),
  proof_ensure: r => snf_solve_cert_ok(d1, d2, c1, c2, y1, y2, r),
} {
  let _ = c1 + c2
  (d1 * y1, d2 * y2)
}

///|
/// 17. `core::Mat::det`：3×3 Bareiss 無分數消去演算法與 Sylvester 恆等式整除核。
pub fn bareiss3_det_synth(
  a11 : Int,
  a12 : Int,
  a13 : Int,
  a21 : Int,
  a22 : Int,
  a23 : Int,
  a31 : Int,
  a32 : Int,
  a33 : Int,
) -> Int where {
  proof_require: p_bareiss3_hyp(a11, a12, a21, a22),
  proof_ensure: d => {
    bareiss3_det_ok(a11, a12, a13, a21, a22, a23, a31, a32, a33, d)
  },
} {
  let m22 = a11 * a22 - a21 * a12
  let m23 = a11 * a23 - a21 * a13
  let m32 = a11 * a32 - a31 * a12
  let m33 = a11 * a33 - a31 * a13
  (m22 * m33 - m23 * m32) / a11
}
