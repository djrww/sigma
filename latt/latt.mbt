///|
/// latt/latt.mbt —— 格論：Gram 矩陣、協體積、精確 LLL（有理數算術）、
/// 對偶格、SVP/CVP 窮舉、密度報告，以及全部的自證義務。
///
/// 一切幾何量以精確整數/有理數表示：
///   covol(L)² = det(Gram)   ·   ⟨b_i, b*_j⟩ = δ_ij   ·   b' = U b, U 么模

///|
/// 格的基：以列向量給出的矩陣（每列一個基向量）。
pub type Basis = @core.Mat

///|
/// Gram 矩陣 G = B Bᵀ。
pub fn gram(b : Basis) -> @core.Mat {
  b.mul(b.transpose())
}

///|
/// 協體積平方（精確整數）。
pub fn covolume_sq(b : Basis) -> Int64 {
  gram(b).det()
}

///|
/// 是否滿秩。
pub fn is_full_rank(b : Basis) -> Bool {
  b.rows == b.cols && b.det() != 0L
}

///|
/// 有理數行向量。
pub type QVec = Array[@core.Frac]

///|
/// 整數列轉有理列。
fn qvec_of_ints(a : Array[Int64]) -> QVec {
  let out : QVec = []
  for x in a {
    out.push(@core.Frac::int(x))
  }
  out
}

///|
/// 內積（有理）。
fn qdot(x : QVec, y : QVec) -> @core.Frac {
  let mut s = @core.Frac::zero()
  for i = 0; i < x.length(); i = i + 1 {
    s = @core.Frac::add(s, @core.Frac::mul(x[i], y[i]))
  }
  s
}

///|
/// dst += c · src（有理）。
fn qscale_add(dst : QVec, src : QVec, c : @core.Frac) -> Unit {
  for i = 0; i < dst.length(); i = i + 1 {
    dst[i] = @core.Frac::add(dst[i], @core.Frac::mul(c, src[i]))
  }
}

///|
/// Gram–Schmidt：回傳 (b*, μ)。
pub fn gram_schmidt(b : Basis) -> (Array[QVec], Array[Array[@core.Frac]]) {
  let n = b.rows
  let bstar : Array[QVec] = []
  let mu : Array[Array[@core.Frac]] = []
  for i = 0; i < n; i = i + 1 {
    let v = qvec_of_ints(b.row(i))
    let row_mu : Array[@core.Frac] = []
    for j = 0; j < i; j = j + 1 {
      let m = @core.Frac::div(
        qdot(qvec_of_ints(b.row(i)), bstar[j]),
        qdot(bstar[j], bstar[j]),
      )
      row_mu.push(m)
      qscale_add(v, bstar[j], @core.Frac::neg(m))
    }
    bstar.push(v)
    mu.push(row_mu)
  }
  (bstar, mu)
}

///|
/// 尺寸約化判定：所有 |μ_ij| ≤ 1/2。
pub fn is_size_reduced(b : Basis) -> Bool {
  let (_bs, mu) = gram_schmidt(b)
  for i = 0; i < mu.length(); i = i + 1 {
    for j = 0; j < mu[i].length(); j = j + 1 {
      if !@core.Frac::le(@core.Frac::abs(mu[i][j]), @core.Frac::of(1L, 2L)) {
        return false
      }
    }
  }
  true
}

///|
/// LLL 約化判定（δ = 3/4）。
pub fn is_lll_reduced(b : Basis) -> Bool {
  if !is_size_reduced(b) {
    return false
  }
  let (bs, mu) = gram_schmidt(b)
  let delta = @core.Frac::of(3L, 4L)
  for i = 1; i < b.rows; i = i + 1 {
    let mu2 = @core.Frac::mul(mu[i][i - 1], mu[i][i - 1])
    let lhs = @core.Frac::mul(
      @core.Frac::sub(delta, mu2),
      qdot(bs[i - 1], bs[i - 1]),
    )
    let rhs = qdot(bs[i], bs[i])
    if @core.Frac::lt(rhs, lhs) {
      return false
    }
  }
  true
}

///|
/// 精確 LLL 約化（δ = 3/4）。回傳 (b', U)，b' = U b，U 么模 ⟹ 同格。
pub fn lll_reduce(b : Basis) -> (Basis, @core.Mat) {
  let n = b.rows
  let out = b.copy()
  let u = @core.Mat::ident(n)
  let mut k = 1
  let mut steps = 0
  while k < n && steps < 200000 {
    steps = steps + 1
    let (_bs, mu) = gram_schmidt(out)
    let mut j = k - 1
    while j >= 0 {
      let q = @core.Frac::round(mu[k][j])
      if q != 0L {
        out.add_row(k, j, -q)
        u.add_row(k, j, -q)
      }
      j = j - 1
    }
    let (bs2, mu2) = gram_schmidt(out)
    let delta = @core.Frac::of(3L, 4L)
    let mu2k = @core.Frac::mul(mu2[k][k - 1], mu2[k][k - 1])
    let lhs = @core.Frac::mul(
      @core.Frac::sub(delta, mu2k),
      qdot(bs2[k - 1], bs2[k - 1]),
    )
    let rhs = qdot(bs2[k], bs2[k])
    if @core.Frac::lt(rhs, lhs) {
      out.swap_rows(k, k - 1)
      u.swap_rows(k, k - 1)
      k = if k > 1 { k - 1 } else { 1 }
    } else {
      k = k + 1
    }
  }
  (out, u)
}

///|
/// 義務自證：LLL 憑證（U 么模、b' = U b、b' 已約化、協體積不變）。
pub fn verify_lll(b : Basis, bp : Basis, u : @core.Mat) -> Bool {
  u.is_unimodular() &&
  u.mul(b).eq(bp) &&
  is_lll_reduced(bp) &&
  covolume_sq(b) == covolume_sq(bp)
}

///|
/// 向量歐氏範數平方。
pub fn norm_sq(v : Array[Int64]) -> Int64 {
  let mut s = 0L
  for x in v {
    s = s + x * x
  }
  s
}

///|
/// 係數盒遍歷器（-k..k 的混合基計數）。
fn box_iterate(n : Int, k : Int, body : (Array[Int64]) -> Unit) -> Unit {
  let idx = FixedArray::make(n, (-k).to_int64())
  let total = @core.ipow((2 * k + 1).to_int64(), n).to_int()
  for _c = 0; _c < total; _c = _c + 1 {
    let c : Array[Int64] = []
    for i = 0; i < n; i = i + 1 {
      c.push(idx[i])
    }
    body(c)
    let mut t = 0
    while t < n {
      if idx[t] < k.to_int64() {
        idx[t] = idx[t] + 1L
        break
      }
      idx[t] = (-k).to_int64()
      t = t + 1
    }
  }
}

///|
/// 由係數產生格點。
fn lattice_point(b : Basis, c : Array[Int64]) -> Array[Int64] {
  let v : Array[Int64] = []
  for j = 0; j < b.cols; j = j + 1 {
    let mut s = 0L
    for i = 0; i < b.rows; i = i + 1 {
      s = s + c[i] * b.get(i, j)
    }
    v.push(s)
  }
  v
}

///|
/// SVP（係數盒內窮舉）：回傳 (係數, 最短非零向量, 範數平方)。
pub fn svp_box(b : Basis, k : Int) -> (Array[Int64], Array[Int64], Int64) {
  let mut best_c : Array[Int64] = []
  let mut best_v : Array[Int64] = []
  let mut best = 0L
  box_iterate(b.rows, k, c => {
    let mut is_zero = true
    for x in c {
      if x != 0L {
        is_zero = false
      }
    }
    if !is_zero {
      let v = lattice_point(b, c)
      let ns = norm_sq(v)
      if best == 0L || ns < best {
        best = ns
        best_c = c
        best_v = v
      }
    }
  })
  (best_c, best_v, best)
}

///|
/// CVP（係數盒內窮舉）：回傳 (係數, 最近格點, 距離平方)。
pub fn cvp_box(
  b : Basis,
  target : Array[Int64],
  k : Int,
) -> (Array[Int64], Array[Int64], Int64) {
  let mut best_c : Array[Int64] = []
  let mut best_v : Array[Int64] = []
  let mut best = 0L
  box_iterate(b.rows, k, c => {
    let v = lattice_point(b, c)
    let diff : Array[Int64] = []
    for j = 0; j < v.length(); j = j + 1 {
      diff.push(v[j] - target[j])
    }
    let ns = norm_sq(diff)
    if best == 0L || ns < best {
      best = ns
      best_c = c
      best_v = v
    }
  })
  (best_c, best_v, best)
}

///|
/// 對偶格基（有理）：b*_j = Σ_k (G^{-1})_{jk} b_k，其中 G = Gram。
pub fn dual_basis(b : Basis) -> Array[QVec] {
  let n = b.rows
  let g = gram(b)
  let gi : Array[QVec] = []
  for i = 0; i < n; i = i + 1 {
    let row : QVec = []
    for j = 0; j < n; j = j + 1 {
      row.push(@core.Frac::int(g.get(i, j)))
    }
    gi.push(row)
  }
  let inv : Array[QVec] = []
  for i = 0; i < n; i = i + 1 {
    let row : QVec = []
    for j = 0; j < n; j = j + 1 {
      row.push(@core.Frac::int(if i == j { 1L } else { 0L }))
    }
    inv.push(row)
  }
  for c = 0; c < n; c = c + 1 {
    let mut pr = -1
    for r = c; r < n; r = r + 1 {
      if @core.Frac::sign(gi[r][c]) != 0 {
        pr = r
        break
      }
    }
    if pr < 0 {
      continue
    }
    if pr != c {
      let t1 = gi[pr]
      gi[pr] = gi[c]
      gi[c] = t1
      let t2 = inv[pr]
      inv[pr] = inv[c]
      inv[c] = t2
    }
    let piv = gi[c][c]
    for j = 0; j < n; j = j + 1 {
      gi[c][j] = @core.Frac::div(gi[c][j], piv)
      inv[c][j] = @core.Frac::div(inv[c][j], piv)
    }
    for r = 0; r < n; r = r + 1 {
      if r != c && @core.Frac::sign(gi[r][c]) != 0 {
        let f = gi[r][c]
        for j = 0; j < n; j = j + 1 {
          gi[r][j] = @core.Frac::sub(gi[r][j], @core.Frac::mul(f, gi[c][j]))
          inv[r][j] = @core.Frac::sub(inv[r][j], @core.Frac::mul(f, inv[c][j]))
        }
      }
    }
  }
  let out : Array[QVec] = []
  for i = 0; i < n; i = i + 1 {
    let row : QVec = []
    for j = 0; j < b.cols; j = j + 1 {
      let mut s = @core.Frac::zero()
      for k = 0; k < n; k = k + 1 {
        s = @core.Frac::add(
          s,
          @core.Frac::mul(inv[i][k], @core.Frac::int(b.get(k, j))),
        )
      }
      row.push(s)
    }
    out.push(row)
  }
  out
}

///|
/// 義務自證：⟨b_i, b*_j⟩ = δ_ij。
pub fn verify_dual(b : Basis, dual : Array[QVec]) -> Bool {
  let n = b.rows
  if dual.length() != n {
    return false
  }
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let mut s = @core.Frac::zero()
      for k = 0; k < b.cols; k = k + 1 {
        s = @core.Frac::add(
          s,
          @core.Frac::mul(@core.Frac::int(b.get(i, k)), dual[j][k]),
        )
      }
      let want = @core.Frac::int(if i == j { 1L } else { 0L })
      if !@core.Frac::eq(s, want) {
        return false
      }
    }
  }
  true
}

///|
/// 有理矩陣行列式（高斯消去，精確）。
pub fn det_q(m : Array[QVec]) -> @core.Frac {
  let n = m.length()
  let a : Array[QVec] = []
  for r in m {
    let row : QVec = []
    for x in r {
      row.push(x)
    }
    a.push(row)
  }
  let mut det = @core.Frac::int(1L)
  for c = 0; c < n; c = c + 1 {
    let mut pr = -1
    for r = c; r < n; r = r + 1 {
      if @core.Frac::sign(a[r][c]) != 0 {
        pr = r
        break
      }
    }
    if pr < 0 {
      return @core.Frac::zero()
    }
    if pr != c {
      let t = a[pr]
      a[pr] = a[c]
      a[c] = t
      det = @core.Frac::neg(det)
    }
    det = @core.Frac::mul(det, a[c][c])
    let piv = a[c][c]
    for r = c + 1; r < n; r = r + 1 {
      if @core.Frac::sign(a[r][c]) != 0 {
        let f = @core.Frac::div(a[r][c], piv)
        for j = c; j < n; j = j + 1 {
          a[r][j] = @core.Frac::sub(a[r][j], @core.Frac::mul(f, a[c][j]))
        }
      }
    }
  }
  det
}

///|
/// 義務自證：滿秩格 det(L)·det(L*) = 1（有理數精確比較）。
pub fn verify_duality_det(b : Basis) -> Bool {
  if !is_full_rank(b) {
    return false
  }
  let dual = dual_basis(b)
  let n = b.rows
  let gstar : Array[QVec] = []
  for i = 0; i < n; i = i + 1 {
    let row : QVec = []
    for j = 0; j < n; j = j + 1 {
      row.push(qdot(dual[i], dual[j]))
    }
    gstar.push(row)
  }
  let dl = @core.Frac::int(b.det())
  let lhs = @core.Frac::mul(det_q(gstar), @core.Frac::mul(dl, dl))
  @core.Frac::eq(lhs, @core.Frac::int(1L))
}

///|
/// Hermite 標準形基（與原基同格，且為該格的典範基）。
pub fn hnf_basis(b : Basis) -> (@core.Mat, @core.Mat) {
  @core.hnf_full(b)
}

///|
/// 格的密度報告（Double，僅供呈現）：
/// δ = (λ_1/2)^n · ω_n / covol(L)，ω_n 為單位球體積。
pub fn density_report(b : Basis, lambda1_sq : Int64) -> Double {
  let n = b.rows
  let cov = covolume_sq(b).to_double().sqrt()
  let half_l1 = lambda1_sq.to_double().sqrt() / 2.0
  let mut power = 1.0
  for _k = 0; _k < n; _k = _k + 1 {
    power = power * half_l1
  }
  let mut omega = 1.0
  if n % 2 == 0 {
    for k = 1; k <= n / 2; k = k + 1 {
      omega = omega * 3.141592653589793 / k.to_double()
    }
  } else {
    for k = 1; k <= (n - 1) / 2; k = k + 1 {
      omega = omega * 2.0 * 3.141592653589793 / (2.0 * k.to_double() + 1.0)
    }
    omega = omega * 2.0
  }
  power / cov * omega
}

///|
/// 首向量長度平方與 LLL 界的比較（精確整數）：
/// LLL 保證 ‖b_1‖² ≤ 2^{n-1} λ_1²。此處檢查 ‖b_1‖² ≤ 2^{n-1} · (盒內最短)²。
pub fn verify_lll_bound(bp : Basis, box_min_sq : Int64) -> Bool {
  let n = bp.rows
  let factor = @core.ipow(2L, n - 1)
  norm_sq(bp.row(0)) <= factor * box_min_sq
}
