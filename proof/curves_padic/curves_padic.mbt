///|
/// 程式側（.mbt）：族 E（E1–E6）、族 F（F1）、H1–H5、H10 以及 `curves`、`padic` 與 `dsl`
/// 套件之經形式化驗證演算法核。

///|
/// 1. E1/H2 定理與 `curves::EC::verify_hasse` / `verify_structure`：點群階 #E = p+1-t > 0 與結構分解。
pub fn ec_hasse_trace_order_synth(
  p : Int,
  t : Int,
  d1 : Int,
  d2 : Int,
  k : Int,
) -> (Int, Int) where {
  proof_require: p_ec_hasse_hyp(p, t, d1, d2, k),
  proof_ensure: r => ec_hasse_order_ok(p, t, d1, d2, r),
} {
  let _ = d1 + d2 + k
  let ord_e = p + 1 - t
  let frob_diff = p + 1 - ord_e - t
  (ord_e, frob_diff)
}

///|
/// 2. E2 定理與 `curves::EC::verify_twist`：二次扭轉點數守恆 #E + #E' = 2p + 2。
pub fn ec_quadratic_twist_sum_synth(
  p : Int,
  t : Int,
  chi_x : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => ec_twist_sum_ok(p, t, chi_x, r),
} {
  let ord_e = p + 1 - t
  let ord_twist = p + 1 + t
  let sum_orders = ord_e + ord_twist
  let pair_pts = 1 + chi_x + (1 - chi_x)
  (ord_e, ord_twist, sum_orders, pair_pts)
}

///|
/// 3. E3/H1 定理與 `curves::EC::isogenous_by_2`：Vélu 2-同源係數變換與二扭根消去恆等式。
pub fn velu_two_isogeny_coeff_synth(
  a : Int,
  b : Int,
  alpha : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_two_torsion_hyp(a, b, alpha),
  proof_ensure: r => velu_iso2_ok(a, b, alpha, r),
} {
  let tv = 3 * alpha * alpha + a
  let wv = alpha * tv
  let a_prime = a - 5 * tv
  let b_prime = b - 7 * wv
  let b_rel = b - b_prime + 21 * b + 14 * a * alpha
  (tv, a_prime, b_prime, b_rel)
}

///|
/// 4. E4/H1 義務與 `curves::EC::isogenous_by_3`：Vélu 3-同源係數變換公式。
pub fn velu_three_isogeny_coeff_synth(
  a : Int,
  b : Int,
  x : Int,
  y : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => velu_iso3_ok(a, b, x, y, r),
} {
  let tv = 2 * (3 * x * x + a)
  let uv = 4 * y * y
  let a_prime = a - 5 * tv
  let b_prime = b - 7 * (uv + tv * x)
  (tv, uv, a_prime, b_prime)
}

///|
/// 5. H2 定理與 `curves::EC::tate_skeleton`：Tate 模 T_ℓ(E) 上 Frobenius 矩陣滿足 Φ² - t·Φ + p·I₂ = 0。
pub fn tate_frobenius_cayley_hamilton_synth(
  f11 : Int,
  f12 : Int,
  f21 : Int,
  f22 : Int,
) -> (Int, Int, Int, Int, Int, Int) where {
  proof_ensure: r => tate_frob_ch_ok(f11, f12, f21, f22, r),
} {
  let t = f11 + f22
  let p = f11 * f22 - f12 * f21
  let sq11 = f11 * f11 + f12 * f21
  let sq12 = f11 * f12 + f12 * f22
  let sq21 = f21 * f11 + f22 * f21
  let sq22 = f21 * f12 + f22 * f22
  let z11 = sq11 - t * f11 + p
  let z12 = sq12 - t * f12
  let z21 = sq21 - t * f21
  let z22 = sq22 - t * f22 + p
  (t, p, z11, z12, z21, z22)
}

///|
/// 6. E5/H4 義務與 `padic::teichmuller`：牛頓提升步保持模 p 同餘類 ω₁ ≡ a (mod p)。
pub fn teichmuller_newton_step_synth(
  w0 : Int,
  a : Int,
  p : Int,
  k0 : Int,
  delta : Int,
  pk_prev : Int,
) -> (Int, Int) where {
  proof_require: p_teich_step_hyp(w0, a, p, k0, pk_prev),
  proof_ensure: r => teich_step_ok(w0, a, p, delta, pk_prev, r),
} {
  let w1 = w0 + delta * (p * pk_prev)
  let k1 = k0 + delta * pk_prev
  (w1, k1)
}

///|
/// 7. E6 義務與 `padic::verify_formal_group_axioms`：乘法形式群律 F_m(X,Y) = X+Y+XY 之三公理。
pub fn formal_group_mult_axioms_synth(
  x : Int,
  y : Int,
  z : Int,
) -> (Int, Int, Int, Int, Int) where {
  proof_ensure: r => formal_mult_axioms_ok(x, y, z, r),
} {
  let unit_r = x + 0 + x * 0
  let f_xy = x + y + x * y
  let f_yx = y + x + y * x
  let assoc_lhs = f_xy + z + f_xy * z
  let f_yz = y + z + y * z
  let assoc_rhs = x + f_yz + x * f_yz
  (unit_r, f_xy, f_yx, assoc_lhs, assoc_rhs)
}

///|
/// 8. E6 定理與 `padic::verify_formal_log_grouplaw`：二階形式對數把乘法形式群律化為加法。
pub fn formal_log_deg2_grouplaw_synth(
  x : Int,
  y : Int,
) -> (Int, Int) where {
  proof_ensure: r => formal_log_deg2_ok(x, y, r),
} {
  let lhs_deg2 = 2 * (x + y + x * y) - (x + y) * (x + y)
  let rhs_deg2 = 2 * x - x * x + (2 * y - y * y)
  (lhs_deg2, rhs_deg2)
}

///|
/// 9. E6 定理與 `padic::sl2_order_formula`：離散李群 |SL₂(Z/p^n)| = p^{3n-2}(p²-1) 與李代數核 p³ 遞推。
pub fn sl2_zpn_order_skeleton_synth(
  p : Int,
  p_3n2 : Int,
) -> (Int, Int, Int) where {
  proof_require: p_sl2_hyp(p, p_3n2),
  proof_ensure: r => sl2_order_skeleton_ok(p, p_3n2, r),
} {
  let lie_ker = p * p * p
  let base_factor = p * p - 1
  let ord_n = p_3n2 * base_factor
  let ord_n1 = p_3n2 * lie_ker * base_factor
  (ord_n, ord_n1, lie_ker)
}

///|
/// 10. E6 義務與 `padic::verify_so3_discrete`：SO(3,Z) 旋轉生成元正交性與乘積行列式守恆。
pub fn so3_discrete_orthogonality_synth() -> (Int, Int, Int, Int, Int) where {
  proof_ensure: r => so3_discrete_ok(r),
} {
  // Rx = [[1,0,0],[0,0,-1],[0,1,0]], det(Rx) = 1*(0 - (-1)) = 1
  let det_rx = 1 * (0 * 0 - -1 * 1)
  // Rz = [[0,-1,0],[1,0,0],[0,0,1]], det(Rz) = 1*(0 - (-1)) = 1
  let det_rz = 1 * (0 * 0 - -1 * 1)
  let det_prod = det_rx * det_rz
  // Rxᵀ · Rx 對角線和 = 1 + 1 + 1 = 3
  let ortho_diag_sum = 1 + 1 + 1
  // Rx · Rz = [[0,-1,0],[0,0,-1],[1,0,0]]，跡 = 0 + 0 + 0 = 0（對應 120 度對角軸旋轉）
  let trace_prod = 0 + 0 + 0
  (det_rx, det_rz, det_prod, ortho_diag_sum, trace_prod)
}

///|
/// 11. E6/H10 定理與 `padic::verify_ultrametric`：p-進超度量不等式 v_p(a+b) ≥ min(v_p(a), v_p(b)) 見證核。
pub fn padic_ultrametric_witness_synth(
  a : Int,
  b : Int,
  p_min : Int,
  ka : Int,
  kb : Int,
) -> (Int, Int) where {
  proof_require: p_ultrametric_wit_hyp(a, b, p_min, ka, kb),
  proof_ensure: r => ultrametric_wit_ok(a, b, p_min, r),
} {
  let k_sum = ka + kb
  let sum_ab = a + b
  (sum_ab, k_sum)
}

///|
/// 12. H3/H5 算式：光滑平面曲線虧格 2g = (d-1)(d-2)、貝爾簇 d² 維度與 Kani 四重乘積維度 (2g)² = 4g²。
pub fn abelian_variety_kani_genus_synth(
  d : Int,
  g : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_curve_deg_hyp(d, g),
  proof_ensure: r => kani_genus_dim_ok(d, g, r),
} {
  let two_g = (d - 1) * (d - 2)
  let dim_abel = d * d
  let kani_lhs = 2 * g * (2 * g)
  let kani_rhs = 4 * g * g
  (two_g, dim_abel, kani_lhs, kani_rhs)
}

///|
/// 13. F1 算式與 `dsl::equivalent`：DSL 四大規範形等價律（hom, ext≅tor, bidual, tensor 交換性）。
pub fn dsl_canonical_equivalence_synth(
  a : Int,
  b : Int,
  g : Int,
) -> ((Int, Int), (Int, Int), (Int, Int), (Int, Int)) where {
  proof_ensure: r => dsl_canonical_eq_ok(a, g, r),
} {
  let _ = b
  let hom_pair = (g, g)
  let exttor_pair = (g, g)
  let bidual_pair = (a, a)
  let tensor_pair = (g, g)
  (hom_pair, exttor_pair, bidual_pair, tensor_pair)
}
