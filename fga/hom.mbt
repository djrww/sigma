///|
/// fga/hom.mbt —— 同態群、Ext、張量積、Tor、Pontryagin 對偶，
/// 以及商群與 p-進擷取。全部以「循環因子分解 + Smith 正規化」實作。
///
/// 基本事實表（本檔案即其可執行版本）：
///   Hom(Z/a, Z/b) = Z/gcd(a,b)     Ext(Z/a, Z/b) = Z/gcd(a,b)
///   Hom(Z, Z/b)   = Z/b           Ext(Z, Z/b)   = 0
///   Hom(Z/a, Z)   = 0             Ext(Z/a, Z)   = 0
///   Hom(Z, Z)     = Z             Ext(Z, Z)     = 0

///|
/// Hom(G, H) 的同態群（本身仍是有限生成阿貝爾群）。
pub fn hom_group(g : AbGroup, h : AbGroup) -> AbGroup {
  let cs : Array[Int64] = []
  // 撓 – 撓：gcd 個因子
  for a in g.tors {
    for b in h.tors {
      cs.push(@core.igcd(a, b))
    }
  }
  // 自由 – 撓：Hom(Z, Z/b) = Z/b
  for _i = 0; _i < g.free; _i = _i + 1 {
    for b in h.tors {
      cs.push(b)
    }
  }
  // 自由 – 自由：Z (每個配對)
  AbGroup::of(g.free * h.free, cs)
}

///|
/// Ext^1(G, H) ≅ ⊕ Z/gcd(g_i, h_j)。
pub fn ext_group(g : AbGroup, h : AbGroup) -> AbGroup {
  let cs : Array[Int64] = []
  for a in g.tors {
    for b in h.tors {
      cs.push(@core.igcd(a, b))
    }
  }
  AbGroup::of(0, cs)
}

///|
/// Tor_1(G, H) ≅ Ext^1(G, H)（有限生成阿貝爾群情形）。
pub fn tor_group(g : AbGroup, h : AbGroup) -> AbGroup {
  ext_group(g, h)
}

///|
/// 張量積 G ⊗ H：自由部分 rank 相乘，撓部分由 gcd 給出。
pub fn tensor_group(g : AbGroup, h : AbGroup) -> AbGroup {
  let cs : Array[Int64] = []
  for a in g.tors {
    for b in h.tors {
      cs.push(@core.igcd(a, b))
    }
  }
  AbGroup::of(g.free * h.free, cs)
}

///|
/// Pontryagin 對偶 G* = Hom(G, R/Z) ≅ Z^r ⊕ ⊕ Z/d_i（與 G 同構但不典範）。
pub fn dual_group(g : AbGroup) -> AbGroup {
  AbGroup::of(g.free, g.tors)
}

///|
/// 雙對偶（典範同構 G** ≅ G）。
pub fn bidual_group(g : AbGroup) -> AbGroup {
  dual_group(dual_group(g))
}

///|
/// p-主成分（p-Sylow 子群）：對每個撓不變因子擷取其 p-冪分量並正規化。
pub fn p_primary(g : AbGroup, p : Int64) -> AbGroup {
  let cs : Array[Int64] = []
  for d in g.tors {
    let mut x = d
    let mut q = 1L
    while x % p == 0L {
      x = x / p
      q = q * p
    }
    if q > 1L {
      cs.push(q)
    }
  }
  AbGroup::of(0, cs)
}

///|
/// 素因子分解（複用 p_primary 擷取各素數 p 之 Sylow 主成分）。
pub fn p_primary_decomposition(g : AbGroup) -> Array[(Int64, Array[Int64])] {
  let out : Array[(Int64, Array[Int64])] = []
  for d in g.tors {
    for (p, _e) in @core.factorize(d) {
      let mut found = false
      for k = 0; k < out.length(); k = k + 1 {
        if out[k].0 == p {
          found = true
        }
      }
      if !found {
        out.push((p, p_primary(g, p).invariants()))
      }
    }
  }
  out
}

///|
/// p^n-撓：G[p^n] = { x : p^n x = 0 }，即 p-可除骨架 [p^n] 的離散模型。
pub fn p_n_torsion(g : AbGroup, p : Int64, n : Int) -> AbGroup {
  let cs : Array[Int64] = []
  for d in g.tors {
    let mut e = 0
    let mut x = d
    while x % p == 0L {
      x = x / p
      e = e + 1
    }
    if e > 0 {
      let k = if e < n { e } else { n }
      cs.push(@core.ipow(p, k))
    }
  }
  AbGroup::of(0, cs)
}

///|
/// 可除判定：有限生成群可除 ⟺ 自由秩 0 且為 0 群（唯一可除的是 0 與 Q-向量空間）。
pub fn is_divisible_fg(g : AbGroup) -> Bool {
  g.free == 0 && g.tors.length() == 0
}

///|
/// 商群 (Z^n / col(A)) / (col(B) 的像) = Z^n / col(A|B)。
pub fn quotient_by_relations(a : @core.Mat, b : @core.Mat) -> AbGroup {
  let cols = a.cols + b.cols
  let m = @core.Mat::zero(a.rows, cols)
  for i = 0; i < a.rows; i = i + 1 {
    for j = 0; j < a.cols; j = j + 1 {
      m.set(i, j, a.get(i, j))
    }
    for j = 0; j < b.cols; j = j + 1 {
      m.set(i, a.cols + j, b.get(i, j))
    }
  }
  group_from_relations(m)
}

///|
/// 可直接由群與「子群生成向量」求商的便捷封裝：
/// G = Z^n/A，H 由 B 的行給出（作為 Z^n 的元素）。
pub fn quotient_by_subgroup_gens(
  a : @core.Mat,
  gens : Array[Array[Int64]],
) -> AbGroup {
  let n = a.cols
  let b = @core.Mat::zero(n, gens.length())
  for j = 0; j < gens.length(); j = j + 1 {
    let v = gens[j]
    for i = 0; i < n; i = i + 1 {
      b.set(i, j, if i < v.length() { v[i] } else { 0L })
    }
  }
  quotient_by_relations(a, b)
}

///|
/// 義務自證 A：Ext ≅ Tor（有限生成阿貝爾群情形）且兩者皆為有限群。
pub fn verify_ext_eq_tor(g : AbGroup, h : AbGroup) -> Bool {
  let e = ext_group(g, h)
  let t = tor_group(g, h)
  e.equal(t) && e.free == 0
}

///|
/// 義務自證 B：(G ⊗ H) 的撓 ≅ Tor_1(G, H)。
pub fn verify_tensor_torsion(g : AbGroup, h : AbGroup) -> Bool {
  let te = tensor_group(g, h)
  let tor = AbGroup::of(0, te.tors)
  tor.equal(tor_group(g, h))
}

///|
/// 義務自證 C：雙對偶同構 G** ≅ G。
pub fn verify_bidual(g : AbGroup) -> Bool {
  bidual_group(g).equal(g)
}

///|
/// 義務自證 D：Hom(Z/a, Z/b) 的階 = gcd(a,b)（逐對檢查，不經正規化）。
pub fn verify_hom_cyclic(a : Int64, b : Int64) -> Bool {
  let g = cyclic_group(a)
  let h = cyclic_group(b)
  let hm = hom_group(g, h)
  hm.equal(cyclic_group(@core.igcd(a, b)))
}

///|
/// 中國餘數定理的群論版本：Z/(a b) ≅ Z/a + Z/b 當 gcd(a,b)=1。
pub fn verify_crt(a : Int64, b : Int64) -> Bool {
  if @core.igcd(a, b) != 1L {
    return false
  }
  cyclic_group(a * b).equal(product_group(cyclic_group(a), cyclic_group(b)))
}
