///|
/// spec/gfp.mbt —— 有限域 F_p 上的精確算子層（傅立葉、循環、伴隨、辛、超矩陣）。
/// 選用 Fermat 質數 p = 65537（p-1 = 2^16）以支援 2 的冪次長度 N ≤ 2^16 之
/// 原生 N 次單位根：這是「整數 FFT」的精確版本，零浮點誤差。

///|
/// 模 p 加法。
pub fn gadd(a : Int64, b : Int64, p : Int64) -> Int64 {
  @core.zmod(a + b, p)
}

///|
/// 模 p 乘法。
pub fn gmul(a : Int64, b : Int64, p : Int64) -> Int64 {
  @core.zmod(a * b, p)
}

///|
/// 模 p 冪。
pub fn gpow(a : Int64, e : Int64, p : Int64) -> Int64 {
  @core.powmod(a, e, p)
}

///|
/// 模 p 逆。
pub fn ginv(a : Int64, p : Int64) -> Int64 {
  @core.invmod(a, p)
}

///|
/// 判斷 a 是否 N 次原根（a^N = 1 且 a^{N/q} ≠ 1 對每個 prime q | N）。
pub fn is_primitive_root(a : Int64, n : Int, p : Int64) -> Bool {
  if @core.zmod(gpow(a, n.to_int64(), p), p) != 1L {
    return false
  }
  let facts = @core.factorize(n.to_int64())
  for (q, _e) in facts {
    if @core.zmod(gpow(a, (n / q.to_int()).to_int64(), p), p) == 1L {
      return false
    }
  }
  true
}

///|
/// Fermat 質數 p = 65537 的最小原根（3 是 Z/65537 的原根，本函式以驗證確認）。
pub fn fermat_p() -> Int64 {
  65537L
}

///|
/// 取 N 次原根（N | p-1）：g^{(p-1)/N}。
pub fn nth_root(n : Int, p : Int64) -> Int64 {
  let g = 3L
  // 先把 g 提升為原根（如有需要）
  let mut root = g
  for cand = 2L; cand < 100L; cand = cand + 1 {
    if is_primitive_root(cand, (p - 1L).to_int(), p) {
      root = cand
      break
    }
  }
  gpow(root, (p - 1L) / n.to_int64(), p)
}
