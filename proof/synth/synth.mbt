///|
/// 程式側（.mbt）：經 Why3 + Z3/CVC5 形式驗證的「演算法合成與超優化」核心算子。
/// 每個算子同時展示：(1) 優化後之合成代碼；(2) 與樸素參考規格之完全等價性契約。

///|
/// 1. Horner 三次多項式求值合成：將 6 次乘法折減為 3 次乘法，並證明與展開式完全等價。
pub fn horner3_synth(
  a3 : Int,
  a2 : Int,
  a1 : Int,
  a0 : Int,
  x : Int,
) -> Int where {
  proof_ensure: r => horner3_ok(a3, a2, a1, a0, x, r),
} {
  ((a3 * x + a2) * x + a1) * x + a0
}

///|
/// 2. Gauss–Karatsuba 複數／高斯整數乘法合成：以 3 次純量乘法合成 4 次乘法的實部與虛部。
pub fn gauss_karatsuba_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int) where {
  proof_ensure: r => karatsuba_ok(a, b, c, d, r),
} {
  let k1 = a * c
  let k2 = b * d
  let k3 = (a + b) * (c + d)
  (k1 - k2, k3 - k1 - k2)
}

///|
/// 3. Cayley–Hamilton 2×2 矩陣二次冪降階合成：利用 A² = tr(A)·A − det(A)·I 將矩陣乘法降為純量線性組合。
pub fn ch_power2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => ch_pow2_ok(a, b, c, d, r),
} {
  let tr = a + d
  let det = a * d - b * c
  (tr * a - det, tr * b, tr * c, tr * d - det)
}

///|
/// 4. 伴隨矩陣（Adjugate）無除法求解器合成：對 b_vec = A·(x,y)ᵀ 施以 A^adj 直接還原 det(A)·(x,y)ᵀ。
pub fn adjugate_solve_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  x : Int,
  y : Int,
) -> (Int, Int) where {
  proof_ensure: r => adjugate_solve_ok(a, b, c, d, x, y, r),
} {
  let rhs0 = a * x + b * y
  let rhs1 = c * x + d * y
  let rx = d * rhs0 - b * rhs1
  let ry = -c * rhs0 + a * rhs1
  (rx, ry)
}

///|
/// 5. Bézout 擴展歐幾里得單步見證合成：由遞迴子問題見證 b·u₁ + (a mod b)·v₁ = g 構造 a·u + b·v = g。
pub fn bezout_step_synth(
  a : Int,
  b : Int,
  u1 : Int,
  v1 : Int,
  g : Int,
) -> (Int, Int) where {
  proof_require: p_bezout_step_hyp(a, b, u1, v1, g),
  proof_ensure: r => bezout_step_ok(a, b, g, r),
} {
  let q = a / b
  (v1, u1 - q * v1)
}

///|
/// 6. 四分之一平方乘法強度折減：(x+y)² − (x−y)² = 4xy（以平方與減法合成乘法）。
pub fn quarter_square_synth(
  x : Int,
  y : Int,
) -> Int where {
  proof_ensure: r => quarter_sq_ok(x, y, r),
} {
  let s = x + y
  let d = x - y
  s * s - d * d
}

///|
/// 7a. 二點蝶形 DFT 演算法與逆蝶形往返合成：H₂(H₂(x)) = 2x。
pub fn butterfly_roundtrip_synth(
  x0 : Int,
  x1 : Int,
) -> (Int, Int) where {
  proof_ensure: r => butterfly_rt_ok(x0, x1, r),
} {
  let y0 = x0 + x1
  let y1 = x0 - x1
  (y0 + y1, y0 - y1)
}

///|
/// 7b. 二點蝶形 DFT 的 Parseval 能量守恆憑證：y₀² + y₁² = 2(x₀² + x₁²)。
pub fn butterfly_transform_synth(
  x0 : Int,
  x1 : Int,
) -> (Int, Int) where {
  proof_ensure: r => butterfly_parseval_ok(x0, x1, r),
} {
  (x0 + x1, x0 - x1)
}

///|
/// 8. Brahmagupta–Fibonacci 二平方和範數乘性合成：合成複合高斯同源的度數分解見證。
pub fn brahmagupta_fibonacci_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int) where {
  proof_ensure: r => brahmagupta_ok(a, b, c, d, r),
} {
  (a * c - b * d, a * d + b * c)
}

///|
/// 9. CEGIS 反例引導修補：將僅在 a ≥ 0 正確的截斷除法修補為對任意整數 a ∈ ℤ（含負數）
/// 均滿足歐幾里得契約 a = b·q + rem ∧ 0 ≤ rem < b 的全定義域算子。
pub fn euclid_div_mod_repaired(
  a : Int,
  b : Int,
) -> (Int, Int) where {
  proof_require: p_pos_divisor(b),
  proof_ensure: r => euclid_total_ok(a, b, r),
} {
  let q0 = a / b
  let r0 = a % b
  if r0 < 0 {
    (q0 - 1, r0 + b)
  } else {
    (q0, r0)
  }
}

///|
/// 10. 辛雙環標準交錯形式 vᵀ J v 零化消去超優化：任意向量與自身之辛配對恆為 0（O(n) → O(1) 常數摺疊）。
pub fn symplectic_self_pairing_synth(
  x : Int,
  y : Int,
) -> Int where {
  proof_ensure: r => symplectic_alt_ok(x, y, r),
} {
  let _ = x + y
  0
}

///|
/// 11. 循環算子 2×2 雙向 FFT 對角化合成：在頻域僅用 2 次純量乘法合成時域 4 次乘法的循環摺積。
pub fn circulant2_fft_diag_synth(
  c0 : Int,
  c1 : Int,
  x0 : Int,
  x1 : Int,
) -> (Int, Int) where {
  proof_ensure: r => circulant2_fft_ok(c0, c1, x0, x1, r),
} {
  let fc0 = c0 + c1
  let fc1 = c0 - c1
  let fx0 = x0 + x1
  let fx1 = x0 - x1
  let p0 = fc0 * fx0
  let p1 = fc1 * fx1
  (p0 + p1, p0 - p1)
}

///|
/// 12. 辛算子逆元對合消去：(-J)·J·(x,y) = (x,y)（驗證 E-graph 重寫規則 NegJ(J(v)) → v）。
pub fn symplectic_inv_synth(
  x : Int,
  y : Int,
) -> (Int, Int) where {
  proof_ensure: r => symplectic_inv_ok(x, y, r),
} {
  let jx = y
  let jy = -x
  (-jy, jx)
}

///|
/// 13. 伴隨／轉置反變函子重寫：驗證 Bᵀ·Aᵀ 與 (A·B)ᵀ 逐分量恆等。
pub fn transpose_mul2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  e : Int,
  f : Int,
  g : Int,
  h : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => transpose_mul2_ok(a, b, c, d, e, f, g, h, r),
} {
  let bt11 = e
  let bt12 = g
  let bt21 = f
  let bt22 = h
  let at11 = a
  let at12 = c
  let at21 = b
  let at22 = d
  (
    bt11 * at11 + bt12 * at21,
    bt11 * at12 + bt12 * at22,
    bt21 * at11 + bt22 * at21,
    bt21 * at12 + bt22 * at22,
  )
}

///|
/// 14. 乘積跡循環不變與點積降階合成：將 8 次乘法的矩陣乘積取跡降為 4 次雙線性內積乘法。
pub fn trace_cyclic2_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  e : Int,
  f : Int,
  g : Int,
  h : Int,
) -> Int where {
  proof_ensure: r => trace_cyclic2_ok(a, b, c, d, e, f, g, h, r),
} {
  a * e + b * g + c * f + d * h
}

///|
/// 15. Rosati 對合與 Kani 同源鑽石合成：驗證複合自同態 α†·α 退化為純量同源 [a²+b²]。
pub fn rosati_kani_synth(
  a : Int,
  b : Int,
  x : Int,
  y : Int,
) -> (Int, Int) where {
  proof_ensure: r => rosati_kani_ok(a, b, x, y, r),
} {
  let ux = a * x - b * y
  let uy = b * x + a * y
  (a * ux + b * uy, -b * ux + a * uy)
}

///|
/// 16. Hensel 二次牛頓提升步（p^k → p^{2k}）構造性見證合成：同時給出提升解 x₁ 與模 p^{2k} 整除餘因子 k₂。
pub fn hensel_sqrt_step_synth(
  x0 : Int,
  c : Int,
  t : Int,
  pk : Int,
  m : Int,
) -> (Int, Int) where {
  proof_require: p_hensel_hyp(x0, c, t, pk, m),
  proof_ensure: r => hensel_step_ok(x0, c, t, pk, r),
} {
  (x0 + t * pk, m + t * t)
}

///|
/// 17. Pontryagin 二重對偶／二重轉置消去：驗證 Dual(Dual(A)) → A。
pub fn bidual2_involution_synth(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> (Int, Int, Int, Int) where {
  proof_ensure: r => bidual2_ok(a, b, c, d, r),
} {
  let t11 = a
  let t12 = c
  let t21 = b
  let t22 = d
  (t11, t21, t12, t22)
}

///|
/// 18. Estrin 平行樹多項式求值合成：將關鍵路徑深度由 O(d) 降為 O(log d)，並證明與樸素式及 Horner 式三方等價。
pub fn estrin3_synth(
  a3 : Int,
  a2 : Int,
  a1 : Int,
  a0 : Int,
  x : Int,
) -> Int where {
  proof_ensure: r => estrin3_ok(a3, a2, a1, a0, x, r),
} {
  let x2 = x * x
  let hi = a3 * x + a2
  let lo = a1 * x + a0
  hi * x2 + lo
}
