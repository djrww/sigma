///|
/// Σ-Cryptographic Hardware Abstraction Layer (Virtual Package `sigma_hal`).
///
/// Mechanism D: Official MoonBit `virtual` / `implement` / `overrides` pattern.
/// This package defines the virtual cryptographic arithmetic interface and its
/// default pure-software reference implementation (`"sigma-hal-default-sw"`).
/// Downstream targets (such as `sigma` and `cmd/main`) can override this
/// package at compile time via `overrides: ["sigma/supermatrix/sigma_hal_ct"]`
/// to switch to the constant-time bitwise-masked & hardware-blinded backend
/// without changing a single line of `.sigma` DSL or protocol logic.

///|
pub fn hal_backend_name() -> String {
  "sigma-hal-default-sw"
}

///|
pub fn hal_is_constant_time() -> Bool {
  false
}

///|
pub fn hal_ct_select(mask_bit : Int, a : Int, b : Int) -> Int {
  if mask_bit != 0 {
    a
  } else {
    b
  }
}

///|
pub fn hal_mod_norm(x : Int, q : Int) -> Int {
  let r = x % q
  if r < 0 {
    r + q
  } else {
    r
  }
}

///|
pub fn hal_mod_add(a : Int, b : Int, q : Int) -> Int {
  hal_mod_norm(a + b, q)
}

///|
pub fn hal_mod_sub(a : Int, b : Int, q : Int) -> Int {
  hal_mod_norm(a - b, q)
}

///|
pub fn hal_mod_mul(a : Int, b : Int, q : Int) -> Int {
  hal_mod_norm(a * b, q)
}

///|
pub fn hal_ntt_butterfly(
  u : Int,
  v : Int,
  twiddle : Int,
  q : Int,
) -> (Int, Int) {
  let t = hal_mod_mul(v, twiddle, q)
  let out0 = hal_mod_add(u, t, q)
  let out1 = hal_mod_sub(u, t, q)
  (out0, out1)
}

///|
pub fn hal_lwe_blinded_decode(
  b_val : Int,
  a_val : Int,
  s_key : Int,
  blinding_r : Int,
  q : Int,
) -> Int {
  let _ = blinding_r
  let diff = hal_mod_sub(b_val, hal_mod_mul(a_val, s_key, q), q)
  let centered = if 2 * diff > q { diff - q } else { diff }
  let abs2 = if centered >= 0 { 2 * centered } else { -2 * centered }
  if abs2 * 2 > q {
    1
  } else {
    0
  }
}

///|
pub fn hal_kron_det_2_4(det_a2 : Int, det_b4 : Int) -> Int {
  let a2 = det_a2 * det_a2
  let a4 = a2 * a2
  let b2 = det_b4 * det_b4
  a4 * b2
}

///|
pub fn hal_audit_digest() -> Int {
  let (y0, y1) = hal_ntt_butterfly(5, 3, 9, 17)
  let bit1 = hal_lwe_blinded_decode(14, 7, 1, 5, 17)
  let kdet = hal_kron_det_2_4(2, 36)
  y0 * 100000 + y1 * 10000 + bit1 * 1000 + kdet % 1000
}
