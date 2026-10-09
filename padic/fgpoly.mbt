///|
/// padic/fgpoly.mbt —— 三變數截斷多項式（總次數 ≤ D），用於形式群律的
/// **精確**結合律/交換律驗證。這是「形式群 = 群的代數公理化」的機器實作。
/// 係數為有理數 @core.Frac，故 Ĝ_m、Ĝ_a 與形式對數的恆等式都能逐項精確核對。

///|
/// 單項：係數 + 指數三元組 (a, b, c) 對應 X^a Y^b Z^c。
pub type Term = (@core.Frac, Int, Int, Int)

///|
/// 截斷三變數多項式（稀疏表示）。
pub struct Poly {
  terms : Array[Term]
  deg : Int
}

///|
/// 零多項式。
pub fn Poly::zero(deg : Int) -> Poly {
  { terms: [], deg, }
}

///|
/// 單項式 c·X^a Y^b Z^c。
pub fn Poly::mono(
  c : @core.Frac,
  a : Int,
  b : Int,
  c3 : Int,
  deg : Int,
) -> Poly {
  if a + b + c3 > deg || @core.Frac::sign(c) == 0 {
    return Poly::zero(deg)
  }
  { terms: [(c, a, b, c3)], deg, }
}

///|
/// 加法（自動合併）。
pub fn Poly::add(p : Poly, q : Poly) -> Poly {
  let out : Array[Term] = p.terms.copy()
  for (c, a, b, c3) in q.terms {
    let mut found = false
    for k = 0; k < out.length(); k = k + 1 {
      if out[k].1 == a && out[k].2 == b && out[k].3 == c3 {
        out[k] = (@core.Frac::add(out[k].0, c), a, b, c3)
        found = true
      }
    }
    if !found {
      out.push((c, a, b, c3))
    }
  }
  Poly::normalize({ terms: out, deg: p.deg, })
}

///|
/// 減法。
pub fn Poly::sub(p : Poly, q : Poly) -> Poly {
  p.add(q.scale(@core.Frac::int(-1L)))
}

///|
/// 純量乘。
pub fn Poly::scale(p : Poly, c : @core.Frac) -> Poly {
  let out : Array[Term] = []
  for (x, a, b, c3) in p.terms {
    out.push((@core.Frac::mul(x, c), a, b, c3))
  }
  Poly::normalize({ terms: out, deg: p.deg, })
}

///|
/// 乘法（截斷到總次數 ≤ deg）。
pub fn Poly::mul(p : Poly, q : Poly) -> Poly {
  let out : Array[Term] = []
  for (c1, a1, b1, d1) in p.terms {
    for (c2, a2, b2, d2) in q.terms {
      let a = a1 + a2
      let b = b1 + b2
      let c3 = d1 + d2
      if a + b + c3 <= p.deg {
        out.push((@core.Frac::mul(c1, c2), a, b, c3))
      }
    }
  }
  Poly::normalize({ terms: out, deg: p.deg, })
}

///|
/// 冪次（截斷）。
pub fn Poly::pow(p : Poly, k : Int) -> Poly {
  let mut acc = Poly::mono(@core.Frac::int(1L), 0, 0, 0, p.deg)
  for _i = 0; _i < k; _i = _i + 1 {
    acc = acc.mul(p)
  }
  acc
}

///|
/// 合併同類項、移除零項。
pub fn Poly::normalize(p : Poly) -> Poly {
  let out : Array[Term] = []
  for (c, a, b, c3) in p.terms {
    if @core.Frac::sign(c) == 0 {
      continue
    }
    let mut found = false
    for k = 0; k < out.length(); k = k + 1 {
      if out[k].1 == a && out[k].2 == b && out[k].3 == c3 {
        out[k] = (@core.Frac::add(out[k].0, c), a, b, c3)
        found = true
      }
    }
    if !found {
      out.push((c, a, b, c3))
    }
  }
  let kept : Array[Term] = []
  for t in out {
    if @core.Frac::sign(t.0) != 0 {
      kept.push(t)
    }
  }
  { terms: kept, deg: p.deg, }
}

///|
/// 多項式相等。
pub fn Poly::eq(p : Poly, q : Poly) -> Bool {
  let a = Poly::normalize(p)
  let b = Poly::normalize(q)
  if a.terms.length() != b.terms.length() {
    return false
  }
  for (c, x, y, z) in a.terms {
    let mut found = false
    for (c2, x2, y2, z2) in b.terms {
      if x == x2 && y == y2 && z == z2 && @core.Frac::eq(c, c2) {
        found = true
      }
    }
    if !found {
      return false
    }
  }
  true
}

///|
/// 文字化（供報告）。
pub fn Poly::to_text(p : Poly) -> String {
  let n = Poly::normalize(p)
  if n.terms.length() == 0 {
    return "0"
  }
  let mut s = ""
  for i = 0; i < n.terms.length(); i = i + 1 {
    let (c, a, b, c3) = n.terms[i]
    if i > 0 {
      s = s + " + "
    }
    s = s +
      @core.Frac::to_text(c) +
      "*X^" +
      a.to_string() +
      "*Y^" +
      b.to_string() +
      "*Z^" +
      c3.to_string()
  }
  s
}

///|
/// 結合律檢驗：F(F(X,Y),Z) = F(X,F(Y,Z))，截斷到總次數 deg。
/// 這裡 f 以三變數稀疏多項式表示（其中 Z 的次數應為 0，即 f 只含 X、Y）。
pub fn verify_associativity(f : Poly) -> Bool {
  let fn_ = Poly::normalize(f)
  let deg = f.deg
  // A = Σ c_{mn} F(X,Y)^m · Z^n
  let mut a = Poly::zero(deg)
  for (c, m, n, _k) in fn_.terms {
    a = a.add(f.pow(m).mul(Poly::mono(c, 0, 0, n, deg)))
  }
  // B = Σ c_{mn} X^m · F(Y,Z)^n
  let mut b = Poly::zero(deg)
  for (c, m, n, _k) in fn_.terms {
    // F(Y,Z)：把 f 的 X↔Y 與 Z 對應搬移
    let mut fy = Poly::zero(deg)
    for (c2, m2, n2, _k2) in fn_.terms {
      // f(Y,Z) 中 Y 取 m2 次、Z 取 n2 次
      fy = fy.add(Poly::mono(c2, 0, m2, n2, deg))
    }
    b = b.add(Poly::mono(c, m, 0, 0, deg).mul(fy.pow(n)))
  }
  a.eq(b)
}

///|
/// 交換律檢驗：F(X,Y) = F(Y,X)。
pub fn verify_commutativity(f : Poly) -> Bool {
  let mut s = Poly::zero(f.deg)
  for (c, m, n, k) in Poly::normalize(f).terms {
    s = s.add(Poly::mono(c, n, m, k, f.deg))
  }
  s.eq(f)
}

///|
/// 單位律檢驗：F(X,0) = X 且 F(0,Y) = Y。
pub fn verify_identity_law(f : Poly) -> Bool {
  let deg = f.deg
  let mut fx0 = Poly::zero(deg)
  let mut f0y = Poly::zero(deg)
  for (c, m, n, _k) in Poly::normalize(f).terms {
    if n == 0 {
      fx0 = fx0.add(Poly::mono(c, m, 0, 0, deg))
    }
    if m == 0 {
      f0y = f0y.add(Poly::mono(c, 0, n, 0, deg))
    }
  }
  fx0.eq(Poly::mono(@core.Frac::int(1L), 1, 0, 0, deg)) &&
  f0y.eq(Poly::mono(@core.Frac::int(1L), 0, 1, 0, deg))
}

///|
/// 形式對數（乘法群）截斷級數的係數：L_k = (−1)^{k+1}/k。
pub fn log_coeff(k : Int) -> @core.Frac {
  if k == 0 {
    return @core.Frac::zero()
  }
  let sign = if (k + 1) % 2 == 0 { 1L } else { -1L }
  @core.Frac::of(sign, k.to_int64())
}

///|
/// 義務自證：L(F(X,Y)) = L(X) + L(Y)，其中 F = X + Y + XY，L 截斷到次數 deg。
/// 這是「形式群 ⟷ 形式對數」的核心同構，逐項精確成立。
pub fn verify_formal_log_grouplaw(deg : Int) -> Bool {
  let f = formal_multiplicative_poly(deg)
  // L(F(X,Y)) = Σ_k L_k · F^k
  let mut lhs = Poly::zero(deg)
  for k = 1; k <= deg; k = k + 1 {
    lhs = lhs.add(f.pow(k).scale(log_coeff(k)))
  }
  // L(X) + L(Y)
  let mut rhs = Poly::zero(deg)
  for k = 1; k <= deg; k = k + 1 {
    rhs = rhs
      .add(Poly::mono(log_coeff(k), k, 0, 0, deg))
      .add(Poly::mono(log_coeff(k), 0, k, 0, deg))
  }
  lhs.eq(rhs)
}
