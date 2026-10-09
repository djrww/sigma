///|
/// 程式側（.mbt）：第二代矩陣體系（Grassmann 超矩陣、多項式 λ-矩陣、Kronecker 階層矩陣、
/// Tropical 極值半環矩陣、位移秩矩陣）之形式化驗證核心算子。

///|
/// 1. Grassmann 偶子代數 Λ₀ = Z[η]/(η²) 乘法算子。
pub fn grassmann_even_mul_synth(
  a0 : Int,
  a1 : Int,
  b0 : Int,
  b1 : Int,
) -> (Int, Int) where {
  proof_ensure: r => grassmann_even_mul_ok(a0, a1, b0, b1, r),
} {
  (a0 * b0, a0 * b1 + a1 * b0)
}

///|
/// 2. Grassmann 奇空間 Λ₁ 外積算子：驗證反交換律 u∧v = -v∧u 與冪零性 u∧u = 0。
pub fn grassmann_odd_wedge_synth(
  u1 : Int,
  u2 : Int,
  v1 : Int,
  v2 : Int,
) -> (Int, Int, Int) where {
  proof_ensure: r => grassmann_odd_wedge_ok(u1, u2, v1, v2, r),
} {
  let uv = u1 * v2 - u2 * v1
  let vu = v1 * u2 - v2 * u1
  let uu = u1 * u2 - u2 * u1
  (uv, vu, uu)
}

///|
/// 3a. Grassmann 超矩陣 Berezinian 完整乘法性證明：
/// 當奇部元素反交換（θ₂θ₁ = -θ₁θ₂）時，即使奇部 b, c, f, g 皆非零，
/// Ber_Λ(M ·_Λ N) 與 Ber_Λ(M) ·_Λ Ber_Λ(N) 之標量部與靈魂部（soul part, θ₁θ₂ 係數）完全相等！
pub fn ber_grassmann_multiplicative_synth(
  a : Int,
  b : Int,
  c : Int,
  e : Int,
  f : Int,
  g : Int,
) -> ((Int, Int), (Int, Int)) where {
  proof_ensure: r => ber_grassmann_mul_ok(a, b, c, e, f, g, r),
} {
  // M ·_Λ N 之偶部：P00 = a*e + b*g*η, P11 = 1 - c*f*η (因 θ₂θ₁ = -η)
  // P01 = (a*f + b)*θ₁, P10 = (c*e + g)*θ₂
  // Schur 補 = P00 - P01 * P11⁻¹ * P10 = a*e + (b*g - (a*f + b)*(c*e + g))*η
  // 乘以 P11⁻¹ = 1 + c*f*η：
  let schur0 = a * e
  let schur1 = b * g - (a * f + b) * (c * e + g)
  let lhs0 = schur0
  let lhs1 = schur1 + schur0 * (c * f)
  // 右式 Ber_Λ(M) * Ber_Λ(N) = (a - b*c*η) * (e - f*g*η)
  let rhs0 = a * e
  let rhs1 = -(a * (f * g) + b * c * e)
  ((lhs0, lhs1), (rhs0, rhs1))
}

///|
/// 3b. 第一代交換矩陣 `core::Mat` 之 Berezinian 乘法性缺陷證明：
/// 在交換環（θ₂θ₁ = +θ₁θ₂）中，P11 = 1 + c*f*η ⟹ P11⁻¹ = 1 - c*f*η，
/// 導致 Ber_comm(MN) 與 Ber_comm(M)·Ber_comm(N) 之間恆差一個非零交叉項 -2·a·c·e·f！
pub fn ber_commutative_defect_synth(
  a : Int,
  b : Int,
  c : Int,
  e : Int,
  f : Int,
  g : Int,
) -> Int where {
  proof_ensure: d => ber_commutative_defect_ok(a, b, c, e, f, g, d),
} {
  let comm_lhs1 = b * g - (a * f + b) * (c * e + g) - a * e * c * f
  let comm_rhs1 = -(a * f * g + b * c * e)
  comm_lhs1 - comm_rhs1
}

///|
/// 4a. Kronecker 張量積矩陣 A ⊗ B 跡分解合成：tr(A ⊗ B) = tr(A)·tr(B)（O(n²) → O(n)）。
pub fn kronecker_trace2_synth(
  a11 : Int,
  a12 : Int,
  a21 : Int,
  a22 : Int,
  b11 : Int,
  b12 : Int,
  b21 : Int,
  b22 : Int,
) -> Int where {
  proof_ensure: r => {
    kronecker_trace2_ok(a11, a12, a21, a22, b11, b12, b21, b22, r)
  },
} {
  let _ = a12 + a21 + b12 + b21
  (a11 + a22) * (b11 + b22)
}

///|
/// 4b. Kronecker 張量積行列式冪次合成：det(A ⊗ B) = det(A)^m · det(B)^n。
pub fn kronecker_det_diag2_synth(
  a1 : Int,
  a2 : Int,
  b1 : Int,
  b2 : Int,
) -> Int where {
  proof_ensure: r => kronecker_det_diag2_ok(a1, a2, b1, b2, r),
} {
  let det_a = a1 * a2
  let det_b = b1 * b2
  det_a * det_a * (det_b * det_b)
}

///|
/// 5. 多項式特徵鉛筆 xI - A 分離定理：
/// 證明么模剪切矩陣 [1, k; 0, 1] 與雙曲矩陣 [k+1, k; 1, 1] 在第一代 `core::Mat` 下有相同行列式 1
/// （及相同整數 SNF = diag(1,1)），但在多項式矩陣 xI - A 下特徵判別式分別為 0 與 k(k+4) > 0！
pub fn poly_pencil_separation_synth(
  k : Int,
) -> (Int, Int, Int, Int) where {
  proof_require: p_pos_k(k),
  proof_ensure: r => poly_pencil_sep_ok(k, r),
} {
  // A_shear = [1, k; 0, 1] -> tr = 2, det = 1, disc = tr² - 4*det = 0
  let det_shear = 1 * 1 - k * 0
  let tr_shear = 1 + 1
  let disc_shear = tr_shear * tr_shear - 4 * det_shear
  // A_hyp = [k+1, k; 1, 1] -> tr = k+2, det = (k+1)*1 - k*1 = 1, disc = (k+2)² - 4 = k(k+4)
  let det_hyp = (k + 1) * 1 - k * 1
  let tr_hyp = k + 1 + 1
  let disc_hyp = tr_hyp * tr_hyp - 4 * det_hyp
  (det_shear, det_hyp, disc_shear, disc_hyp)
}

///|
/// 6a. Tropical (min, +) 加法結合律算子。
pub fn tropical_assoc_synth(
  a : Int,
  b : Int,
  c : Int,
) -> (Int, Int) where {
  proof_ensure: r => tropical_scalar_assoc_ok(a, b, c, r),
} {
  let ab = if a <= b { a } else { b }
  let lhs = if ab <= c { ab } else { c }
  let bc = if b <= c { b } else { c }
  let rhs = if a <= bc { a } else { bc }
  (lhs, rhs)
}

///|
/// 6b. Tropical 乘法（+）對 Tropical 加法（min）之左分配律：a + min(b,c) == min(a+b, a+c)。
pub fn tropical_distrib_synth(
  a : Int,
  b : Int,
  c : Int,
) -> (Int, Int) where {
  proof_ensure: r => tropical_distrib_ok(a, b, c, r),
} {
  let bc = if b <= c { b } else { c }
  let lhs = a + bc
  let ab = a + b
  let ac = a + c
  let rhs = if ab <= ac { ab } else { ac }
  (lhs, rhs)
}

///|
/// 6c. Tropical 行列式與 p-進賦值牛頓下界：tdet(v_p(A)) = min(v(a)+v(d), v(b)+v(c)) ≤ v_p(det A)。
pub fn tropical_det2_valuation_synth(
  va : Int,
  vb : Int,
  vc : Int,
  vd : Int,
  v_det : Int,
) -> Int where {
  proof_require: p_ultrametric_val_hyp(va, vb, vc, vd, v_det),
  proof_ensure: tdet => tropical_det2_bound_ok(va, vb, vc, vd, v_det, tdet),
} {
  let d1 = va + vd
  let d2 = vb + vc
  if d1 <= d2 {
    d1
  } else {
    d2
  }
}

///|
/// 7. 循環矩陣與循環移位算子 S₂ = [0, 1; 1, 0] 之位移交換子零化：S₂·C - C·S₂ = 0（位移秩 = 0）。
pub fn displacement_circulant2_synth(
  c0 : Int,
  c1 : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => displacement_circ2_ok(c0, c1, r),
} {
  // S₂ · [c0, c1; c1, c0] = [c1, c0; c0, c1]
  // [c0, c1; c1, c0] · S₂ = [c1, c0; c0, c1]
  (c1 - c1, c0 - c0, c0 - c0, c1 - c1)
}
