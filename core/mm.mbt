///|
/// core/mm.mbt —— Z 上的矩陣（Mat）。
/// 資料布局：列主序扁平 FixedArray[Int64]，維度資訊在結構內。
/// 一切代數運算都帶「可驗證見證」：運算結果可由測試獨立重算。

///|
/// 整數矩陣：公開欄位僅供形狀查詢，元素一律走 get/set 以維持不變式。
pub struct Mat {
  rows : Int
  cols : Int
  data : FixedArray[Int64]
}

///|
/// 建立 rows×cols 全填 fill 的矩陣。
pub fn Mat::make(rows : Int, cols : Int, fill : Int64) -> Mat {
  { rows, cols, data: FixedArray::make(rows * cols, fill), }
}

///|
/// 零矩陣。
pub fn Mat::zero(rows : Int, cols : Int) -> Mat {
  Mat::make(rows, cols, 0L)
}

///|
/// n 階單位矩陣 I_n（么模矩陣的原型）。
pub fn Mat::ident(n : Int) -> Mat {
  let m = Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    m.set(i, i, 1L)
  }
  m
}

///|
/// 由列陣列建構；不規則輸入會補零到最大列長。
pub fn Mat::of_rows(rs : Array[Array[Int64]]) -> Mat {
  let nr = rs.length()
  let mut nc = 0
  for r in rs {
    if r.length() > nc {
      nc = r.length()
    }
  }
  let m = Mat::zero(nr, nc)
  for i = 0; i < nr; i = i + 1 {
    let r = rs[i]
    for j = 0; j < r.length(); j = j + 1 {
      m.set(i, j, r[j])
    }
  }
  m
}

///|
/// 由方陣對角線建構（SNF、Gram、DFT 等高頻用途）。
pub fn Mat::diag(ds : Array[Int64]) -> Mat {
  let n = ds.length()
  let m = Mat::zero(n, n)
  for i = 0; i < n; i = i + 1 {
    m.set(i, i, ds[i])
  }
  m
}

///|
/// 列數。
pub fn Mat::nrows(self : Mat) -> Int {
  self.rows
}

///|
/// 行數。
pub fn Mat::ncols(self : Mat) -> Int {
  self.cols
}

///|
/// 取元素 a_{ij}。
pub fn Mat::get(self : Mat, i : Int, j : Int) -> Int64 {
  self.data[i * self.cols + j]
}

///|
/// 設元素 a_{ij}。
pub fn Mat::set(self : Mat, i : Int, j : Int, v : Int64) -> Unit {
  self.data[i * self.cols + j] = v
}

///|
/// 深拷貝。
pub fn Mat::copy(self : Mat) -> Mat {
  let m = Mat::zero(self.rows, self.cols)
  for i = 0; i < self.rows * self.cols; i = i + 1 {
    m.data[i] = self.data[i]
  }
  m
}

///|
/// 轉置。
pub fn Mat::transpose(self : Mat) -> Mat {
  let m = Mat::zero(self.cols, self.rows)
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      m.set(j, i, self.get(i, j))
    }
  }
  m
}

///|
/// 交換第 i、j 列。
pub fn Mat::swap_rows(self : Mat, i : Int, j : Int) -> Unit {
  for c = 0; c < self.cols; c = c + 1 {
    let t = self.get(i, c)
    self.set(i, c, self.get(j, c))
    self.set(j, c, t)
  }
}

///|
/// 交換第 i、j 行。
pub fn Mat::swap_cols(self : Mat, i : Int, j : Int) -> Unit {
  for r = 0; r < self.rows; r = r + 1 {
    let t = self.get(r, i)
    self.set(r, i, self.get(r, j))
    self.set(r, j, t)
  }
}

///|
/// 初等列運算：row_dst += k * row_src。
pub fn Mat::add_row(self : Mat, dst : Int, src : Int, k : Int64) -> Unit {
  for c = 0; c < self.cols; c = c + 1 {
    self.set(dst, c, self.get(dst, c) + k * self.get(src, c))
  }
}

///|
/// 初等行運算：col_dst += k * col_src。
pub fn Mat::add_col(self : Mat, dst : Int, src : Int, k : Int64) -> Unit {
  for r = 0; r < self.rows; r = r + 1 {
    self.set(r, dst, self.get(r, dst) + k * self.get(r, src))
  }
}

///|
/// 列取負：row_i *= -1。
pub fn Mat::neg_row(self : Mat, i : Int) -> Unit {
  for c = 0; c < self.cols; c = c + 1 {
    self.set(i, c, -self.get(i, c))
  }
}

///|
/// 兩行線性組合：(col_i, col_j) <- (s*col_i + t*col_j, c*col_i + d*col_j)。
/// 當 [[s,t],[c,d]] 么模時，這是 SNF 的基本行變換。
pub fn Mat::combine_cols(
  self : Mat,
  i : Int,
  j : Int,
  s : Int64,
  t : Int64,
  c : Int64,
  d : Int64,
) -> Unit {
  let col_i = FixedArray::make(self.rows, 0L)
  let col_j = FixedArray::make(self.rows, 0L)
  for r = 0; r < self.rows; r = r + 1 {
    col_i[r] = self.get(r, i)
    col_j[r] = self.get(r, j)
  }
  for r = 0; r < self.rows; r = r + 1 {
    self.set(r, i, s * col_i[r] + t * col_j[r])
    self.set(r, j, c * col_i[r] + d * col_j[r])
  }
}

///|
/// 兩列線性組合：(row_i, row_j) <- (s*row_i + t*row_j, c*row_i + d*row_j)。
pub fn Mat::combine_rows(
  self : Mat,
  i : Int,
  j : Int,
  s : Int64,
  t : Int64,
  c : Int64,
  d : Int64,
) -> Unit {
  let row_i = FixedArray::make(self.cols, 0L)
  let row_j = FixedArray::make(self.cols, 0L)
  for k = 0; k < self.cols; k = k + 1 {
    row_i[k] = self.get(i, k)
    row_j[k] = self.get(j, k)
  }
  for k = 0; k < self.cols; k = k + 1 {
    self.set(i, k, s * row_i[k] + t * row_j[k])
    self.set(j, k, c * row_i[k] + d * row_j[k])
  }
}

///|
/// 加法。
pub fn Mat::add(self : Mat, o : Mat) -> Mat {
  let m = Mat::zero(self.rows, self.cols)
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      m.set(i, j, self.get(i, j) + o.get(i, j))
    }
  }
  m
}

///|
/// 減法。
pub fn Mat::sub(self : Mat, o : Mat) -> Mat {
  let m = Mat::zero(self.rows, self.cols)
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      m.set(i, j, self.get(i, j) - o.get(i, j))
    }
  }
  m
}

///|
/// 純量乘法。
pub fn Mat::scale(self : Mat, k : Int64) -> Mat {
  let m = Mat::zero(self.rows, self.cols)
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      m.set(i, j, k * self.get(i, j))
    }
  }
  m
}

///|
/// 矩陣乘法（內維度必須相符）。
pub fn Mat::mul(self : Mat, o : Mat) -> Mat {
  let m = Mat::zero(self.rows, o.cols)
  for i = 0; i < self.rows; i = i + 1 {
    for k = 0; k < self.cols; k = k + 1 {
      let a = self.get(i, k)
      if a != 0L {
        for j = 0; j < o.cols; j = j + 1 {
          m.set(i, j, m.get(i, j) + a * o.get(k, j))
        }
      }
    }
  }
  m
}

///|
/// 逐元素相等。
pub fn Mat::eq(self : Mat, o : Mat) -> Bool {
  if self.rows != o.rows || self.cols != o.cols {
    return false
  }
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      if self.get(i, j) != o.get(i, j) {
        return false
      }
    }
  }
  true
}

///|
/// 是否為零矩陣。
pub fn Mat::is_zero(self : Mat) -> Bool {
  for i = 0; i < self.rows * self.cols; i = i + 1 {
    if self.data[i] != 0L {
      return false
    }
  }
  true
}

///|
/// 是否為對角矩陣（所有 i != j 的位置皆為 0）。
pub fn Mat::is_diagonal(self : Mat) -> Bool {
  for i = 0; i < self.rows; i = i + 1 {
    for j = 0; j < self.cols; j = j + 1 {
      if i != j && self.get(i, j) != 0L {
        return false
      }
    }
  }
  true
}

///|
/// 跡（trace）。
pub fn Mat::trace(self : Mat) -> Int64 {
  let mut s = 0L
  let n = if self.rows < self.cols { self.rows } else { self.cols }
  for i = 0; i < n; i = i + 1 {
    s = s + self.get(i, i)
  }
  s
}

///|
/// 第 i 列（副本）。
pub fn Mat::row(self : Mat, i : Int) -> Array[Int64] {
  let out : Array[Int64] = []
  for j = 0; j < self.cols; j = j + 1 {
    out.push(self.get(i, j))
  }
  out
}

///|
/// 第 j 行（副本）。
pub fn Mat::col(self : Mat, j : Int) -> Array[Int64] {
  let out : Array[Int64] = []
  for i = 0; i < self.rows; i = i + 1 {
    out.push(self.get(i, j))
  }
  out
}

///|
/// 元素絕對值上界。
pub fn Mat::entry_bound(self : Mat) -> Int64 {
  let mut best = 0L
  for i = 0; i < self.rows * self.cols; i = i + 1 {
    let v = iabs(self.data[i])
    if v > best {
      best = v
    }
  }
  best
}

///|
/// 溢出守衛：det / SNF / LLL 路徑的定義域定理之可執行版本。
/// 若 Hadamard 上界 (b*sqrt(n))^n 可能超過 2^62，則拒絕執行。
pub fn Mat::guard_hadamard(self : Mat) -> Bool {
  let n = if self.rows > self.cols { self.rows } else { self.cols }
  let b = self.entry_bound()
  // 保守上界：每一項 <= b^n * n!；n! <= 2^63 之前 n <= 6。
  if n > 6 {
    return false
  }
  let mut f = 1L
  for k = 1; k <= n; k = k + 1 {
    f = f * k.to_int64()
  }
  // b^n * n! <= 2^60 ?
  let mut p = 1L
  for _k = 0; _k < n; _k = _k + 1 {
    if p > 1152921504606846976L / (if b == 0L { 1L } else { b }) {
      return false
    }
    p = p * (if b == 0L { 1L } else { b })
  }
  p <= 1152921504606846976L / (if f == 0L { 1L } else { f })
}

///|
/// 人類/機器皆可讀的矩陣文本：[r1c1 r1c2; r2c1 r2c2]。
pub fn Mat::to_text(self : Mat) -> String {
  let mut s = "["
  for i = 0; i < self.rows; i = i + 1 {
    if i > 0 {
      s = s + "; "
    }
    for j = 0; j < self.cols; j = j + 1 {
      if j > 0 {
        s = s + " "
      }
      s = s + self.get(i, j).to_string()
    }
  }
  s + "]"
}

///|
/// 對角線字串（SNF 證書輸出用）。
pub fn Mat::diag_text(self : Mat) -> String {
  let mut s = "("
  let n = if self.rows < self.cols { self.rows } else { self.cols }
  for i = 0; i < n; i = i + 1 {
    if i > 0 {
      s = s + ","
    }
    s = s + self.get(i, i).to_string()
  }
  s + ")"
}
