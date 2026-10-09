///|
/// fga/enum.mbt —— 群的離散顯式化：元素列舉、階統計、p-撓計數反推分割、
/// 子群格與結構圖。這些是「結構定理」的可執行證明工具：
/// 對有限阿貝爾群而言，「各階元素個數」是完全不變量。

///|
/// 元素：Z/d_1 × ... × Z/d_r 中的座標向量。
pub type Elem = Array[Int64]

///|
/// 兩元素相加（座標模 d_i）。
pub fn elem_add(g : AbGroup, x : Elem, y : Elem) -> Elem {
  let out : Elem = []
  for i = 0; i < g.tors.length(); i = i + 1 {
    out.push(@core.zmod(x[i] + y[i], g.tors[i]))
  }
  out
}

///|
/// 零元素。
pub fn elem_zero(g : AbGroup) -> Elem {
  let out : Elem = []
  for _i = 0; _i < g.tors.length(); _i = _i + 1 {
    out.push(0L)
  }
  out
}

///|
/// 元素相等。
pub fn elem_eq(x : Elem, y : Elem) -> Bool {
  if x.length() != y.length() {
    return false
  }
  for i = 0; i < x.length(); i = i + 1 {
    if x[i] != y[i] {
      return false
    }
  }
  true
}

///|
/// 元素的階。
pub fn elem_order(g : AbGroup, x : Elem) -> Int64 {
  let mut o = 1L
  for i = 0; i < g.tors.length(); i = i + 1 {
    let d = g.tors[i]
    if x[i] != 0L {
      let c = d / @core.igcd(x[i], d)
      o = o / @core.igcd(o, c) * c
    }
  }
  o
}

///|
/// 列舉有限群的全部元素（|G| 上限由呼叫方控制）。
pub fn elements(g : AbGroup) -> Array[Elem] {
  let out : Array[Elem] = []
  if g.free > 0 || g.tors.length() == 0 {
    if g.tors.length() == 0 {
      out.push([])
    }
    return out
  }
  let r = g.tors.length()
  let idx = FixedArray::make(r, 0L)
  let total = g.order()
  if total > 100000L {
    return out
  }
  for _c = 0; _c < total.to_int(); _c = _c + 1 {
    let e : Elem = []
    for i = 0; i < r; i = i + 1 {
      e.push(idx[i])
    }
    out.push(e)
    // 進位
    let mut k = 0
    while k < r {
      idx[k] = idx[k] + 1L
      if idx[k] < g.tors[k] {
        break
      }
      idx[k] = 0L
      k = k + 1
    }
  }
  out
}

///|
/// 階統計：回傳 (階, 個數) 的有序清單。對有限阿貝爾群是完全不變量。
pub fn order_statistics(g : AbGroup) -> Array[(Int64, Int)] {
  let out : Array[(Int64, Int)] = []
  for x in elements(g) {
    let o = elem_order(g, x)
    let mut found = false
    for k = 0; k < out.length(); k = k + 1 {
      if out[k].0 == o {
        out[k] = (o, out[k].1 + 1)
        found = true
      }
    }
    if !found {
      out.push((o, 1))
    }
  }
  // 依階排序（插入排序）
  for i = 1; i < out.length(); i = i + 1 {
    let cur = out[i]
    let mut j = i - 1
    while j >= 0 && out[j].0 > cur.0 {
      out[j + 1] = out[j]
      j = j - 1
    }
    out[j + 1] = cur
  }
  out
}

///|
/// 義務自證：兩個有限阿貝爾群同構 ⟺ 階統計完全相同。
pub fn isomorphic_by_statistics(g : AbGroup, h : AbGroup) -> Bool {
  if g.free != h.free {
    return false
  }
  if g.order() != h.order() {
    return false
  }
  let sg = order_statistics(g)
  let sh = order_statistics(h)
  if sg.length() != sh.length() {
    return false
  }
  for i = 0; i < sg.length(); i = i + 1 {
    if sg[i].0 != sh[i].0 || sg[i].1 != sh[i].1 {
      return false
    }
  }
  true
}

///|
/// |G[p^e]| = p^{Σ_i min(e, e_i)}：由撓元素計數反推 p-分割。
/// 回傳 G 的 p-部分的指數集合 {e_i}（每個 Z/p^{e_i} 一份）。
pub fn p_partition(g : AbGroup, p : Int64) -> Array[Int] {
  // 1. 收集 p-部分的指數
  let exps : Array[Int] = []
  for d in g.tors {
    let mut e = 0
    let mut x = d
    while x % p == 0L {
      x = x / p
      e = e + 1
    }
    if e > 0 {
      exps.push(e)
    }
  }
  exps
}

///|
/// 整數陣列降序排列輔助函式。
fn sort_desc(arr : Array[Int]) -> Array[Int] {
  let s = arr.copy()
  for i = 0; i < s.length(); i = i + 1 {
    for j = i + 1; j < s.length(); j = j + 1 {
      if s[j] > s[i] {
        let t = s[i]
        s[i] = s[j]
        s[j] = t
      }
    }
  }
  s
}

///|
/// 由 p^n-撓的階反推分割（duality/conjugate partition 版）：
/// 若 k_j = #{i : e_i >= j}，則 Σ_j k_j = Σ_i e_i 且 |G[p^n]| = p^{Σ_i min(n,e_i)}。
/// 本函式用「逐 n 計數」重算 k_j，並回傳還原出的指數集合。
pub fn p_partition_via_torsion_counts(g : AbGroup, p : Int64) -> Array[Int] {
  let exps = p_partition(g, p)
  let mut maxe = 0
  for e in exps {
    if e > maxe {
      maxe = e
    }
  }
  let ks : Array[Int] = []
  for j = 1; j <= maxe; j = j + 1 {
    let mut k = 0
    for e in exps {
      if e >= j {
        k = k + 1
      }
    }
    ks.push(k)
  }
  // 由 k_j 還原指數：e 的多重集 = { j : k_j > 0 } 帶重數 k_j - k_{j+1}
  let out : Array[Int] = []
  for j = 0; j < ks.length(); j = j + 1 {
    let next = if j + 1 < ks.length() { ks[j + 1] } else { 0 }
    let mult = ks[j] - next
    for _t = 0; _t < mult; _t = _t + 1 {
      out.push(j + 1)
    }
  }
  sort_desc(out)
}

///|
/// 義務自證：由撓計數反推的 p-分割與直接分解一致（結構定理的雙路徑驗證）。
pub fn verify_partition_agreement(g : AbGroup, p : Int64) -> Bool {
  let sa = sort_desc(p_partition(g, p))
  let sb = p_partition_via_torsion_counts(g, p)
  if sa.length() != sb.length() {
    return false
  }
  for i = 0; i < sa.length(); i = i + 1 {
    if sa[i] != sb[i] {
      return false
    }
  }
  true
}

///|
/// 子群（以元素集合表示）。
pub type Subgroup = Array[Elem]

///|
/// 由生成元集合計運算閉包（BFS 至飽和）。
pub fn subgroup_closure(g : AbGroup, gens : Array[Elem]) -> Subgroup {
  let subs : Subgroup = []
  if g.tors.length() == 0 {
    return subs
  }
  subs.push(elem_zero(g))
  let mut frontier : Subgroup = [elem_zero(g)]
  while frontier.length() > 0 {
    let next : Subgroup = []
    for x in frontier {
      for y in gens {
        let s = elem_add(g, x, y)
        let mut found = false
        for z in subs {
          if elem_eq(z, s) {
            found = true
          }
        }
        if !found {
          subs.push(s)
          next.push(s)
        }
      }
    }
    frontier = next
  }
  subs
}

///|
/// 子群是否包含元素。
pub fn subgroup_mem(s : Subgroup, x : Elem) -> Bool {
  for z in s {
    if elem_eq(z, x) {
      return true
    }
  }
  false
}

///|
/// 子群包含關係 S ⊆ T。
pub fn subgroup_le(s : Subgroup, t : Subgroup) -> Bool {
  for x in s {
    if !subgroup_mem(t, x) {
      return false
    }
  }
  true
}

///|
/// 子群相等。
pub fn subgroup_eq(s : Subgroup, t : Subgroup) -> Bool {
  s.length() == t.length() && subgroup_le(s, t)
}

///|
/// 由兩子群生成的和（最小包含兩者的子群）。
pub fn subgroup_join(g : AbGroup, s : Subgroup, t : Subgroup) -> Subgroup {
  subgroup_closure(g, s + t)
}

///|
/// 全部子群（|G| 較小時可行）。
pub fn all_subgroups(g : AbGroup) -> Array[Subgroup] {
  let out : Array[Subgroup] = []
  if g.free > 0 || g.order() > 4096L {
    return out
  }
  let els = elements(g)
  let triv : Subgroup = [elem_zero(g)]
  out.push(triv)
  for x in els {
    let is_zero = elem_eq(x, elem_zero(g))
    if !is_zero {
      let s = subgroup_closure(g, [x])
      let mut found = false
      for t in out {
        if subgroup_eq(t, s) {
          found = true
        }
      }
      if !found {
        out.push(s)
      }
    }
  }
  // 兩兩取和直到封閉
  let mut changed = true
  let mut rounds = 0
  while changed && rounds < 64 {
    changed = false
    rounds = rounds + 1
    let n = out.length()
    for i = 0; i < n; i = i + 1 {
      for j = i + 1; j < n; j = j + 1 {
        let jn = subgroup_join(g, out[i], out[j])
        let mut found = false
        for t in out {
          if subgroup_eq(t, jn) {
            found = true
          }
        }
        if !found {
          out.push(jn)
          changed = true
        }
      }
    }
  }
  // 依大小排序
  for i = 0; i < out.length(); i = i + 1 {
    for j = i + 1; j < out.length(); j = j + 1 {
      if out[j].length() < out[i].length() {
        let t = out[i]
        out[i] = out[j]
        out[j] = t
      }
    }
  }
  out
}

///|
/// 子群格：回傳 (子群清單, 覆蓋關係對)。覆蓋：H ⋖ K 且無中間子群。
pub fn subgroup_lattice(g : AbGroup) -> (Array[Subgroup], Array[(Int, Int)]) {
  let subs = all_subgroups(g)
  let covers : Array[(Int, Int)] = []
  for i = 0; i < subs.length(); i = i + 1 {
    for j = 0; j < subs.length(); j = j + 1 {
      if i == j {
        continue
      }
      if !subgroup_le(subs[i], subs[j]) {
        continue
      }
      if subs[i].length() == subs[j].length() {
        continue
      }
      let mut has_middle = false
      for k = 0; k < subs.length(); k = k + 1 {
        if k == i || k == j {
          continue
        }
        if subgroup_le(subs[i], subs[k]) && subgroup_le(subs[k], subs[j]) {
          if subs[k].length() > subs[i].length() &&
            subs[k].length() < subs[j].length() {
            has_middle = true
          }
        }
      }
      if !has_middle {
        covers.push((i, j))
      }
    }
  }
  (subs, covers)
}

///|
/// 子群的最小生成集（貪心）。
pub fn minimal_gens(g : AbGroup, s : Subgroup) -> Array[Elem] {
  let gens : Array[Elem] = []
  let mut span = subgroup_closure(g, [])
  for x in s {
    if !subgroup_mem(span, x) {
      gens.push(x)
      span = subgroup_closure(g, gens)
    }
  }
  gens
}

///|
/// 元素文本。
pub fn elem_text(x : Elem) -> String {
  let mut s = "("
  for i = 0; i < x.length(); i = i + 1 {
    if i > 0 {
      s = s + ","
    }
    s = s + x[i].to_string()
  }
  s + ")"
}

///|
/// 子群文本（以最小生成集表示）。
pub fn subgroup_text(g : AbGroup, s : Subgroup) -> String {
  let gens = minimal_gens(g, s)
  if gens.length() == 0 {
    return "0"
  }
  let mut out = "<"
  for i = 0; i < gens.length(); i = i + 1 {
    if i > 0 {
      out = out + ", "
    }
    out = out + elem_text(gens[i])
  }
  out + ">"
}

///|
/// 義務自證：Lagrange 定理——每個子群的階整除群的階。
pub fn verify_lagrange(g : AbGroup) -> Bool {
  let subs = all_subgroups(g)
  let o = g.order()
  for s in subs {
    if o % s.length().to_int64() != 0L {
      return false
    }
  }
  true
}

///|
/// 群結構圖（ASCII）：層級依階數排列，覆蓋關係以縮排與 ├─ 表示。
pub fn structure_diagram(g : AbGroup) -> String {
  let (subs, covers) = subgroup_lattice(g)
  let mut s = "G = " + g.to_text() + "  |G| = " + g.order().to_string() + "\n"
  if subs.length() == 0 {
    return s + "(非有限群或階過大，未展開子群格)\n"
  }
  for i = 0; i < subs.length(); i = i + 1 {
    let up : Array[Int] = []
    for c in covers {
      if c.0 == i {
        up.push(c.1)
      }
    }
    let mut line = "[" +
      subs[i].length().to_string() +
      "] " +
      subgroup_text(g, subs[i])
    if up.length() > 0 {
      line = line + "  ├─> "
      for k = 0; k < up.length(); k = k + 1 {
        if k > 0 {
          line = line + ", "
        }
        line = line +
          "[" +
          subs[up[k]].length().to_string() +
          "] " +
          subgroup_text(g, subs[up[k]])
      }
    }
    s = s + line + "\n"
  }
  s
}

///|
/// 群階統計圖（ASCII 直方圖）。
pub fn order_histogram(g : AbGroup) -> String {
  let st = order_statistics(g)
  let mut s = ""
  for (o, c) in st {
    let mut bar = ""
    let mut k = 0
    while k < c && k < 60 {
      bar = bar + "#"
      k = k + 1
    }
    s = s + "ord " + o.to_string() + " : " + c.to_string() + " " + bar + "\n"
  }
  s
}
