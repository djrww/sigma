///|
/// core/det.mbt —— 行列式、秩、子式、么模逆。
/// 採用 Bareiss 分數自由消去法：全程整數、不引入有理數、商恆為精確。

///|
/// 分數自由（Bareiss）行列式。要求方陣；奇異時回傳 0。
pub fn Mat::det(self : Mat) -> Int64 {
  let n = self.rows
  if n != self.cols {
    abort("det: not square")
  }
  if n == 0 {
    return 1L
  }
  let m = self.copy()
  let mut sign = 1L
  let mut prev = 1L
  for k = 0; k < n - 1; k = k + 1 {
    if m.get(k, k) == 0L {
      let mut sw = -1
      for i = k + 1; i < n; i = i + 1 {
        if sw < 0 && m.get(i, k) != 0L {
          sw = i
        }
      }
      if sw < 0 {
        return 0L
      }
      m.swap_rows(k, sw)
      sign = -sign
    }
    for i = k + 1; i < n; i = i + 1 {
      for j = k + 1; j < n; j = j + 1 {
        m.set(
          i,
          j,
          (m.get(i, j) * m.get(k, k) - m.get(i, k) * m.get(k, j)) / prev,
        )
      }
    }
    prev = m.get(k, k)
  }
  sign * m.get(n - 1, n - 1)
}

///|
/// 秩（以分數自由消去計樞軸數；全程整數）。
pub fn Mat::rank(self : Mat) -> Int {
  let m = self.copy()
  let rows = m.rows
  let cols = m.cols
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
    }
    for i = r + 1; i < rows; i = i + 1 {
      while m.get(i, c) != 0L {
        let (g, s, t) = egcd(m.get(r, c), m.get(i, c))
        let a1 = m.get(r, c) / g
        let b1 = m.get(i, c) / g
        m.combine_rows(r, i, s, t, -b1, a1)
      }
    }
    r = r + 1
  }
  r
}

///|
/// 刪去第 i 列與第 j 行的子式。
pub fn Mat::minor(self : Mat, i : Int, j : Int) -> Mat {
  let m = Mat::zero(self.rows - 1, self.cols - 1)
  let mut rr = 0
  for a = 0; a < self.rows; a = a + 1 {
    if a == i {
      continue
    }
    let mut cc = 0
    for b = 0; b < self.cols; b = b + 1 {
      if b == j {
        continue
      }
      m.set(rr, cc, self.get(a, b))
      cc = cc + 1
    }
    rr = rr + 1
  }
  m
}

///|
/// 伴隨矩陣（轉置餘因子矩陣）。
pub fn Mat::adjugate(self : Mat) -> Mat {
  let n = self.rows
  let m = Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      let sgn = if (i + j) % 2 == 0 { 1L } else { -1L }
      m.set(j, i, sgn * self.minor(i, j).det())
    }
  }
  m
}

///|
/// 么模矩陣的逆：A^{-1} = adj(A)/det(A)，det = ±1 時仍為整數矩陣。
pub fn Mat::inverse_unimodular(self : Mat) -> Mat? {
  let d = self.det()
  if iabs(d) != 1L {
    return None
  }
  Some(self.adjugate().scale(d))
}

///|
/// 是否么模（方陣且 det = ±1）。
pub fn Mat::is_unimodular(self : Mat) -> Bool {
  self.rows == self.cols && iabs(self.det()) == 1L
}

///|
/// 2×2 特徵多項式的係數：(1, -tr, det)。
pub fn Mat::char_poly2(self : Mat) -> (Int64, Int64) {
  (self.trace(), self.det())
}

///|
/// 驗證 Cayley–Hamilton：A² - tr(A) A + det(A) I = 0（2×2 情形）。
pub fn Mat::verify_cayley_hamilton2(self : Mat) -> Bool {
  let (t, d) = self.char_poly2()
  let lhs = self.mul(self).sub(self.scale(t)).add(Mat::ident(2).scale(d))
  lhs.is_zero()
}
