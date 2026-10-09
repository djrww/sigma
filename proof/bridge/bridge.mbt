///|
/// 程式側構造性引理（Proof-by-Call）：透過函數呼叫顯式傳入見證項 (b/d) 與 ((a%b)/d)，
/// 由 Why3 WP 演算直接做語法代入（β-歸約），徹底繞開全稱量詞 E-matching 的觸發盲區。

///|
/// 步驟 1：由 b % d == 0 構造顯式商見證 k2 = b / d，滿足 b == d * k2。
pub fn step_b_wit(
  b : Int,
  d : Int,
) -> Int where {
  proof_require: p_b_hyp(b, d),
  proof_ensure: k => b_wit_ok(b, d, k),
} {
  b / d
}

///|
/// 步驟 2：由 (a % b) % d == 0 構造顯式餘數商見證 kr = (a % b) / d，滿足 a % b == d * kr。
pub fn step_rem_wit(
  a : Int,
  b : Int,
  d : Int,
) -> Int where {
  proof_require: p_rem_hyp(a, b, d),
  proof_ensure: kr => rem_wit_ok(a, b, d, kr),
} {
  a % b / d
}

///|
/// 步驟 3：合成 a 的整除見證 k = k2 * (a / b) + kr，滿足 a == d * k。
pub fn step_a_wit(
  a : Int,
  b : Int,
  d : Int,
) -> Int where {
  proof_require: p_dvd_modback_hyp(a, b, d),
  proof_ensure: k => a_wit_ok(a, d, k),
} {
  let k2 = step_b_wit(b, d)
  let kr = step_rem_wit(a, b, d)
  k2 * (a / b) + kr
}

///|
/// 步驟 4：由顯式倍數等式 a == d * k 推得 a % d == 0。
pub fn step_mul_mod(
  a : Int,
  b : Int,
  d : Int,
  k : Int,
) -> Unit where {
  proof_require: p_mul_mod_hyp(a, d, k),
  proof_ensure: dvd_modback_mod_ok(a, b, d),
} {
  ()
}

///|
/// 引理（構造性證明）：取餘步驟的整除逆推（d | b, a mod b ⟹ d | a）。
pub fn dvd_mod_back(
  a : Int,
  b : Int,
  d : Int,
) -> Unit where {
  proof_require: p_dvd_modback_hyp(a, b, d),
  proof_ensure: dvd_modback_mod_ok(a, b, d),
} {
  let k = step_a_wit(a, b, d)
  step_mul_mod(a, b, d, k)
}
