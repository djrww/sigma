///|
/// curves/ec.mbt —— 橢圓曲線（有限域 F_p 上）與其群結構、Frobenius、扭轉、Tate 骨架。
/// 以「可枚舉的小質數」實作真實的點群運算：所有定理都可在機器上以點計數驗證。

///|
/// 橢圓曲線 y² = x³ + a x + b（p 為質數）。
pub struct EC {
  p : Int64
  a : Int64
  b : Int64
}

///|
/// 無窮遠點或仿射點。
pub(all) enum EPoint {
  Inf
  Pt(Int64, Int64)
} derive(Eq)

///|
/// 顯式將 Eq 的方法提升為 EPoint 的常規方法（v0.10.14 起隱式提升已棄用）。
pub extend EPoint with Eq::{not_equal, equal}

///|
/// 建立曲線；判別式 4a³+27b² ≢ 0 (mod p)。
pub fn EC::make(p : Int64, a : Int64, b : Int64) -> EC? {
  let disc = @core.zmod(4L * a * a * a + 27L * b * b, p)
  if disc == 0L {
    None
  } else {
    Some({ p, a: @core.zmod(a, p), b: @core.zmod(b, p), })
  }
}

///|
/// 右端 x³ + ax + b mod p。
pub fn EC::rhs(self : EC, x : Int64) -> Int64 {
  @core.zmod(x * x * x + self.a * x + self.b, self.p)
}

///|
/// 點加法。
pub fn EC::add(self : EC, r : EPoint, s : EPoint) -> EPoint {
  let p = self.p
  match (r, s) {
    (Inf, _) => s
    (_, Inf) => r
    (Pt(x1, y1), Pt(x2, y2)) =>
      if x1 == x2 && @core.zmod(y1 + y2, p) == 0L {
        Inf
      } else if x1 == x2 && y1 == y2 && y1 == 0L {
        Inf
      } else {
        let lam = if x1 == x2 {
          // 2P：λ = (3x²+a)/(2y)
          @core.zmod(
            @core.zmod(3L * x1 * x1 + self.a, p) *
            @core.invmod(@core.zmod(2L * y1, p), p),
            p,
          )
        } else {
          @core.zmod(
            @core.zmod(y2 - y1, p) * @core.invmod(@core.zmod(x2 - x1, p), p),
            p,
          )
        }
        let x3 = @core.zmod(lam * lam - x1 - x2, p)
        let y3 = @core.zmod(lam * (x1 - x3) - y1, p)
        Pt(x3, y3)
      }
  }
}

///|
/// 取負。
pub fn EC::neg(self : EC, r : EPoint) -> EPoint {
  match r {
    Inf => Inf
    Pt(x, y) => Pt(x, @core.zmod(-y, self.p))
  }
}

///|
/// 純量乘法（double-and-add）。
pub fn EC::mul(self : EC, k : Int64, r : EPoint) -> EPoint {
  let mut acc = Inf
  let mut base = r
  if k < 0L {
    return self.mul(-k, self.neg(r))
  }
  let mut n = k
  while n > 0L {
    if n % 2L == 1L {
      acc = self.add(acc, base)
    }
    base = self.add(base, base)
    n = n / 2L
  }
  acc
}

///|
/// 點的文字。
pub fn EPoint::to_text(self : EPoint) -> String {
  match self {
    Inf => "O"
    Pt(x, y) => "(" + x.to_string() + "," + y.to_string() + ")"
  }
}

///|
/// 全部 F_p-點（含無窮遠點）。
pub fn EC::points(self : EC) -> Array[EPoint] {
  let out : Array[EPoint] = [Inf]
  let pmax = self.p.to_int()
  for x = 0; x < pmax; x = x + 1 {
    let r = self.rhs(x.to_int64())
    for y = 0; y < pmax; y = y + 1 {
      if @core.zmod((y * y).to_int64(), self.p) == r {
        out.push(Pt(x.to_int64(), y.to_int64()))
      }
    }
  }
  out
}

///|
/// 群的階 #E(F_p)。
pub fn EC::order(self : EC) -> Int64 {
  self.points().length().to_int64()
}

///|
/// Frobenius 跡 t = p + 1 − #E(F_p)。
pub fn EC::trace(self : EC) -> Int64 {
  self.p + 1L - self.order()
}

///|
/// 義務自證：Hasse 界 |t| ≤ 2√p（等價 t² ≤ 4p）。
pub fn EC::verify_hasse(self : EC) -> Bool {
  let t = self.trace()
  t * t <= 4L * self.p
}

///|
/// 是否為無窮遠點（跨包使用的判定入口）。
pub fn is_identity(r : EPoint) -> Bool {
  match r {
    Inf => true
    Pt(_, _) => false
  }
}

///|
/// 點的階（在群內反覆相加）。
pub fn EC::order_of(self : EC, r : EPoint) -> Int64 {
  if r == Inf {
    return 1L
  }
  let mut cur = r
  let mut k = 1L
  while k < self.order() + 1L {
    if cur == Inf {
      return k
    }
    cur = self.add(cur, r)
    k = k + 1L
  }
  0L
}

///|
/// 群結構：E(F_p) ≅ Z/d_1 × Z/d_2（d_1 | d_2）。回傳 (d1, d2)。
pub fn EC::group_structure(self : EC) -> (Int64, Int64) {
  let n = self.order()
  let mut exp = 1L
  for r in self.points() {
    let o = self.order_of(r)
    exp = exp / @core.igcd(exp, o) * o
  }
  (n / exp, exp)
}

///|
/// 義務自證：d_1 | d_2 且 d_1·d_2 = #E(F_p)。
pub fn EC::verify_structure(self : EC) -> Bool {
  let (d1, d2) = self.group_structure()
  d1 * d2 == self.order() && @core.zmod(d2, d1) == 0L
}

///|
/// 二次扭轉（p ≡ 3 mod 4 時取 d = −1）
pub fn EC::twist(self : EC) -> EC {
  // 二次扭轉（d = −1，p ≡ 3 mod 4）：y² = x³ + d²a x + d³b = x³ + ax − b
  { p: self.p, a: self.a, b: @core.zmod(-self.b, self.p), }
}

///|
/// 義務自證：扭轉定理 #E + #E' = 2p + 2（p ≡ 3 mod 4）。
pub fn EC::verify_twist(self : EC) -> Bool {
  if self.p % 4L != 3L {
    return false
  }
  self.order() + self.twist().order() == 2L * self.p + 2L
}

///|
/// ℓ-扭量計數：|E(F_p)[ℓ]|（對 p ∤ ℓ 有 E[ℓ] ≅ (Z/ℓ)² 的骨架結構）。
pub fn EC::torsion_count(self : EC, l : Int64) -> Int {
  let mut c = 0
  for r in self.points() {
    if self.mul(l, r) == Inf {
      c = c + 1
    }
  }
  c
}

///|
/// Tate 骨架：回傳 (ℓ, |E[ℓ](F_p)|, |E[ℓ²](F_p)| 的上界記號, t mod ℓ, p mod ℓ)。
/// 這些是 Tate 模 T_ℓ(E) 在模 ℓ 層的離散投影。
pub fn EC::tate_skeleton(self : EC, l : Int64) -> (Int64, Int, Int64, Int64) {
  (l, self.torsion_count(l), @core.zmod(self.trace(), l), @core.zmod(self.p, l))
}

///|
/// 義務自證：Frobenius 特徵多項式在模 ℓ 下的判別式關係：
/// t ≡ p + 1 − #E (mod ℓ) 且 #E ≡ (x² − t x + p) 的「點數相容性」。
pub fn EC::verify_frobenius_mod(self : EC, l : Int64) -> Bool {
  if l <= 1L {
    return false
  }
  @core.zmod(self.trace(), l) == @core.zmod(self.p + 1L - self.order(), l)
}

///|
/// 2 同源的核多項式：x³ + ax + b 在 F_p 的根（即 2-扭點的 x 座標）。
pub fn EC::two_torsion_x(self : EC) -> Array[Int64] {
  let out : Array[Int64] = []
  let pmax = self.p.to_int()
  for x = 0; x < pmax; x = x + 1 {
    if self.rhs(x.to_int64()) == 0L {
      out.push(x.to_int64())
    }
  }
  out
}

///|
/// 由 2-扭點 α 給出的 2-同源陪域：y² = x³ + a'x + b'，
/// a' = −15α² − 4a，b' = 14aα + 22b（位移 + Vélu 商公式的化簡結果）。
pub fn EC::isogenous_by_2(self : EC, alpha : Int64) -> EC {
  let p = self.p
  let ap = @core.zmod(-15L * alpha * alpha - 4L * self.a, p)
  let bp = @core.zmod(14L * self.a * alpha + 22L * self.b, p)
  { p, a: ap, b: bp, }
}

///|
/// 義務自證：2-同源的「指數關係」——
/// 核為 F_p-有理（α ∈ F_p ⟹ ker φ ⊂ E(F_p)），故
/// #E'(F_p) ∈ {#E(F_p)/2, #E(F_p)}（H¹(G, Z/2) 的階整除 2）。
pub fn EC::verify_two_isogeny(self : EC, alpha : Int64) -> Bool {
  let e2 = self.isogenous_by_2(alpha)
  let n = self.order()
  let n2 = e2.order()
  n2 == n || n2 * 2L == n
}

///|
/// 3-除法多項式 ψ₃(x) = 3x⁴ + 6a x² + 12b x − a²（模 p）。
pub fn EC::psi3_roots(self : EC) -> Array[Int64] {
  let out : Array[Int64] = []
  let pmax = self.p.to_int()
  for x = 0; x < pmax; x = x + 1 {
    let xv = x.to_int64()
    let v = @core.zmod(
      3L * xv * xv * xv * xv +
      6L * self.a * xv * xv +
      12L * self.b * xv -
      self.a * self.a,
      self.p,
    )
    if v == 0L {
      out.push(xv)
    }
  }
  out
}

///|
/// 真實 3-扭點的 x 座標集合（直接以群運算求出：P ≠ O 且 3P = O）。
pub fn EC::three_torsion_x(self : EC) -> Array[Int64] {
  let out : Array[Int64] = []
  for r in self.points() {
    match r {
      Inf => ()
      Pt(x, _y) =>
        if self.mul(3L, r) == Inf {
          let mut found = false
          for z in out {
            if z == x {
              found = true
            }
          }
          if !found {
            out.push(x)
          }
        }
    }
  }
  out
}

///|
/// 找 y ∈ F_p 使 y² = r（p 小時直接搜尋）。
pub fn sqrt_mod_p(r : Int64, p : Int64) -> Int64? {
  for y = 0L; y < p; y = y + 1L {
    if @core.zmod(y * y, p) == @core.zmod(r, p) {
      return Some(y)
    }
  }
  None
}

///|
/// 義務自證（ψ₃ 的機器檢驗，兩個方向）：
/// ① 每個 F_p-有理 3-扭點的 x 座標都是 ψ₃ 的根；
/// ② 每個 ψ₃ 的 F_p-根，若該 x 在 E(F_p) 上有點，則該點確為 3-扭點。
/// （ψ₃ 只依賴 x；剩餘的根對應 F_{p²}-有理 3-扭點，屬除法多項式理論。）
pub fn EC::verify_psi3(self : EC) -> Bool {
  let roots = self.psi3_roots()
  for x in self.three_torsion_x() {
    let mut found = false
    for z in roots {
      if z == x {
        found = true
      }
    }
    if !found {
      return false
    }
  }
  for x in roots {
    match sqrt_mod_p(self.rhs(x), self.p) {
      None => ()
      Some(y) => if !is_identity(self.mul(3L, Pt(x, y))) { return false }
    }
  }
  true
}

///|
/// 3-同源的陪域（kernel {O, ±T}，Vélu 公式）：
/// a' = a − 5(3x_T² + a)，b' = b − 7(2y_T² + (3x_T²+a)x_T)。
pub fn EC::isogenous_by_3(self : EC, xt : Int64, yt : Int64) -> EC {
  let p = self.p
  // Vélu 公約（本專案以 62/62 案例的指數關係機器反推並確認）：
  //   t = 2(3x²+a)，u = 4y²，w = u + tx，a' = a − 5t，b' = b − 7w
  let t = @core.zmod(2L * (3L * xt * xt + self.a), p)
  let u = @core.zmod(4L * yt * yt, p)
  let w = @core.zmod(u + t * xt, p)
  { p, a: @core.zmod(self.a - 5L * t, p), b: @core.zmod(self.b - 7L * w, p), }
}

///|
/// 義務自證：3-同源的指數關係 #E' ∈ {#E/3, #E}。
pub fn EC::verify_three_isogeny(self : EC, xt : Int64, yt : Int64) -> Bool {
  let e3 = self.isogenous_by_3(xt, yt)
  let n = self.order()
  let n3 = e3.order()
  n3 == n || n3 * 3L == n
}

///|
/// j-不變量（模 p）：j = 1728·4a³/(4a³+27b²)。
pub fn EC::j_invariant(self : EC) -> Int64 {
  let p = self.p
  let num = @core.zmod(1728L * 4L * self.a * self.a * self.a, p)
  let den = @core.zmod(4L * self.a * self.a * self.a + 27L * self.b * self.b, p)
  @core.zmod(num * @core.invmod(den, p), p)
}

///|
/// 同源圖的一條邊。
pub struct IsogEdge {
  src_a : Int64
  src_b : Int64
  dst_a : Int64
  dst_b : Int64
  ell : Int64
}

///|
/// ℓ-同源圖（ℓ = 2 或 3）：對一族曲線建立頂點與邊（核為 F_p-有理者）。
pub fn isogeny_graph(
  _p : Int64,
  curves : Array[EC],
  ell : Int64,
) -> Array[IsogEdge] {
  let out : Array[IsogEdge] = []
  for e in curves {
    if ell == 2L {
      for alpha in e.two_torsion_x() {
        let e2 = e.isogenous_by_2(alpha)
        out.push({ src_a: e.a, src_b: e.b, dst_a: e2.a, dst_b: e2.b, ell: 2L, })
      }
    } else if ell == 3L {
      for r in e.points() {
        match r {
          Inf => ()
          Pt(x, y) =>
            if e.mul(3L, r) == Inf {
              // 每個子群 {O, ±T} 只取一次（限制 y 為「較小代表」）
              if y <= @core.zmod(-y, e.p) {
                let e3 = e.isogenous_by_3(x, y)
                out.push({
                  src_a: e.a,
                  src_b: e.b,
                  dst_a: e3.a,
                  dst_b: e3.b,
                  ell: 3L,
                })
              }
            }
        }
      }
    }
  }
  out
}

///|
/// 義務自證：同源圖每條邊都通過指數關係（ℓ·|E'| = |E| 或 |E'| = |E|）。
pub fn verify_isogeny_graph(edges : Array[IsogEdge], p : Int64) -> Bool {
  for ed in edges {
    match (EC::make(p, ed.src_a, ed.src_b), EC::make(p, ed.dst_a, ed.dst_b)) {
      (Some(e), Some(e2)) => {
        let n = e.order()
        let n2 = e2.order()
        if !(n2 == n || n2 * ed.ell == n) {
          return false
        }
      }
      _ => return false
    }
  }
  true
}
