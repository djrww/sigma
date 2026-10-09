///|
/// core/frac.mbt —— 精確有理數 Q（以 Int64 分子分母表示，恆保持最簡與正分母）。
/// 用途：Gram–Schmidt、LLL 的 μ 係數、對偶格基——全部保持「零浮點誤差」。

///|
/// 有理數 n/d，d > 0，gcd(n,d)=1。
pub struct Frac {
  n : Int64
  d : Int64
}

///|
/// 建構並約分。
pub fn Frac::of(n : Int64, d : Int64) -> Frac {
  if d == 0L {
    abort("Frac: zero denominator")
  }
  let mut nn = n
  let mut dd = d
  if dd < 0L {
    nn = -nn
    dd = -dd
  }
  let g = igcd(nn, dd)
  if g == 0L {
    { n: 0L, d: 1L, }
  } else {
    { n: nn / g, d: dd / g, }
  }
}

///|
/// 整數視為有理數。
pub fn Frac::int(n : Int64) -> Frac {
  { n, d: 1L, }
}

///|
/// 零。
pub fn Frac::zero() -> Frac {
  { n: 0L, d: 1L, }
}

///|
/// 加法。
pub fn Frac::add(a : Frac, b : Frac) -> Frac {
  Frac::of(a.n * b.d + b.n * a.d, a.d * b.d)
}

///|
/// 減法。
pub fn Frac::sub(a : Frac, b : Frac) -> Frac {
  Frac::of(a.n * b.d - b.n * a.d, a.d * b.d)
}

///|
/// 乘法。
pub fn Frac::mul(a : Frac, b : Frac) -> Frac {
  Frac::of(a.n * b.n, a.d * b.d)
}

///|
/// 除法。
pub fn Frac::div(a : Frac, b : Frac) -> Frac {
  Frac::of(a.n * b.d, a.d * b.n)
}

///|
/// 取負。
pub fn Frac::neg(a : Frac) -> Frac {
  { n: -a.n, d: a.d, }
}

///|
/// 符號：-1 / 0 / 1。
pub fn Frac::sign(a : Frac) -> Int {
  if a.n > 0L {
    1
  } else if a.n < 0L {
    -1
  } else {
    0
  }
}

///|
/// 絕對值。
pub fn Frac::abs(a : Frac) -> Frac {
  if a.n < 0L {
    { n: -a.n, d: a.d, }
  } else {
    a
  }
}

///|
/// 比較 a < b。
pub fn Frac::lt(a : Frac, b : Frac) -> Bool {
  a.n * b.d < b.n * a.d
}

///|
/// 比較 a <= b。
pub fn Frac::le(a : Frac, b : Frac) -> Bool {
  a.n * b.d <= b.n * a.d
}

///|
/// 相等。
pub fn Frac::eq(a : Frac, b : Frac) -> Bool {
  a.n == b.n && a.d == b.d
}

///|
/// 四捨五入到最近整數（.5 進位遠離零，LLL 的 round 步驟用）。
pub fn Frac::round(a : Frac) -> Int64 {
  if a.n >= 0L {
    (2L * a.n + a.d) / (2L * a.d)
  } else {
    -((-2L * a.n + a.d) / (2L * a.d))
  }
}

///|
/// 轉成 Double（僅用於報告，不用於判定）。
pub fn Frac::to_double(a : Frac) -> Double {
  a.n.to_double() / a.d.to_double()
}

///|
/// 文本。
pub fn Frac::to_text(a : Frac) -> String {
  if a.d == 1L {
    a.n.to_string()
  } else {
    a.n.to_string() + "/" + a.d.to_string()
  }
}
