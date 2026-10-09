///|
/// core/snf.mbt —— Smith 標準形（含么模變換 U、V）、Hermite 標準形、
/// 核基、整數線性方程求解，以及全部的「義務自證」驗證器。
///
/// 核心恆等式：U A V = D，U、V 么模，D = diag(d_1,...,d_r,0,...,0)，
/// 且 d_1 | d_2 | ... | d_r（d_i > 0）。這是有限生成 Z-模結構定理的演算法化身。

///|
/// SNF 全資訊：回傳 (U, D, V)。
pub fn snf_full(a : Mat) -> (Mat, Mat, Mat) {
  let rows = a.rows
  let cols = a.cols
  let m = a.copy()
  let u = Mat::ident(rows)
  let v = Mat::ident(cols)
  let mut i = 0
  while i < rows && i < cols {
    // 1. 取非零樞軸
    let mut pi = -1
    let mut pj = -1
    let mut r = i
    while r < rows && pi < 0 {
      let mut c = i
      while c < cols {
        if m.get(r, c) != 0L {
          pi = r
          pj = c
          break
        }
        c = c + 1
      }
      r = r + 1
    }
    if pi < 0 {
      break
    }
    if pi != i {
      m.swap_rows(pi, i)
      u.swap_rows(pi, i)
    }
    if pj != i {
      m.swap_cols(pj, i)
      v.swap_cols(pj, i)
    }
    // 2. 反覆消去第 i 列與第 i 行，直到只剩樞軸
    let mut steps = 0
    let mut clean = false
    while !clean && steps < 100000 {
      steps = steps + 1
      clean = true
      for j = i + 1; j < cols; j = j + 1 {
        if m.get(i, j) != 0L {
          let (g, s, t) = egcd(m.get(i, i), m.get(i, j))
          let a1 = m.get(i, i) / g
          let b1 = m.get(i, j) / g
          m.combine_cols(i, j, s, t, -b1, a1)
          v.combine_cols(i, j, s, t, -b1, a1)
          clean = false
        }
      }
      for k = i + 1; k < rows; k = k + 1 {
        if m.get(k, i) != 0L {
          let (g, s, t) = egcd(m.get(i, i), m.get(k, i))
          let a1 = m.get(i, i) / g
          let b1 = m.get(k, i) / g
          m.combine_rows(i, k, s, t, -b1, a1)
          u.combine_rows(i, k, s, t, -b1, a1)
          clean = false
        }
      }
    }
    // 3. 樞軸取正
    if m.get(i, i) < 0L {
      m.neg_row(i)
      u.neg_row(i)
    }
    // 4. 整除性修正：若 d_i 不整除某個 m[p][q]，把該行加到第 i 行後重做
    let mut fixed = true
    let mut fq = -1
    for p = i + 1; p < rows; p = p + 1 {
      for q = i + 1; q < cols; q = q + 1 {
        if !divides(m.get(i, i), m.get(p, q)) {
          fixed = false
          fq = q
        }
      }
    }
    if !fixed {
      m.add_col(i, fq, 1L)
      v.add_col(i, fq, 1L)
      continue
    }
    i = i + 1
  }
  (u, m, v)
}

///|
/// 只取 Smith 對角形 D。
pub fn snf_diag(a : Mat) -> Mat {
  let (_u, d, _v) = snf_full(a)
  d
}

///|
/// 不變因子（D 的對角線，正數，含 1）。
pub fn invariant_factors(a : Mat) -> Array[Int64] {
  let d = snf_diag(a)
  let n = if d.rows < d.cols { d.rows } else { d.cols }
  let out : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    out.push(d.get(i, i))
  }
  out
}

///|
/// 撓不變量（去掉 1 之後的 >1 因子），即 Z^n/A 的撓部分。
pub fn torsion_invariants(a : Mat) -> Array[Int64] {
  let out : Array[Int64] = []
  for d in invariant_factors(a) {
    if d > 1L {
      out.push(d)
    }
  }
  out
}

///|
/// 試除法質因數分解（數值域定理保證輸入 < 2^31 時足夠）。
pub fn factorize(n : Int64) -> Array[(Int64, Int)] {
  let out : Array[(Int64, Int)] = []
  let mut x = iabs(n)
  if x <= 1L {
    return out
  }
  let mut p = 2L
  while p * p <= x {
    if x % p == 0L {
      let mut e = 0
      while x % p == 0L {
        x = x / p
        e = e + 1
      }
      out.push((p, e))
    }
    p = p + 1L
  }
  if x > 1L {
    out.push((x, 1))
  }
  out
}

///|
/// 初等除子：把每個不變因子分解為質數冪，輸出有序清單。
pub fn elementary_divisors(a : Mat) -> Array[(Int64, Int)] {
  let out : Array[(Int64, Int)] = []
  for d in invariant_factors(a) {
    for (p, e) in factorize(d) {
      out.push((p, e))
    }
  }
  out
}

///|
/// Hermite 標準形（列式）：回傳 (H, U)，U 么模，H = U A 為列階梯形且
/// 樞軸為正、樞軸上方元素已對樞軸取模歸約。
pub fn hnf_full(a : Mat) -> (Mat, Mat) {
  let rows = a.rows
  let cols = a.cols
  let m = a.copy()
  let u = Mat::ident(rows)
  let mut r = 0
  for c = 0; c < cols; c = c + 1 {
    if r >= rows {
      break
    }
    let mut pr = -1
    for i = r; i < rows; i = i + 1 {
      if m.get(i, c) != 0L {
        pr = i
        break
      }
    }
    if pr < 0 {
      continue
    }
    if pr != r {
      m.swap_rows(pr, r)
      u.swap_rows(pr, r)
    }
    for i = r + 1; i < rows; i = i + 1 {
      let mut steps = 0
      while m.get(i, c) != 0L && steps < 1000 {
        steps = steps + 1
        let (g, s, t) = egcd(m.get(r, c), m.get(i, c))
        let a1 = m.get(r, c) / g
        let b1 = m.get(i, c) / g
        m.combine_rows(r, i, s, t, -b1, a1)
        u.combine_rows(r, i, s, t, -b1, a1)
        if m.get(r, c) < 0L {
          m.neg_row(r)
          u.neg_row(r)
        }
      }
    }
    if m.get(r, c) < 0L {
      m.neg_row(r)
      u.neg_row(r)
    }
    for i = 0; i < r; i = i + 1 {
      let q = zdiv(m.get(i, c), m.get(r, c))
      if q != 0L {
        m.add_row(i, r, -q)
        u.add_row(i, r, -q)
      }
    }
    r = r + 1
  }
  (m, u)
}

///|
/// HNF（只取標準形矩陣）。
pub fn hnf(a : Mat) -> Mat {
  let (h, _u) = hnf_full(a)
  h
}

///|
/// 核基（Z-模意義）：ker(A) = <V 的第 j 行，j >= rank>。
/// 依據：A V = U^{-1} D，若 D 的第 j 個對角元為 0，則 V e_j 被 A 殺掉。
pub fn kernel_basis(a : Mat) -> Array[Array[Int64]] {
  let (_u, d, v) = snf_full(a)
  let rows = d.rows
  let cols = d.cols
  let mut rank = 0
  let nn = if rows < cols { rows } else { cols }
  for i = 0; i < nn; i = i + 1 {
    if d.get(i, i) != 0L {
      rank = rank + 1
    }
  }
  let out : Array[Array[Int64]] = []
  for j = rank; j < cols; j = j + 1 {
    out.push(v.col(j))
  }
  out
}

///|
/// 像（行空間）的格基：{ d_i * (U^{-1}) 的第 i 行 }，i < rank。
pub fn image_basis(a : Mat) -> Array[Array[Int64]] {
  let (u, d, _v) = snf_full(a)
  let rows = d.rows
  let cols = d.cols
  let nn = if rows < cols { rows } else { cols }
  let out : Array[Array[Int64]] = []
  match u.inverse_unimodular() {
    None => out
    Some(uinv) => {
      for i = 0; i < nn; i = i + 1 {
        if d.get(i, i) != 0L {
          let r = uinv.row(i)
          let rr : Array[Int64] = []
          for x in r {
            rr.push(d.get(i, i) * x)
          }
          out.push(rr)
        }
      }
      out
    }
  }
}

///|
/// 整數線性方程 A x = b：可解時回傳一組特解（x 為行向量），否則 None。
pub fn solve_integer(a : Mat, b : Mat) -> Array[Int64]? {
  let (u, d, v) = snf_full(a)
  let bp = u.mul(b)
  let rows = d.rows
  let cols = d.cols
  let nn = if rows < cols { rows } else { cols }
  let y = FixedArray::make(cols, 0L)
  for i = 0; i < cols; i = i + 1 {
    if i < nn && d.get(i, i) != 0L {
      let bi = bp.get(i, 0)
      if bi % d.get(i, i) != 0L {
        return None
      }
      y[i] = bi / d.get(i, i)
    } else {
      if bp.get(i, 0) != 0L {
        return None
      }
      y[i] = 0L
    }
  }
  let out : Array[Int64] = []
  for i = 0; i < cols; i = i + 1 {
    out.push(y[i])
  }
  // x = V y
  let x : Array[Int64] = []
  for i = 0; i < cols; i = i + 1 {
    let mut s = 0L
    for j = 0; j < cols; j = j + 1 {
      s = s + v.get(i, j) * out[j]
    }
    x.push(s)
  }
  Some(x)
}

///|
/// 義務自證 1：U A V = D 且 U、V 么模。
pub fn verify_snf(a : Mat, u : Mat, d : Mat, v : Mat) -> Bool {
  u.is_unimodular() && v.is_unimodular() && u.mul(a).mul(v).eq(d)
}

///|
/// 義務自證 2：D 確為 Smith 形（對角、非負、整除鏈、零在尾）。
pub fn verify_smith_shape(d : Mat) -> Bool {
  if !d.is_diagonal() {
    return false
  }
  let n = if d.rows < d.cols { d.rows } else { d.cols }
  let mut seen_zero = false
  for i = 0; i < n; i = i + 1 {
    let x = d.get(i, i)
    if x < 0L {
      return false
    }
    if x == 0L {
      seen_zero = true
    } else {
      if seen_zero {
        return false
      }
      if i > 0 && !divides(d.get(i - 1, i - 1), x) {
        return false
      }
    }
  }
  true
}

///|
/// 完整 SNF 義務：形狀 + 變換 + 秩不變。
pub fn verify_snf_full(a : Mat, u : Mat, d : Mat, v : Mat) -> Bool {
  verify_snf(a, u, d, v) && verify_smith_shape(d) && d.rank() == a.rank()
}

///|
/// 義務自證 3：HNF 證書 H = U A、U 么模、H 為列階梯形、樞軸為正且上方已歸約。
pub fn verify_hnf(a : Mat, h : Mat, u : Mat) -> Bool {
  if !u.is_unimodular() {
    return false
  }
  if !u.mul(a).eq(h) {
    return false
  }
  // 逐列檢查：找到該列首個非零（樞軸），其左側必須為 0，樞軸 > 0
  let mut prev_pivot = -1
  for i = 0; i < h.rows; i = i + 1 {
    let mut pj = -1
    for j = 0; j < h.cols; j = j + 1 {
      if h.get(i, j) != 0L {
        pj = j
        break
      }
    }
    if pj < 0 {
      continue
    }
    if pj <= prev_pivot {
      return false
    }
    prev_pivot = pj
    if h.get(i, pj) <= 0L {
      return false
    }
    for k = 0; k < i; k = k + 1 {
      let v = zmod(h.get(k, pj), h.get(i, pj))
      if h.get(k, pj) != v {
        return false
      }
    }
  }
  true
}

///|
/// 義務自證 4：核基真的在核裡，且由 SNF 給出的自由度相符。
pub fn verify_kernel(a : Mat, basis : Array[Array[Int64]]) -> Bool {
  let cols = a.cols
  for v in basis {
    if v.length() != cols {
      return false
    }
    for i = 0; i < a.rows; i = i + 1 {
      let mut s = 0L
      for j = 0; j < cols; j = j + 1 {
        s = s + a.get(i, j) * v[j]
      }
      if s != 0L {
        return false
      }
    }
  }
  // 自由秩核驗：dim ker = cols - rank
  a.rank() + basis.length() == cols
}

///|
/// 義務自證 5：特解確實滿足 A x = b。
pub fn verify_solution(a : Mat, b : Mat, x : Array[Int64]) -> Bool {
  if x.length() != a.cols {
    return false
  }
  for i = 0; i < a.rows; i = i + 1 {
    let mut s = 0L
    for j = 0; j < a.cols; j = j + 1 {
      s = s + a.get(i, j) * x[j]
    }
    if s != b.get(i, 0) {
      return false
    }
  }
  true
}
