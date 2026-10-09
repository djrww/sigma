///|
/// core 套件 —— Σ-超矩陣框架的算術地基。
/// 全部在 Z 上做「精確」運算：以 Int64 承載，並以顯式的數值域守衛
/// 保證不溢出（見 core_domain_test）。
/// 本檔案：Z 上的初等整數運算子（gcd / 擴展歐幾里得 / 帶符號除法 / 冪）。

///|
/// 絕對值。
pub fn iabs(a : Int64) -> Int64 {
  if a < 0L {
    -a
  } else {
    a
  }
}

///|
/// 最大公因數（恆非負，gcd(0,0)=0）。
pub fn igcd(a : Int64, b : Int64) -> Int64 {
  let mut x = iabs(a)
  let mut y = iabs(b)
  while y != 0L {
    let t = x % y
    x = y
    y = t
  }
  x
}

///|
/// 擴展歐幾里得：回傳 (g, s, t) 使 g = s*a + t*b 且 g = gcd(a,b) >= 0。
/// 這是 SNF 演算法中所有么模行/列變換的來源。
pub fn egcd(a : Int64, b : Int64) -> (Int64, Int64, Int64) {
  let mut old_r = a
  let mut r = b
  let mut old_s = 1L
  let mut s = 0L
  let mut old_t = 0L
  let mut t = 1L
  while r != 0L {
    let q = old_r / r
    let nr = old_r - q * r
    old_r = r
    r = nr
    let ns = old_s - q * s
    old_s = s
    s = ns
    let nt = old_t - q * t
    old_t = t
    t = nt
  }
  if old_r < 0L {
    (-old_r, -old_s, -old_t)
  } else {
    (old_r, old_s, old_t)
  }
}

///|
/// 對非零除數 b 的地板除法（a == b * zdiv(a, b) + zmod(a, b)）。
pub fn zdiv(a : Int64, b : Int64) -> Int64 {
  let q = a / b
  let r = a % b
  if r < 0L {
    if b > 0L {
      q - 1L
    } else {
      q + 1L
    }
  } else {
    q
  }
}

///|
/// 正規化餘數：zmod(a,b) 落在 [0,|b|) 內。
pub fn zmod(a : Int64, b : Int64) -> Int64 {
  let m = iabs(b)
  let r = a % m
  if r < 0L {
    r + m
  } else {
    r
  }
}

///|
/// 整數冪（exponent >= 0；負指數回傳 0，本框架不需要有理數）。
pub fn ipow(a : Int64, e : Int) -> Int64 {
  let mut base = a
  let mut exp = e
  let mut acc = 1L
  while exp > 0 {
    if exp % 2 == 1 {
      acc = acc * base
    }
    base = base * base
    exp = exp / 2
  }
  acc
}

///|
/// 模冪 a^e mod m（m > 0）。用於 (Z/p^n)* 與 Hensel 提升。
pub fn powmod(a : Int64, e : Int64, m : Int64) -> Int64 {
  if m == 1L {
    return 0L
  }
  let mut base = zmod(a, m)
  let mut exp = e
  let mut acc = 1L
  while exp > 0L {
    if exp % 2L == 1L {
      acc = zmod(acc * base, m)
    }
    base = zmod(base * base, m)
    exp = exp / 2L
  }
  acc
}

///|
/// 模逆（牛頓迭代版，要求 gcd(a,m)=1 且 m > 1）。回傳 x 使 a*x ≡ 1 (mod m)。
pub fn invmod(a : Int64, m : Int64) -> Int64 {
  let (g, s, _t) = egcd(a, m)
  if g != 1L {
    abort("invmod: not invertible")
  }
  zmod(s, m)
}

///|
/// 判斷 a | b。
pub fn divides(a : Int64, b : Int64) -> Bool {
  if a == 0L {
    b == 0L
  } else {
    b % a == 0L
  }
}
