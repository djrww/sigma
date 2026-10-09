///|
/// fga/abgroup.mbt —— 有限生成阿貝爾群的規範形。
/// 表示法：AbGroup = Z^free ⊕ Z/d_1 ⊕ ... ⊕ Z/d_r，其中 1 < d_1 | d_2 | ... | d_r。
/// 任何構造（直積、餘核、Hom）都先化為「循環因子多重集」，再用 Smith 標準形
/// 正規化成不變因子——這就是有限生成 Z-模結構定理的演算法本體。

///|
/// 有限生成阿貝爾群（規範不變因子形）。
pub struct AbGroup {
  free : Int
  tors : Array[Int64]
}

///|
/// 由自由秩與撓循環因子（任意順序、可含 1）建構並正規化。
pub fn AbGroup::of(free : Int, cycles : Array[Int64]) -> AbGroup {
  let kept : Array[Int64] = []
  for c in cycles {
    if @core.iabs(c) > 1L {
      kept.push(@core.iabs(c))
    }
  }
  if kept.length() == 0 {
    return { free, tors: [], }
  }
  { free, tors: @core.torsion_invariants(@core.Mat::diag(kept)), }
}

///|
/// 平凡群 0。
pub fn trivial_group() -> AbGroup {
  { free: 0, tors: [], }
}

///|
/// 循環群 Z/n（n = 0 表示 Z）。
pub fn cyclic_group(n : Int64) -> AbGroup {
  if n == 0L {
    { free: 1, tors: [], }
  } else {
    AbGroup::of(0, [@core.iabs(n)])
  }
}

///|
/// 自由群 Z^r。
pub fn free_group(r : Int) -> AbGroup {
  { free: r, tors: [], }
}

///|
/// 初等阿貝爾 p-群 (Z/p)^n。
pub fn elementary_abelian(p : Int64, n : Int) -> AbGroup {
  let cs : Array[Int64] = []
  for _i = 0; _i < n; _i = _i + 1 {
    cs.push(p)
  }
  AbGroup::of(0, cs)
}

///|
/// 群的直積（= 直和，阿貝爾情形兩者一致）。
pub fn product_group(g : AbGroup, h : AbGroup) -> AbGroup {
  AbGroup::of(g.free + h.free, g.tors + h.tors)
}

///|
/// 阿貝爾群的自由秩。
pub fn AbGroup::rank(self : AbGroup) -> Int {
  self.free
}

///|
/// 撓不變因子清單。
pub fn AbGroup::invariants(self : AbGroup) -> Array[Int64] {
  self.tors
}

///|
/// 指數（最小 n 使 nG = 0；自由部分非零時回傳 0 表示無限）。
pub fn AbGroup::exponent(self : AbGroup) -> Int64 {
  if self.free > 0 {
    return 0L
  }
  let mut e = 1L
  for d in self.tors {
    e = e / @core.igcd(e, d) * d
  }
  e
}

///|
/// 有限群的階（自由部分非零回傳 0）。
pub fn AbGroup::order(self : AbGroup) -> Int64 {
  if self.free > 0 {
    return 0L
  }
  let mut o = 1L
  for d in self.tors {
    o = o * d
  }
  o
}

///|
/// 是否有限。
pub fn AbGroup::is_finite(self : AbGroup) -> Bool {
  self.free == 0
}

///|
/// 是否為 p-群（有限且階為 p 的冪）。
pub fn AbGroup::is_p_group(self : AbGroup, p : Int64) -> Bool {
  if self.free > 0 {
    return false
  }
  for d in self.tors {
    let mut x = d
    while x > 1L && x % p == 0L {
      x = x / p
    }
    if x != 1L {
      return false
    }
  }
  true
}

///|
/// 是否為循環群。
pub fn AbGroup::is_cyclic(self : AbGroup) -> Bool {
  self.free <= 1 && self.tors.length() <= 1
}

///|
/// 是否可分解為初等阿貝爾 p-群（所有不變因子都是同一個質數）。
pub fn AbGroup::is_elementary(self : AbGroup, p : Int64) -> Bool {
  if self.free > 0 {
    return false
  }
  for d in self.tors {
    if d != p {
      return false
    }
  }
  true
}

///|
/// 群相等（規範形唯一性：等價於不變因子與秩完全一致）。
pub fn AbGroup::equal(self : AbGroup, o : AbGroup) -> Bool {
  if self.free != o.free || self.tors.length() != o.tors.length() {
    return false
  }
  for i = 0; i < self.tors.length(); i = i + 1 {
    if self.tors[i] != o.tors[i] {
      return false
    }
  }
  true
}

///|
/// 群的文本表示：Z^r + Z/d1 + Z/d2 ...（"0" 表示平凡群）。
pub fn AbGroup::to_text(self : AbGroup) -> String {
  if self.free == 0 && self.tors.length() == 0 {
    return "0"
  }
  let mut s = ""
  if self.free > 0 {
    s = "Z^" + self.free.to_string()
  }
  for d in self.tors {
    if s.length() > 0 {
      s = s + " + "
    }
    s = s + "Z/" + d.to_string()
  }
  s
}

///|
/// 餘核：Z^n / col(A) ≅ Z^free ⊕ ⊕ Z/d_i。
/// 公約：關係矩陣 A 的「列 = 生成元數 n」，「行 = 關係數」；
/// 故自由秩 = n − rank(A) = a.rows − rank(A)。
pub fn group_from_relations(a : @core.Mat) -> AbGroup {
  let inv = @core.invariant_factors(a)
  let mut rk = 0
  let cs : Array[Int64] = []
  for d in inv {
    if d != 0L {
      rk = rk + 1
      cs.push(d)
    }
  }
  AbGroup::of(a.rows - rk, cs)
}

///|
/// 義務自證：關係矩陣的秩 + 自由秩 == 生成元數（Z^n 的分解）。
pub fn verify_structure_theorem(a : @core.Mat) -> Bool {
  let g = group_from_relations(a)
  g.free + a.rank() == a.rows
}
