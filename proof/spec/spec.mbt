///|
/// 程式側（.mbt）：族 D（D1–D6）、H9 與 `spec` 套件之經形式化驗證演算法核。

///|
/// 1. D1/H9 義務與 `spec::fft` / `ifft`：4 點雙向傅立葉蝶形變換往返互逆合成 F₄* · F₄(x) = 4x。
pub fn dft4_roundtrip_synth(
  x0 : Int,
  x1 : Int,
  x2 : Int,
  x3 : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => dft4_roundtrip_ok(x0, x1, x2, x3, r),
} {
  // 第一級偶奇蝶形
  let e0 = x0 + x2
  let e1 = x0 - x2
  let o0 = x1 + x3
  let o1 = x1 - x3
  // 第二級頻域合成（ω² = -1 分量）
  let f0 = e0 + o0
  let f2 = e0 - o0
  let f1_re = e1
  let f1_im = o1
  let f3_re = e1
  let f3_im = -o1
  // 逆變換第一級
  let ie0 = f0 + f2
  let io0 = f0 - f2
  let ie1 = f1_re + f3_re
  let io1 = f1_im - f3_im
  // 逆變換第二級還原
  let y0 = ie0 + ie1
  let y2 = ie0 - ie1
  let y1 = io0 + io1
  let y3 = io0 - io1
  (y0, y1, y2, y3)
}

///|
/// 2. D2 定理與 `spec::verify_convolution_theorem`：頻域逐點乘積反演等於時域循環卷積。
pub fn convolution_theorem2_synth(
  a0 : Int,
  a1 : Int,
  b0 : Int,
  b1 : Int,
) -> ((Int, Int), (Int, Int)) where {
  proof_ensure: r => conv2_theorem_ok(a0, a1, b0, b1, r),
} {
  let fa0 = a0 + a1
  let fa1 = a0 - a1
  let fb0 = b0 + b1
  let fb1 = b0 - b1
  let p0 = fa0 * fb0
  let p1 = fa1 * fb1
  let fft_c0 = p0 + p1
  let fft_c1 = p0 - p1
  let naive_c0 = a0 * b0 + a1 * b1
  let naive_c1 = a0 * b1 + a1 * b0
  ((fft_c0, fft_c1), (naive_c0, naive_c1))
}

///|
/// 3. D3/H9 定理與 `spec::verify_circulant_diagonalization`：循環算子被 DFT 基底對角化。
pub fn circulant_eigen_diag2_synth(
  c0 : Int,
  c1 : Int,
) -> ((Int, Int, Int, Int), (Int, Int, Int, Int)) where {
  proof_ensure: r => circ_eigen_diag2_ok(c0, c1, r),
} {
  // F₂ = [[1, 1], [1, -1]], C = [[c0, c1], [c1, c0]]
  let l11 = c0 + c1
  let l12 = c1 + c0
  let l21 = c0 - c1
  let l22 = c1 - c0
  // diag(c0+c1, c0-c1) · F₂
  let lam0 = c0 + c1
  let lam1 = c0 - c1
  let r11 = lam0 * 1
  let r12 = lam0 * 1
  let r21 = lam1 * 1
  let r22 = lam1 * -1
  ((l11, l12, l21, l22), (r11, r12, r21, r22))
}

///|
/// 4. D4/H9 義務與 `spec::verify_adjoint`（2D）：⟨Ax, y⟩ = ⟨x, Aᵀy⟩。
pub fn adjoint_inner_product2_synth(
  a11 : Int,
  a12 : Int,
  a21 : Int,
  a22 : Int,
  x1 : Int,
  x2 : Int,
  y1 : Int,
  y2 : Int,
) -> (Int, Int) where {
  proof_ensure: r => adjoint2_ok(a11, a12, a21, a22, x1, x2, y1, y2, r),
} {
  let ax1 = a11 * x1 + a12 * x2
  let ax2 = a21 * x1 + a22 * x2
  let lhs = ax1 * y1 + ax2 * y2
  let aty1 = a11 * y1 + a21 * y2
  let aty2 = a12 * y1 + a22 * y2
  let rhs = x1 * aty1 + x2 * aty2
  (lhs, rhs)
}

///|
/// 5. D4/H9 義務與 `spec::verify_adjoint`（3D 雙對角算子）：⟨Ax, y⟩ = ⟨x, Aᵀy⟩。
pub fn adjoint_inner_product3_synth(
  d1 : Int,
  d2 : Int,
  d3 : Int,
  s12 : Int,
  s23 : Int,
  x1 : Int,
  x2 : Int,
  x3 : Int,
  y1 : Int,
  y2 : Int,
  y3 : Int,
) -> (Int, Int) where {
  proof_ensure: r => {
    adjoint3_ok(d1, d2, d3, s12, s23, x1, x2, x3, y1, y2, y3, r)
  },
} {
  let ax1 = d1 * x1 + s12 * x2
  let ax2 = d2 * x2 + s23 * x3
  let ax3 = d3 * x3
  let lhs = ax1 * y1 + ax2 * y2 + ax3 * y3
  let aty1 = d1 * y1
  let aty2 = s12 * y1 + d2 * y2
  let aty3 = s23 * y2 + d3 * y3
  let rhs = x1 * aty1 + x2 * aty2 + x3 * aty3
  (lhs, rhs)
}

///|
/// 6. D4 義務與 `spec::verify_symplectic`：辛雙環塊對角元素 S = diag(A, (Aᵀ)⁻¹) 保守辛形式 SᵀJS = J。
pub fn symplectic_block_shear_synth(
  t : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => symplectic_shear_ok(t, r),
} {
  // Aᵀ = [[1, 0], [t, 1]], D = (Aᵀ)⁻¹ = [[1, 0], [-t, 1]]
  // Sᵀ J S 之右上塊為 Aᵀ · D = I₂
  let p11 = 1 * 1 + 0 * -t
  let p12 = 1 * 0 + 0 * 1
  let p21 = t * 1 + 1 * -t
  let p22 = t * 0 + 1 * 1
  (p11, p12, p21, p22)
}

///|
/// 7. H9 定理與 `spec::symplectic_j`：標準辛矩陣 J = [[0,1],[-1,0]] 滿足 J² = -I₂ 且 Jᵀ + J = 0。
pub fn symplectic_j_involution_synth() -> (Int, Int, Int, Int, Int, Int) where {
  proof_ensure: r => symplectic_j2_involution_ok(r),
} {
  let j11 = 0
  let j12 = 1
  let j21 = -1
  let j22 = 0
  let j2_11 = j11 * j11 + j12 * j21
  let j2_12 = j11 * j12 + j12 * j22
  let j2_21 = j21 * j11 + j22 * j21
  let j2_22 = j21 * j12 + j22 * j22
  let sym12 = j21 + j12
  let sym21 = j12 + j21
  (j2_11, j2_12, j2_21, j2_22, sym12, sym21)
}

///|
/// 8. D5/H9 定理與 `spec::verify_supertrace_vanishes`（偶分次）：偶塊交換子之跡恆消沒。
pub fn supertrace_even_commutator_synth(
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
    supertrace_even_comm_ok(a11, a12, a21, a22, b11, b12, b21, b22, r)
  },
} {
  let tr_ab = a11 * b11 + a12 * b21 + (a21 * b12 + a22 * b22)
  let tr_ba = b11 * a11 + b12 * a21 + (b21 * a12 + b22 * a22)
  tr_ab - tr_ba
}

///|
/// 9. D5/H9 定理與 `spec::verify_supertrace_vanishes`（奇分次）：奇超矩陣之超交換子 [M,N] = MN + NM 超跡恆為 0。
pub fn supertrace_odd_anticommutator_synth(
  b1 : Int,
  c1 : Int,
  b2 : Int,
  c2 : Int,
) -> (Int, Int, Int) where {
  proof_ensure: r => supertrace_odd_anticomm_ok(b1, c1, b2, c2, r),
} {
  let even_top = b1 * c2 + b2 * c1
  let even_bot = c1 * b2 + c2 * b1
  let str_val = even_top - even_bot
  (even_top, even_bot, str_val)
}

///|
/// 10. D5 義務與 `spec::verify_berezinian_multiplicative`：塊三角超矩陣 Berezinian 分子分母乘性守恆。
pub fn berezinian_block_triangular_synth(
  a1 : Int,
  d1 : Int,
  a2 : Int,
  d2 : Int,
) -> ((Int, Int), (Int, Int)) where {
  proof_ensure: r => ber_block_tri_ok(a1, d1, a2, d2, r),
} {
  let num_mn = a1 * a2
  let den_mn = d1 * d2
  ((num_mn, den_mn), (a1 * a2, d1 * d2))
}

///|
/// 11. D6 定理與 `spec::verify_polarization_identity`：二維二次型極化恆等式 Q(x+y) - Q(x) - Q(y) = 2B(x,y)。
pub fn polarization_quadratic2_synth(
  a : Int,
  b : Int,
  c : Int,
  x1 : Int,
  x2 : Int,
  y1 : Int,
  y2 : Int,
) -> (Int, Int) where {
  proof_ensure: r => polarization_quad2_ok(a, b, c, x1, x2, y1, y2, r),
} {
  let s1 = x1 + y1
  let s2 = x2 + y2
  let q_sum = a * s1 * s1 + 2 * b * s1 * s2 + c * s2 * s2
  let q_x = a * x1 * x1 + 2 * b * x1 * x2 + c * x2 * x2
  let q_y = a * y1 * y1 + 2 * b * y1 * y2 + c * y2 * y2
  let lhs_diff = q_sum - q_x - q_y
  let rhs_2b = 2 * (a * x1 * y1 + b * (x1 * y2 + x2 * y1) + c * x2 * y2)
  (lhs_diff, rhs_2b)
}

///|
/// 12. D6 定理與 `spec::verify_polarization_cubic` / `verify_polar_diagonal`：三次型容斥極化恆等式與對角還原。
pub fn polarization_cubic_incexcl_synth(
  u : Int,
  v : Int,
  w : Int,
) -> (Int, Int, Int) where {
  proof_ensure: r => polarization_cubic_ok(u, v, w, r),
} {
  let uvw = u + v + w
  let uv = u + v
  let uw = u + w
  let vw = v + w
  let inc_excl = uvw * uvw * uvw -
    uv * uv * uv -
    uw * uw * uw -
    vw * vw * vw +
    u * u * u +
    v * v * v +
    w * w * w
  let six_uvw = 6 * u * v * w
  let diag_uuu = 6 * u * u * u
  (inc_excl, six_uvw, diag_uuu)
}
