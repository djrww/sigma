///|
/// spec/ops.mbt —— Σ-超矩陣算子層：
/// ① 雙向 FFT（有限域上精確版）② 循環算子雙向對角化 ③ 伴隨映射
/// ④ 辛雙環分次代數與超矩陣（超跡、Berezinian）⑤ 極化恆等式（二次/三次）
/// 全部附義務自證；所有運算為精確整數（模 p）。

///|
/// 矩陣模 p 求逆（Gauss–Jordan）。
pub fn mat_inv_mod(a : @core.Mat, p : Int64) -> @core.Mat? {
  let n = a.rows
  if n != a.cols {
    return None
  }
  let m = a.copy()
  let inv = @core.Mat::ident(n)
  for c = 0; c < n; c = c + 1 {
    let mut pr = -1
    for r = c; r < n; r = r + 1 {
      if @core.zmod(m.get(r, c), p) != 0L {
        pr = r
        break
      }
    }
    if pr < 0 {
      return None
    }
    if pr != c {
      m.swap_rows(pr, c)
      inv.swap_rows(pr, c)
    }
    let piv = @core.invmod(@core.zmod(m.get(c, c), p), p)
    for j = 0; j < n; j = j + 1 {
      m.set(c, j, gmul(m.get(c, j), piv, p))
      inv.set(c, j, gmul(inv.get(c, j), piv, p))
    }
    for r = 0; r < n; r = r + 1 {
      if r != c && @core.zmod(m.get(r, c), p) != 0L {
        let f = @core.zmod(m.get(r, c), p)
        for j = 0; j < n; j = j + 1 {
          m.set(r, j, @core.zmod(m.get(r, j) - gmul(f, m.get(c, j), p), p))
          inv.set(
            r,
            j,
            @core.zmod(inv.get(r, j) - gmul(f, inv.get(c, j), p), p),
          )
        }
      }
    }
  }
  Some(inv)
}

///|
/// 模 p 矩陣加法（逐步約化）。
pub fn mat_add_mod(a : @core.Mat, b : @core.Mat, p : Int64) -> @core.Mat {
  let m = @core.Mat::zero(a.nrows(), a.ncols())
  for i = 0; i < a.nrows(); i = i + 1 {
    for j = 0; j < a.ncols(); j = j + 1 {
      m.set(i, j, gadd(a.get(i, j), b.get(i, j), p))
    }
  }
  m
}

///|
/// 模 p 矩陣乘法（逐步約化，避免 Int64 溢出——這是 n=16 以上案例的關鍵）。
pub fn mat_mul_mod(a : @core.Mat, b : @core.Mat, p : Int64) -> @core.Mat {
  let m = @core.Mat::zero(a.nrows(), b.ncols())
  for i = 0; i < a.nrows(); i = i + 1 {
    for k = 0; k < a.ncols(); k = k + 1 {
      let x = @core.zmod(a.get(i, k), p)
      if x != 0L {
        for j = 0; j < b.ncols(); j = j + 1 {
          m.set(i, j, gadd(m.get(i, j), gmul(x, b.get(k, j), p), p))
        }
      }
    }
  }
  m
}

///|
/// 模 p 純量乘（逐步約化）。
pub fn mat_scale_mod(a : @core.Mat, k : Int64, p : Int64) -> @core.Mat {
  let m = @core.Mat::zero(a.nrows(), a.ncols())
  for i = 0; i < a.nrows(); i = i + 1 {
    for j = 0; j < a.ncols(); j = j + 1 {
      m.set(i, j, gmul(a.get(i, j), k, p))
    }
  }
  m
}

///|
/// 有限域上的 radix-2 FFT（遞迴 Cooley–Tukey），w 為 n 次原根。
pub fn fft(vec : Array[Int64], w : Int64, p : Int64) -> Array[Int64] {
  let n = vec.length()
  if n <= 1 {
    return vec.copy()
  }
  let half = n / 2
  let even : Array[Int64] = []
  let odd : Array[Int64] = []
  for i = 0; i < half; i = i + 1 {
    even.push(@core.zmod(vec[2 * i], p))
    odd.push(@core.zmod(vec[2 * i + 1], p))
  }
  let w2 = gmul(w, w, p)
  let fe = fft(even, w2, p)
  let fo = fft(odd, w2, p)
  let res : Array[Int64] = []
  for _i = 0; _i < n; _i = _i + 1 {
    res.push(0L)
  }
  let mut wk = 1L
  for i = 0; i < half; i = i + 1 {
    let t = gmul(wk, fo[i], p)
    res[i] = gadd(fe[i], t, p)
    res[i + half] = @core.zmod(fe[i] - t, p)
    wk = gmul(wk, w, p)
  }
  res
}

///|
/// 逆 FFT。
pub fn ifft(vec : Array[Int64], w : Int64, p : Int64) -> Array[Int64] {
  let wi = ginv(w, p)
  let f = fft(vec, wi, p)
  let ninv = ginv(vec.length().to_int64(), p)
  let out : Array[Int64] = []
  for x in f {
    out.push(gmul(x, ninv, p))
  }
  out
}

///|
/// 義務自證：FFT 與 IFFT 互逆（雙向變換）。
pub fn verify_fft_roundtrip(vec : Array[Int64], w : Int64, p : Int64) -> Bool {
  let g = ifft(fft(vec, w, p), w, p)
  if g.length() != vec.length() {
    return false
  }
  for i = 0; i < vec.length(); i = i + 1 {
    if g[i] != @core.zmod(vec[i], p) {
      return false
    }
  }
  true
}

///|
/// 樸素卷積（mod p）。
pub fn conv_naive(
  a : Array[Int64],
  b : Array[Int64],
  p : Int64,
) -> Array[Int64] {
  let n = a.length() + b.length() - 1
  let out : Array[Int64] = []
  for _i = 0; _i < n; _i = _i + 1 {
    out.push(0L)
  }
  for i = 0; i < a.length(); i = i + 1 {
    for j = 0; j < b.length(); j = j + 1 {
      out[i + j] = gadd(
        out[i + j],
        gmul(@core.zmod(a[i], p), @core.zmod(b[j], p), p),
        p,
      )
    }
  }
  out
}

///|
/// 下一個 2 的冪。
pub fn next_pow2(n : Int) -> Int {
  let mut m = 1
  while m < n {
    m = m * 2
  }
  m
}

///|
/// FFT 卷積：自動零填充到 2 的冪並取相應階數的原根。
pub fn conv_fft(a : Array[Int64], b : Array[Int64], p : Int64) -> Array[Int64] {
  let need = a.length() + b.length() - 1
  let n = next_pow2(need)
  let w = nth_root(n, p)
  let fa : Array[Int64] = []
  let fb : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    fa.push(if i < a.length() { @core.zmod(a[i], p) } else { 0L })
    fb.push(if i < b.length() { @core.zmod(b[i], p) } else { 0L })
  }
  let f1 = fft(fa, w, p)
  let f2 = fft(fb, w, p)
  let prod : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    prod.push(gmul(f1[i], f2[i], p))
  }
  let back = ifft(prod, w, p)
  let out : Array[Int64] = []
  for i = 0; i < need; i = i + 1 {
    out.push(@core.zmod(back[i], p))
  }
  out
}

///|
/// 義務自證：卷積定理（FFT 版本 == 樸素版本）。
pub fn verify_convolution_theorem(
  a : Array[Int64],
  b : Array[Int64],
  p : Int64,
) -> Bool {
  let x = conv_naive(a, b, p)
  let y = conv_fft(a, b, p)
  if x.length() != y.length() {
    return false
  }
  for i = 0; i < x.length(); i = i + 1 {
    if x[i] != y[i] {
      return false
    }
  }
  true
}

///|
/// 循環矩陣（第 i 列為 first row 右移 i 位）。
pub fn circulant(first : Array[Int64]) -> @core.Mat {
  let n = first.length()
  let m = @core.Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      m.set(i, j, first[@core.zmod((j - i).to_int64(), n.to_int64()).to_int()])
    }
  }
  m
}

///|
/// DFT 矩陣 F_{ij} = w^{ij}。
pub fn dft_matrix(n : Int, w : Int64, p : Int64) -> @core.Mat {
  let m = @core.Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      m.set(i, j, gpow(w, (i * j).to_int64(), p))
    }
  }
  m
}

///|
/// 義務自證：循環算子「雙向」對角化——
/// F C F⁻¹ 與 F⁻¹ C F 皆為對角，且正向對角元等於 FFT(first)。
pub fn verify_circulant_diagonalization(
  first : Array[Int64],
  p : Int64,
) -> Bool {
  let n = first.length()
  let w = nth_root(n, p)
  let c = circulant(first)
  let f = dft_matrix(n, w, p)
  let fi = mat_scale_mod(dft_matrix(n, ginv(w, p), p), ginv(n.to_int64(), p), p)
  let d = mat_mul_mod(mat_mul_mod(f, c, p), fi, p)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if i != j && @core.zmod(d.get(i, j), p) != 0L {
        return false
      }
    }
  }
  // 公約：C_{ij} = c_{(j−i)} ⟹ F·C·F⁻¹ = diag(ĉ(w⁻¹))，F⁻¹·C·F = diag(ĉ(w))
  let e = fft(first, ginv(w, p), p)
  for i = 0; i < n; i = i + 1 {
    if @core.zmod(d.get(i, i), p) != e[i] {
      return false
    }
  }
  let d2 = mat_mul_mod(mat_mul_mod(fi, c, p), f, p)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if i != j && @core.zmod(d2.get(i, j), p) != 0L {
        return false
      }
    }
  }
  let e2 = fft(first, w, p)
  for i = 0; i < n; i = i + 1 {
    if @core.zmod(d2.get(i, i), p) != e2[i] {
      return false
    }
  }
  true
}

///|
/// 伴隨映射（標準雙線性型下的轉置）。
pub fn adjoint(a : @core.Mat) -> @core.Mat {
  a.transpose()
}

///|
/// 義務自證：⟨Ax, y⟩ = ⟨x, Aᵀy⟩（模 p）。
pub fn verify_adjoint(
  a : @core.Mat,
  x : Array[Int64],
  y : Array[Int64],
  p : Int64,
) -> Bool {
  let n = a.rows
  let at = adjoint(a)
  let mut lhs = 0L
  let mut rhs = 0L
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      lhs = gadd(lhs, gmul(gmul(a.get(i, j), x[j], p), y[i], p), p)
      rhs = gadd(rhs, gmul(x[j], gmul(at.get(j, i), y[i], p), p), p)
    }
  }
  lhs == rhs
}

///|
/// 辛形式 J = [[0, I], [-I, 0]]。
pub fn symplectic_j(n : Int) -> @core.Mat {
  let m = @core.Mat::zero(2 * n, 2 * n)
  for i = 0; i < n; i = i + 1 {
    m.set(i, n + i, 1L)
    m.set(n + i, i, -1L)
  }
  m
}

///|
/// 義務自證：S 保守辛形式（Sᵀ J S = J）。
pub fn verify_symplectic(s : @core.Mat, n : Int) -> Bool {
  let j = symplectic_j(n)
  s.transpose().mul(j).mul(s).eq(j)
}

///|
/// 分塊宇稱：even (0) ⟺ 非對角塊 B = C = 0；否則為 odd (1)。
pub fn block_parity(m : @core.Mat, n : Int) -> Int {
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if m.get(i, n + j) != 0L || m.get(n + i, j) != 0L {
        return 1
      }
    }
  }
  0
}

///|
/// 超跡 str[[A,B],[C,D]] = tr(A) − tr(D)。
pub fn supertrace(m : @core.Mat, n : Int) -> Int64 {
  let mut s = 0L
  for i = 0; i < n; i = i + 1 {
    s = s + m.get(i, i) - m.get(n + i, n + i)
  }
  s
}

///|
/// 超交換子 [M,N] = MN − (−1)^{|M||N|} NM。
pub fn supercommutator(m : @core.Mat, o : @core.Mat, n : Int) -> @core.Mat {
  let pm = block_parity(m, n)
  let po = block_parity(o, n)
  let sgn = if pm * po % 2 == 0 { 1L } else { -1L }
  m.mul(o).sub(o.mul(m).scale(sgn))
}

///|
/// 義務自證：超跡在超交換子上消失。
pub fn verify_supertrace_vanishes(
  m : @core.Mat,
  o : @core.Mat,
  n : Int,
) -> Bool {
  supertrace(supercommutator(m, o, n), n) == 0L
}

///|
/// Berezinian（超行列式），偶可逆分塊情形：
/// sdet[[A,B],[C,D]] = det(A − B D⁻¹ C) · det(D)⁻¹（模 p）。
pub fn berezinian(m : @core.Mat, n : Int, p : Int64) -> Int64? {
  let a = @core.Mat::zero(n, n)
  let b = @core.Mat::zero(n, n)
  let c = @core.Mat::zero(n, n)
  let d = @core.Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      a.set(i, j, @core.zmod(m.get(i, j), p))
      b.set(i, j, @core.zmod(m.get(i, n + j), p))
      c.set(i, j, @core.zmod(m.get(n + i, j), p))
      d.set(i, j, @core.zmod(m.get(n + i, n + j), p))
    }
  }
  match mat_inv_mod(d, p) {
    None => None
    Some(di) => {
      let schur = mat_add_mod(
        a,
        mat_scale_mod(mat_mul_mod(mat_mul_mod(b, di, p), c, p), -1L, p),
        p,
      )
      let det_schur = @core.zmod(schur.det(), p)
      let det_d = @core.zmod(d.det(), p)
      Some(gmul(det_schur, ginv(det_d, p), p))
    }
  }
}

///|
/// 義務自證：Berezinian 的乘法性 sdet(MN) = sdet(M)·sdet(N)。
/// 註：在交換環上，乘法性對「偶部可逆」的塊對角/塊三角超矩陣成立；
/// 一般具非零奇部 B、C 的情形需在分次（反交換）設定下才有乘法性——
/// 本專案因此只用塊三角與塊對角樣本作為機器見證（誠實標註）。
pub fn verify_berezinian_multiplicative(
  m : @core.Mat,
  o : @core.Mat,
  n : Int,
  p : Int64,
) -> Bool {
  let mn = m.mul(o)
  match (berezinian(m, n, p), berezinian(o, n, p), berezinian(mn, n, p)) {
    (Some(x), Some(y), Some(z)) => z == gmul(x, y, p)
    _ => false
  }
}

///|
/// 二次型 Q(x) = xᵀA x（模 p）。
pub fn quadratic_eval(a : @core.Mat, v : Array[Int64], p : Int64) -> Int64 {
  let n = a.rows
  let mut s = 0L
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      s = gadd(s, gmul(gmul(v[i], a.get(i, j), p), v[j], p), p)
    }
  }
  s
}

///|
/// 極化（二次）：B(x,y) = Q(x+y) − Q(x) − Q(y)。
pub fn polarize_quadratic(
  a : @core.Mat,
  x : Array[Int64],
  y : Array[Int64],
  p : Int64,
) -> Int64 {
  let xy : Array[Int64] = []
  for i = 0; i < x.length(); i = i + 1 {
    xy.push(gadd(x[i], y[i], p))
  }
  @core.zmod(
    quadratic_eval(a, xy, p) - quadratic_eval(a, x, p) - quadratic_eval(a, y, p),
    p,
  )
}

///|
/// 義務自證：2·B(x,y) = Q(x+y) − Q(x) − Q(y)（A 對稱、p 奇）。
pub fn verify_polarization_identity(
  a : @core.Mat,
  x : Array[Int64],
  y : Array[Int64],
  p : Int64,
) -> Bool {
  // B(x,y) = Σ_{ij} a_ij x_i y_j；恆等式：2B(x,y) = Q(x+y) − Q(x) − Q(y)
  let n = a.nrows()
  let mut b = 0L
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      b = gadd(b, gmul(gmul(a.get(i, j), x[i], p), y[j], p), p)
    }
  }
  @core.zmod(2L * b, p) == polarize_quadratic(a, x, y, p)
}

///|
/// 三次型（兩變數）P(x,y) = c0 x³ + c1 x²y + c2 xy² + c3 y³。
pub fn cubic_eval(c : Array[Int64], x : Int64, y : Int64) -> Int64 {
  c[0] * x * x * x + c[1] * x * x * y + c[2] * x * y * y + c[3] * y * y * y
}

///|
/// 三次型的多線性極化展開（整數版，等價於 3! · P̃；係數 (6,2,2,6) 由容斥恆等式反推）：
/// 3!·P̃(u,v,w) = c0 x₁x₂x₃ + c1·Σ x_i x_j y_k + c2·Σ x_i y_j y_k + c3 y₁y₂y₃
/// （對 {1,2,3} 的全部置換取和，體現「組合後衍生」的對稱化）。
pub fn polar3_expansion(
  c : Array[Int64],
  u : Array[Int64],
  v : Array[Int64],
  w : Array[Int64],
) -> Int64 {
  let s = u + v + w
  // 便利索引：s[0..2] = x1,x2,x3；s[3..5] = y1,y2,y3
  let x1 = s[0]
  let y1 = s[1]
  let x2 = s[2]
  let y2 = s[3]
  let x3 = s[4]
  let y3 = s[5]
  let term0 = 6L * c[0] * x1 * x2 * x3
  let term1 = 2L * c[1] * (x1 * x2 * y3 + x1 * y2 * x3 + y1 * x2 * x3)
  let term2 = 2L * c[2] * (x1 * y2 * y3 + y1 * x2 * y3 + y1 * y2 * x3)
  let term3 = 6L * c[3] * y1 * y2 * y3
  term0 + term1 + term2 + term3
}

///|
/// 義務自證：極化恆等式（容斥版）——
/// Σ_{S ⊆ {u,v,w}} (−1)^{3−|S|} P(Σ_{i∈S} i) = 3!·P̃(u,v,w)。
pub fn verify_polarization_cubic(
  c : Array[Int64],
  u : Array[Int64],
  v : Array[Int64],
  w : Array[Int64],
) -> Bool {
  // 容斥和
  let mut sum = 0L
  // 8 個子集的指標
  for mask = 0; mask < 8; mask = mask + 1 {
    let mut px = 0L
    let mut py = 0L
    let mut size = 0
    if mask % 2 == 1 {
      px = px + u[0]
      py = py + u[1]
      size = size + 1
    }
    if mask / 2 % 2 == 1 {
      px = px + v[0]
      py = py + v[1]
      size = size + 1
    }
    if mask / 4 % 2 == 1 {
      px = px + w[0]
      py = py + w[1]
      size = size + 1
    }
    let val = cubic_eval(c, px, py)
    let sign = if (3 - size) % 2 == 0 { 1L } else { -1L }
    sum = sum + sign * val
  }
  sum == polar3_expansion(c, u, v, w)
}

///|
/// 極化後的「對角限制」：P̃(v,v,v) 應等於 3!·P(v)/... 直接檢驗
/// （本函式檢查 P̃ 的對角值與 P 的一致性：P̃(v,v,v) = 6·P(v)? 不——
/// 對對稱多線性形式，P̃(v,v,v) = P(v)；此處 3!·P̃ 的對角值為 6P(v)）。
pub fn verify_polar_diagonal(c : Array[Int64], v : Array[Int64]) -> Bool {
  let pv = cubic_eval(c, v[0], v[1])
  let diag = polar3_expansion(c, v, v, v)
  diag == 6L * pv
}
