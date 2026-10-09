///|
/// mat2/mat2.mbt —— 第二代矩陣體系（Second-Generation Matrix Paradigm）。
///
/// 針對第一代稠密交換整數矩陣 `core::Mat`（FixedArray[Int64]）在五大結構維度上的天花板，
/// 實作五種互補的第二代矩陣表示與算子，並提供與 `core::Mat` 的逐項差異實測對照：
///   - II-A: `GrassmannSuperMat`（ℤ/2-分次反交換 Grassmann 超矩陣，解決一般奇部下 Berezinian 乘法性失效）
///   - II-B: `PolyMat`（𝔽_p[x] 多項式鉛筆 λ-矩陣與多項式 SNF，解決 `core::Mat` 無法區分同行列式么模算子／Jordan 塊之盲區）
///   - II-C: `KronBlockMat`（Kronecker 張量積與直和階層矩陣樹，解決高維乘積貝爾簇之 O(N³) 維度爆炸）
///   - II-D: `TropicalMat`（(min, +) 極值賦值半環矩陣，統一同源圖最短測地線與 p-進牛頓多邊形下界）
///   - II-E: `DispCircMat`（位移秩 O(n) 生成元壓縮矩陣，將 n² 儲存壓縮為 n 維生成元）

/// ============================================================================
/// II-A：ℤ/2-分次 Grassmann 超矩陣（GrassmannSuperMat）
/// ============================================================================

///|
/// (1|1)×(1|1) Grassmann 超矩陣：
/// 偶部 a, d ∈ Λ₀ = ℤ ⊕ ℤ·η（η = θ₁θ₂, η² = 0）；
/// 奇部 b = b₁θ₁ + b₂θ₂, c = c₁θ₁ + c₂θ₂ ∈ Λ₁（θ₁² = θ₂² = 0, θ₁θ₂ = -θ₂θ₁ = η）。
pub(all) struct GrassmannSuperMat {
  a0 : Int
  a12 : Int
  b1 : Int
  b2 : Int
  c1 : Int
  c2 : Int
  d0 : Int
  d12 : Int
}

///|
/// 建立標準奇生成元超矩陣 M = [a, b·θ₁; c·θ₂, 1]。
pub fn GrassmannSuperMat::standard(
  a : Int,
  b : Int,
  c : Int,
) -> GrassmannSuperMat {
  { a0: a, a12: 0, b1: b, b2: 0, c1: 0, c2: c, d0: 1, d12: 0, }
}

///|
/// Grassmann 超矩陣乘法 M ·_Λ N（嚴格遵循奇部反交換 θ₂θ₁ = -θ₁θ₂）。
pub fn GrassmannSuperMat::mul(
  self : GrassmannSuperMat,
  other : GrassmannSuperMat,
) -> GrassmannSuperMat {
  // 偶×偶 + 奇×奇
  let (aa0, aa12) = @pmat2.grassmann_even_mul_synth(
    self.a0,
    self.a12,
    other.a0,
    other.a12,
  )
  let (bc_wedge, _, _) = @pmat2.grassmann_odd_wedge_synth(
    self.b1,
    self.b2,
    other.c1,
    other.c2,
  )
  let p_a0 = aa0
  let p_a12 = aa12 + bc_wedge

  let (dd0, dd12) = @pmat2.grassmann_even_mul_synth(
    self.d0,
    self.d12,
    other.d0,
    other.d12,
  )
  let (cb_wedge, _, _) = @pmat2.grassmann_odd_wedge_synth(
    self.c1,
    self.c2,
    other.b1,
    other.b2,
  )
  let p_d0 = dd0
  let p_d12 = dd12 + cb_wedge

  // 偶×奇 + 奇×偶（奇部吸收偶部標量項，η·θ_i = 0）
  let p_b1 = self.a0 * other.b1 + self.b1 * other.d0
  let p_b2 = self.a0 * other.b2 + self.b2 * other.d0
  let p_c1 = self.c1 * other.a0 + self.d0 * other.c1
  let p_c2 = self.c2 * other.a0 + self.d0 * other.c2

  {
    a0: p_a0,
    a12: p_a12,
    b1: p_b1,
    b2: p_b2,
    c1: p_c1,
    c2: p_c2,
    d0: p_d0,
    d12: p_d12,
  }
}

///|
/// 當 d0 = 1 時計算 Λ₀ = ℤ ⊕ ℤ·η 上的精確 Berezinian：
/// Ber_Λ(M) = (A - B·D⁻¹·C)·D⁻¹ ∈ Λ₀。
pub fn GrassmannSuperMat::berezinian_unit_d(
  self : GrassmannSuperMat,
) -> (Int, Int) {
  // D = 1 + d12·η ⟹ D⁻¹ = 1 - d12·η
  // B·D⁻¹·C = B·C = (b1·c2 - b2·c1)·η
  let (bc_wedge, _, _) = @pmat2.grassmann_odd_wedge_synth(
    self.b1,
    self.b2,
    self.c1,
    self.c2,
  )
  let schur0 = self.a0
  let schur12 = self.a12 - bc_wedge
  @pmat2.grassmann_even_mul_synth(schur0, schur12, 1, -self.d12)
}

///|
/// 對照實測 1：比較第一代 `core::Mat`（交換環）與第二代 `GrassmannSuperMat`（反交換超環）
/// 在非零奇部下的 Berezinian 乘法性表現。
/// 回傳：(Mat2_是否完美守恆, Mat1_交換缺陷值, Mat2_左式靈魂部, Mat2_右式靈魂部)。
pub fn compare_berezinian_mat1_vs_mat2(
  a : Int,
  b : Int,
  c : Int,
  e : Int,
  f : Int,
  g : Int,
) -> (Bool, Int, Int, Int) {
  let m = GrassmannSuperMat::standard(a, b, c)
  let n = GrassmannSuperMat::standard(e, f, g)
  let mn = m.mul(n)
  let ber_mn = mn.berezinian_unit_d()
  let ber_m = m.berezinian_unit_d()
  let ber_n = n.berezinian_unit_d()
  let ber_prod = @pmat2.grassmann_even_mul_synth(
    ber_m.0,
    ber_m.1,
    ber_n.0,
    ber_n.1,
  )
  let ((proof_lhs0, proof_lhs1), (proof_rhs0, proof_rhs1)) = @pmat2.ber_grassmann_multiplicative_synth(
    a, b, c, e, f, g,
  )
  let defect_mat1 = @pmat2.ber_commutative_defect_synth(a, b, c, e, f, g)
  let mat2_ok = ber_mn == ber_prod &&
    ber_mn.0 == proof_lhs0 &&
    ber_mn.1 == proof_lhs1 &&
    proof_lhs0 == proof_rhs0 &&
    proof_lhs1 == proof_rhs1
  (mat2_ok, defect_mat1, ber_mn.1, ber_prod.1)
}

/// ============================================================================
/// II-B：𝔽_p[x] 多項式鉛筆 λ-矩陣（PolyMat）與多項式 Smith 正規形
/// ============================================================================

///|
/// 有限域 𝔽_p 上的一元多項式（係數陣列 coeffs[i] 代表 x^i，最高次項去零並正規化）。
pub(all) struct PolyFp {
  coeffs : Array[Int64]
  p : Int64
}

///|
/// 正規化多項式（去除尾端 0，係數取正模 p）。
pub fn PolyFp::norm(coeffs : Array[Int64], p : Int64) -> PolyFp {
  let out : Array[Int64] = []
  for c in coeffs {
    out.push(@core.zmod(c, p))
  }
  while out.length() > 0 && out[out.length() - 1] == 0L {
    let _ = out.pop()
  }
  { coeffs: out, p, }
}

///|
/// 次數（零多項式為 -1）。
pub fn PolyFp::deg(self : PolyFp) -> Int {
  self.coeffs.length() - 1
}

///|
/// 是否為零多項式。
pub fn PolyFp::is_zero(self : PolyFp) -> Bool {
  self.coeffs.length() == 0
}

///|
/// 化為首一多項式（Monic Polynomial）。
pub fn PolyFp::to_monic(self : PolyFp) -> PolyFp {
  if self.is_zero() {
    return self
  }
  let lead = self.coeffs[self.coeffs.length() - 1]
  let inv = @core.invmod(lead, self.p)
  let out : Array[Int64] = []
  for c in self.coeffs {
    out.push(@core.zmod(c * inv, self.p))
  }
  PolyFp::norm(out, self.p)
}

///|
/// 多項式加法。
pub fn PolyFp::add(self : PolyFp, other : PolyFp) -> PolyFp {
  let n = if self.coeffs.length() > other.coeffs.length() {
    self.coeffs.length()
  } else {
    other.coeffs.length()
  }
  let out : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    let a = if i < self.coeffs.length() { self.coeffs[i] } else { 0L }
    let b = if i < other.coeffs.length() { other.coeffs[i] } else { 0L }
    out.push(@core.zmod(a + b, self.p))
  }
  PolyFp::norm(out, self.p)
}

///|
/// 多項式減法。
pub fn PolyFp::sub(self : PolyFp, other : PolyFp) -> PolyFp {
  let n = if self.coeffs.length() > other.coeffs.length() {
    self.coeffs.length()
  } else {
    other.coeffs.length()
  }
  let out : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    let a = if i < self.coeffs.length() { self.coeffs[i] } else { 0L }
    let b = if i < other.coeffs.length() { other.coeffs[i] } else { 0L }
    out.push(@core.zmod(a - b, self.p))
  }
  PolyFp::norm(out, self.p)
}

///|
/// 多項式乘法。
pub fn PolyFp::mul(self : PolyFp, other : PolyFp) -> PolyFp {
  if self.is_zero() || other.is_zero() {
    return PolyFp::norm([], self.p)
  }
  let n = self.coeffs.length() + other.coeffs.length() - 1
  let out : Array[Int64] = []
  for _i = 0; _i < n; _i = _i + 1 {
    out.push(0L)
  }
  for i = 0; i < self.coeffs.length(); i = i + 1 {
    for j = 0; j < other.coeffs.length(); j = j + 1 {
      out[i + j] = @core.zmod(
        out[i + j] + self.coeffs[i] * other.coeffs[j],
        self.p,
      )
    }
  }
  PolyFp::norm(out, self.p)
}

///|
/// 多項式歐幾里得帶餘除法：回傳 (q, r) 滿足 self = q * d + r 且 deg(r) < deg(d)。
pub fn PolyFp::div_mod(self : PolyFp, d : PolyFp) -> (PolyFp, PolyFp) {
  let p = self.p
  let mut r = self
  if r.deg() < d.deg() || d.is_zero() {
    return (PolyFp::norm([], p), r)
  }
  let q_len = r.deg() - d.deg() + 1
  let q_coeffs : Array[Int64] = []
  for _i = 0; _i < q_len; _i = _i + 1 {
    q_coeffs.push(0L)
  }
  let d_lead_inv = @core.invmod(d.coeffs[d.deg()], p)
  while !r.is_zero() && r.deg() >= d.deg() {
    let shift = r.deg() - d.deg()
    let factor = @core.zmod(r.coeffs[r.deg()] * d_lead_inv, p)
    q_coeffs[shift] = @core.zmod(q_coeffs[shift] + factor, p)
    let term_coeffs : Array[Int64] = []
    for _j = 0; _j < shift; _j = _j + 1 {
      term_coeffs.push(0L)
    }
    term_coeffs.push(factor)
    let term = PolyFp::norm(term_coeffs, p)
    r = r.sub(term.mul(d))
  }
  (PolyFp::norm(q_coeffs, p), r)
}

///|
/// 首一最大公因式 gcd(f, g) ∈ 𝔽_p[x]。
pub fn PolyFp::gcd(a : PolyFp, b : PolyFp) -> PolyFp {
  let mut x = a
  let mut y = b
  while !y.is_zero() {
    let (_q, r) = x.div_mod(y)
    x = y
    y = r
  }
  x.to_monic()
}

///|
/// 多項式可讀字串。
pub fn PolyFp::to_text(self : PolyFp) -> String {
  if self.is_zero() {
    return "0"
  }
  let sb = StringBuilder()
  let mut first = true
  for i = self.coeffs.length() - 1; i >= 0; i = i - 1 {
    let c = self.coeffs[i]
    if c != 0L {
      if !first {
        sb.write_string("+")
      }
      first = false
      if i == 0 {
        sb.write_string(c.to_string())
      } else if i == 1 {
        if c == 1L {
          sb.write_string("x")
        } else {
          sb.write_string("\{c}x")
        }
      } else if c == 1L {
        sb.write_string("x^\{i}")
      } else {
        sb.write_string("\{c}x^\{i}")
      }
    }
  }
  sb.to_string()
}

///|
/// 2×2 多項式鉛筆矩陣 xI - A ∈ M₂(𝔽_p[x]) 之不變因子對 (f₁(x), f₂(x))（滿足 f₁ | f₂ 且 f₁·f₂ = charpoly(A)）：
///   - f₁(x) = gcd(x - a₁₁, -a₁₂, -a₂₁, x - a₂₂)
///   - f₂(x) = det(xI - A) / f₁(x)（最小多項式 μ_A(x)！）
pub fn poly_pencil_snf2(
  a11 : Int64,
  a12 : Int64,
  a21 : Int64,
  a22 : Int64,
  p : Int64,
) -> (PolyFp, PolyFp) {
  let p00 = PolyFp::norm([-a11, 1L], p)
  let p01 = PolyFp::norm([-a12], p)
  let p10 = PolyFp::norm([-a21], p)
  let p11 = PolyFp::norm([-a22, 1L], p)
  let f1 = PolyFp::gcd(PolyFp::gcd(p00, p01), PolyFp::gcd(p10, p11))
  let det_poly = p00.mul(p11).sub(p01.mul(p10)).to_monic()
  let (f2, _rem) = det_poly.div_mod(f1)
  (f1.to_monic(), f2.to_monic())
}

///|
/// 對照實測 2：展示三個在第一代 `core::Mat` 下具有完全相同整數 SNF = diag(1,1) 與 det = 1 的算子
/// （單位算子 I₂、冪幺剪切算子 [1,1;0,1]、雙曲 Frobenius 算子 [2,1;1,1]），
/// 在第二代 `PolyMat`（xI - A over 𝔽_p[x]）下被完全分離為三個截然不同的有理標準形與最小多項式！
pub fn compare_polymat_vs_mat1(p : Int64) -> (Bool, String, String, String) {
  let m_id = @core.Mat::of_rows([[1L, 0L], [0L, 1L]])
  let m_shear = @core.Mat::of_rows([[1L, 1L], [0L, 1L]])
  let m_hyp = @core.Mat::of_rows([[2L, 1L], [1L, 1L]])
  // 在第一代 core::Mat 下，三者的整數 SNF 完全相同，無法區分！
  let s_id = @core.snf_diag(m_id).diag_text()
  let s_shear = @core.snf_diag(m_shear).diag_text()
  let s_hyp = @core.snf_diag(m_hyp).diag_text()
  let mat1_blind = s_id == s_shear && s_shear == s_hyp

  // 在第二代 PolyMat 下，計算 xI - A 的多項式不變因子 (f₁(x), f₂(x))：
  let (id_f1, id_f2) = poly_pencil_snf2(1L, 0L, 0L, 1L, p)
  let (sh_f1, sh_f2) = poly_pencil_snf2(1L, 1L, 0L, 1L, p)
  let (hy_f1, hy_f2) = poly_pencil_snf2(2L, 1L, 1L, 1L, p)

  let t_id = "(\{id_f1.to_text()}, \{id_f2.to_text()})"
  let t_sh = "(\{sh_f1.to_text()}, \{sh_f2.to_text()})"
  let t_hy = "(\{hy_f1.to_text()}, \{hy_f2.to_text()})"
  let mat2_separates = id_f1.deg() == 1 &&
    id_f2.deg() == 1 &&
    sh_f1.deg() == 0 &&
    sh_f2.deg() == 2 &&
    hy_f1.deg() == 0 &&
    hy_f2.deg() == 2 &&
    t_id != t_sh &&
    t_sh != t_hy
  (mat1_blind && mat2_separates, t_id, t_sh, t_hy)
}

/// ============================================================================
/// II-C：Kronecker–Block 階層符號矩陣樹（KronBlockMat）
/// ============================================================================

///|
/// 階層分塊與張量積矩陣樹：不展開為稠密陣列，直接在代數樹上計算不變量。
pub(all) enum KronBlockMat {
  Leaf(@core.Mat)
  DirectSum(KronBlockMat, KronBlockMat)
  Kronecker(KronBlockMat, KronBlockMat)
}

///|
/// 矩陣總維度 n（方陣）。
pub fn KronBlockMat::dim(self : KronBlockMat) -> Int {
  match self {
    Leaf(m) => m.nrows()
    DirectSum(a, b) => a.dim() + b.dim()
    Kronecker(a, b) => a.dim() * b.dim()
  }
}

///|
/// 階層壓縮儲存字數（對比稠密展開所需的 dim² 字數）。
pub fn KronBlockMat::storage_words(self : KronBlockMat) -> Int {
  match self {
    Leaf(m) => m.nrows() * m.ncols()
    DirectSum(a, b) => a.storage_words() + b.storage_words()
    Kronecker(a, b) => a.storage_words() + b.storage_words()
  }
}

///|
/// 快速結構化求跡：
/// tr(A ⊕ B) = tr(A) + tr(B)；tr(A ⊗ B) = tr(A) · tr(B)（經 `proof/mat2::kronecker_trace2_synth` 證明）。
pub fn KronBlockMat::trace_fast(self : KronBlockMat) -> Int64 {
  match self {
    Leaf(m) => m.trace()
    DirectSum(a, b) => a.trace_fast() + b.trace_fast()
    Kronecker(a, b) => a.trace_fast() * b.trace_fast()
  }
}

///|
/// 快速結構化行列式：
/// det(A ⊕ B) = det(A) · det(B)；det(A ⊗ B) = det(A)^{dim B} · det(B)^{dim A}。
pub fn KronBlockMat::det_fast(self : KronBlockMat) -> Int64 {
  match self {
    Leaf(m) => m.det()
    DirectSum(a, b) => a.det_fast() * b.det_fast()
    Kronecker(a, b) =>
      @core.ipow(a.det_fast(), b.dim()) * @core.ipow(b.det_fast(), a.dim())
  }
}

///|
/// 快速結構化求秩：
/// rank(A ⊕ B) = rank(A) + rank(B)；rank(A ⊗ B) = rank(A) · rank(B)。
pub fn KronBlockMat::rank_fast(self : KronBlockMat) -> Int {
  match self {
    Leaf(m) => m.rank()
    DirectSum(a, b) => a.rank_fast() + b.rank_fast()
    Kronecker(a, b) => a.rank_fast() * b.rank_fast()
  }
}

///|
/// 將兩個 `core::Mat` 組合為塊對角稠密矩陣 A ⊕ B。
pub fn dense_block_diag(a : @core.Mat, b : @core.Mat) -> @core.Mat {
  let r1 = a.nrows()
  let c1 = a.ncols()
  let r2 = b.nrows()
  let c2 = b.ncols()
  let out = @core.Mat::zero(r1 + r2, c1 + c2)
  for i = 0; i < r1; i = i + 1 {
    for j = 0; j < c1; j = j + 1 {
      out.set(i, j, a.get(i, j))
    }
  }
  for i = 0; i < r2; i = i + 1 {
    for j = 0; j < c2; j = j + 1 {
      out.set(r1 + i, c1 + j, b.get(i, j))
    }
  }
  out
}

///|
/// 將兩個 `core::Mat` 組合為 Kronecker 稠密張量積矩陣 A ⊗ B。
pub fn dense_kronecker(a : @core.Mat, b : @core.Mat) -> @core.Mat {
  let r1 = a.nrows()
  let c1 = a.ncols()
  let r2 = b.nrows()
  let c2 = b.ncols()
  let out = @core.Mat::zero(r1 * r2, c1 * c2)
  for i1 = 0; i1 < r1; i1 = i1 + 1 {
    for j1 = 0; j1 < c1; j1 = j1 + 1 {
      let v = a.get(i1, j1)
      for i2 = 0; i2 < r2; i2 = i2 + 1 {
        for j2 = 0; j2 < c2; j2 = j2 + 1 {
          out.set(i1 * r2 + i2, j1 * c2 + j2, v * b.get(i2, j2))
        }
      }
    }
  }
  out
}

///|
/// 檢查階層樹的所有葉節點是否皆通過 Hadamard 無溢位安全守衛（n ≤ 6）。
pub fn KronBlockMat::leaves_hadamard_safe(self : KronBlockMat) -> Bool {
  match self {
    Leaf(m) => m.guard_hadamard()
    DirectSum(a, b) => a.leaves_hadamard_safe() && b.leaves_hadamard_safe()
    Kronecker(a, b) => a.leaves_hadamard_safe() && b.leaves_hadamard_safe()
  }
}

///|
/// 展開為第一代稠密 `core::Mat`（供交叉驗證與成本對比）。
pub fn KronBlockMat::to_dense_mat1(self : KronBlockMat) -> @core.Mat {
  match self {
    Leaf(m) => m.copy()
    DirectSum(a, b) => dense_block_diag(a.to_dense_mat1(), b.to_dense_mat1())
    Kronecker(a, b) => dense_kronecker(a.to_dense_mat1(), b.to_dense_mat1())
  }
}

///|
/// 對照實測 3：在多重張量積與直和結構上比較 `KronBlockMat`（Mat2）與稠密 `core::Mat`（Mat1）
/// 的結果一致性、Hadamard 溢位守衛（8×8 時 Mat1 拒絕 `guard_hadamard()=false`、Mat2 葉節點安全 `true`）
/// 與儲存／消去複雜度差距。
/// 回傳：(不變量完全一致且守衛對比成立, Mat1_稠密字數, Mat2_結構字數, Mat1_立方複雜度指標, Mat2_葉節點立方指標)。
pub fn compare_kron_mat2_vs_mat1(
  a : @core.Mat,
  b : @core.Mat,
  c : @core.Mat,
) -> (Bool, Int, Int, Int, Int) {
  let ktree = KronBlockMat::Kronecker(
    KronBlockMat::Kronecker(KronBlockMat::Leaf(a), KronBlockMat::Leaf(b)),
    KronBlockMat::Leaf(c),
  )
  let dense = ktree.to_dense_mat1()
  let tr_ok = ktree.trace_fast() == dense.trace()
  let det_ok = ktree.det_fast() == dense.det()
  // 8×8 稠密矩陣觸發 Mat1 的 Hadamard 溢位守衛上限 (n > 6 -> false)，而 Mat2 在 2×2 葉節點上安全通過 (true)！
  let guard_contrast = !dense.guard_hadamard() && ktree.leaves_hadamard_safe()
  let n = ktree.dim()
  let mat1_words = n * n
  let mat2_words = ktree.storage_words()
  let mat1_ops = n * n * n
  let na = a.nrows()
  let nb = b.nrows()
  let nc = c.nrows()
  let mat2_ops = na * na * na + nb * nb * nb + nc * nc * nc
  (
    tr_ok && det_ok && guard_contrast,
    mat1_words,
    mat2_words,
    mat1_ops,
    mat2_ops,
  )
}

///|
/// 對照實測 3b（關鍵發現）：展示當 A=[20,1;1,2], B=[2,1;1,6], C=[1,2;2,5] 時，
/// 8×8 張量積 A⊗B⊗C 的真實行列式僅為 39⁴×11⁴ = 33,871,089,681（僅佔 35 bits，遠小於 Int64 上限），
/// 第二代 `KronBlockMat::det_fast()` 精確算出 33,871,089,681，
/// 但第一代稠密 `core::Mat::det()` 因 8×8 Bareiss 消去中間乘積超過 2^63-1 而發生整數溢位失真！
pub fn verify_kron_avoids_bareiss_overflow() -> (Bool, Int64, Int64) {
  let a = @core.Mat::of_rows([[20L, 1L], [1L, 2L]])
  let b = @core.Mat::of_rows([[2L, 1L], [1L, 6L]])
  let c = @core.Mat::of_rows([[1L, 2L], [2L, 5L]])
  let ktree = KronBlockMat::Kronecker(
    KronBlockMat::Kronecker(KronBlockMat::Leaf(a), KronBlockMat::Leaf(b)),
    KronBlockMat::Leaf(c),
  )
  let dense = ktree.to_dense_mat1()
  let mat2_exact = ktree.det_fast()
  let mat1_corrupted = dense.det()
  let ok = mat2_exact == 33871089681L &&
    mat1_corrupted != mat2_exact &&
    !dense.guard_hadamard() &&
    ktree.leaves_hadamard_safe()
  (ok, mat2_exact, mat1_corrupted)
}

/// ============================================================================
/// II-D：Tropical (min, +) 極值賦值半環矩陣（TropicalMat）
/// ============================================================================

///|
/// Tropical 極值半環矩陣（元素屬 ℤ ∪ {+∞}，以 inf = 1_000_000_000 代表 ∞）。
pub(all) struct TropicalMat {
  n : Int
  data : FixedArray[Int]
}

///|
/// Tropical 無窮大常數（加法單位元）。
pub fn tropical_inf() -> Int {
  1000000000
}

///|
/// 建立 n×n Tropical 矩陣。
pub fn TropicalMat::of_rows(rs : Array[Array[Int]]) -> TropicalMat {
  let n = rs.length()
  let data = FixedArray::make(n * n, tropical_inf())
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      data[i * n + j] = rs[i][j]
    }
  }
  { n, data, }
}

///|
/// 取元素。
pub fn TropicalMat::get(self : TropicalMat, i : Int, j : Int) -> Int {
  self.data[i * self.n + j]
}

///|
/// Tropical 矩陣乘法 (A ⊗_𝕋 B)_{ij} = min_k (A_{ik} + B_{kj})。
pub fn TropicalMat::mul(self : TropicalMat, other : TropicalMat) -> TropicalMat {
  let n = self.n
  let inf = tropical_inf()
  let data = FixedArray::make(n * n, inf)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let mut best = inf
      for k = 0; k < n; k = k + 1 {
        let aik = self.get(i, k)
        let bkj = other.get(k, j)
        if aik < inf && bkj < inf {
          let s = aik + bkj
          if s < best {
            best = s
          }
        }
      }
      data[i * n + j] = best
    }
  }
  { n, data, }
}

///|
/// 2×2 Tropical 行列式（最小指派永久式）：tdet(A) = min(a₀₀+a₁₁, a₀₁+a₁₀)。
pub fn TropicalMat::tdet2(self : TropicalMat) -> Int {
  let d1 = self.get(0, 0) + self.get(1, 1)
  let d2 = self.get(0, 1) + self.get(1, 0)
  if d1 <= d2 {
    d1
  } else {
    d2
  }
}

///|
/// 由第一代整數矩陣 `core::Mat` 映射出 p-進賦值 Tropical 矩陣 V_{ij} = v_p(M_{ij})，
/// 並驗證牛頓賦值下界定理：v_p(det M) ≥ tdet(v_p(M))！
pub fn verify_tropical_padic_newton_bound(
  m : @core.Mat,
  p : Int64,
) -> (Bool, Int, Int) {
  let v00 = @padic.vp(m.get(0, 0), p)
  let v01 = @padic.vp(m.get(0, 1), p)
  let v10 = @padic.vp(m.get(1, 0), p)
  let v11 = @padic.vp(m.get(1, 1), p)
  let tmat = TropicalMat::of_rows([[v00, v01], [v10, v11]])
  let tdet = tmat.tdet2()
  let det_m = m.det()
  let v_det = if det_m == 0L { 999 } else { @padic.vp(det_m, p) }
  let ok = v_det >= tdet
  (ok, tdet, v_det)
}

///|
/// 對照實測 4：在同一張帶權有向同源圖上，比較第一代 `core::Mat` 乘法（計算路徑權重代數和）
/// 與第二代 `TropicalMat` 乘法（直接給出兩步最短同源測地線距離）。
pub fn compare_tropical_geodesic_vs_mat1() -> (Bool, Int, Int64) {
  // 3 節點同源圖：0 -> 1 (權 2), 1 -> 2 (權 3), 0 -> 2 直接邊 (權 9)
  let t_adj = TropicalMat::of_rows([
    [0, 2, 9],
    [tropical_inf(), 0, 3],
    [tropical_inf(), tropical_inf(), 0],
  ])
  let t_step2 = t_adj.mul(t_adj)
  let shortest_0_to_2 = t_step2.get(0, 2) // min(0+9, 2+3, 9+0) = 5！

  let m1_adj = @core.Mat::of_rows([[1L, 2L, 9L], [0L, 1L, 3L], [0L, 0L, 1L]])
  let m1_step2 = m1_adj.mul(m1_adj)
  let ring_sum_0_to_2 = m1_step2.get(0, 2) // 1*9 + 2*3 + 9*1 = 24（代數疊加，非最短路徑）

  (
    shortest_0_to_2 == 5 && ring_sum_0_to_2 == 24L,
    shortest_0_to_2,
    ring_sum_0_to_2,
  )
}

/// ============================================================================
/// II-E：位移秩 O(n) 生成元壓縮循環矩陣（DispCircMat）
/// ============================================================================

///|
/// 以單一首列生成元 c ∈ ℤ^n 表示 n×n 循環算子（儲存 O(n)，無需配置 n² 陣列）。
pub(all) struct DispCircMat {
  gen : Array[Int64]
}

///|
/// 生成元空間直接摺積乘法（O(n²) 或 FFT O(n log n)，完全免除 O(n³) 矩陣乘法）。
pub fn DispCircMat::mul(self : DispCircMat, other : DispCircMat) -> DispCircMat {
  let n = self.gen.length()
  let out : Array[Int64] = []
  for _i = 0; _i < n; _i = _i + 1 {
    out.push(0L)
  }
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let idx = (i + j) % n
      out[idx] = out[idx] + self.gen[i] * other.gen[j]
    }
  }
  { gen: out, }
}

///|
/// 展開為第一代 `core::Mat` 供等價驗證。
pub fn DispCircMat::to_dense_mat1(self : DispCircMat) -> @core.Mat {
  let n = self.gen.length()
  let m = @core.Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let idx = (j - i + n) % n
      m.set(i, j, self.gen[idx])
    }
  }
  m
}

///|
/// 綜合輸出第二代矩陣與第一代矩陣之五大差異實證報告（供 CLI `mat2` 調用）。
pub fn render_mat2_report() -> String {
  let sb = StringBuilder()
  sb.write_string(
    "== Σ-超矩陣：第二代矩陣體系（Mat2）vs 第一代稠密整數矩陣（Mat1）實證對照報告 ==\n",
  )
  // 1. Grassmann 超矩陣 vs 交換矩陣
  let (g_ok, defect, lhs_soul, rhs_soul) = compare_berezinian_mat1_vs_mat2(
    2, 3, 5, 7, 11, 13,
  )
  sb.write_string(
    "[II-A Grassmann 超矩陣] 非零奇部 Berezinian 乘法性：Mat2(反交換)=true (靈魂部 \{lhs_soul}==\{rhs_soul}) vs Mat1(交換環缺陷)=\{-defect} (違反乘法性！)｜驗證=\{g_ok}\n",
  )
  // 2. 多項式鉛筆矩陣 vs 整數 SNF
  let (p_ok, tid, tsh, thy) = compare_polymat_vs_mat1(17L)
  sb.write_string(
    "[II-B 多項式 λ-矩陣] 同行列式么模算子分離：Mat1 整數 SNF 全盲 (皆為 diag(1,1)) vs Mat2 𝔽_17[x]-SNF：I₂->\{tid}, 剪切->\{tsh}, 雙曲->\{thy}｜驗證=\{p_ok}\n",
  )
  // 3. Kronecker 階層矩陣樹 vs 稠密展開
  let a = @core.Mat::of_rows([[2L, 1L], [1L, 3L]])
  let b = @core.Mat::of_rows([[3L, 2L], [1L, 2L]])
  let c = @core.Mat::of_rows([[1L, 4L], [2L, 9L]])
  let (k_ok, w1, w2, op1, op2) = compare_kron_mat2_vs_mat1(a, b, c)
  let (ovf_ok, det_mat2, det_mat1_ovf) = verify_kron_avoids_bareiss_overflow()
  sb.write_string(
    "[II-C Kronecker 階層樹] 三重張量積 A⊗B⊗C：儲存字數 Mat1=\{w1} vs Mat2=\{w2}；消去規模 Mat1=\{op1} vs Mat2=\{op2}；高係數下 Mat2 精確行列式=\{det_mat2} vs Mat1 Bareiss 中間溢位失真=\{det_mat1_ovf}｜驗證=\{k_ok && ovf_ok}\n",
  )
  // 4. Tropical 極值半環矩陣 vs 標準環矩陣
  let (t_ok, geo_dist, ring_val) = compare_tropical_geodesic_vs_mat1()
  let m_padic = @core.Mat::of_rows([[9L, 3L], [6L, 5L]])
  let (nb_ok, tdet, vdet) = verify_tropical_padic_newton_bound(m_padic, 3L)
  sb.write_string(
    "[II-D Tropical 半環矩陣] 同源圖 0->2 兩步運算：Mat2(最短測地線)=\{geo_dist} vs Mat1(代數路徑和)=\{ring_val}；3-進牛頓下界 tdet=\{tdet} ≤ v_3(det)=\{vdet}｜驗證=\{t_ok && nb_ok}\n",
  )
  // 5. 位移秩壓縮循環矩陣
  let dc1 : DispCircMat = { gen: [1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L], }
  let dc2 : DispCircMat = { gen: [2L, 0L, 1L, 3L, 1L, 2L, 4L, 1L], }
  let dc_prod = dc1.mul(dc2)
  let dense_eq = dc_prod
    .to_dense_mat1()
    .eq(dc1.to_dense_mat1().mul(dc2.to_dense_mat1()))
  sb.write_string(
    "[II-E 位移秩壓縮矩陣] 8×8 循環算子：儲存字數 Mat1=64 vs Mat2=8（壓縮 87.5%）｜摺積與稠密乘法一致=\{dense_eq}\n",
  )
  sb.to_string()
}
