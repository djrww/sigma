/// 程式側（.mbt）：帶契約的可執行函數。`moon prove` 對其生成驗證條件並交 Why3/z3 求解。
/// 每個函數對應 corpus 中「義務自證（機器見證＝SMT 已證）」的條目。

///|
/// 絕對值：結果等於 ±x 且符合 abs_ok 謂詞。
pub fn abs_verified(
  x : Int,
) -> Int where {
  proof_ensure: result => abs_ok(x, result),
} {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
/// 絕對值非負。
pub fn abs_nonneg(
  x : Int,
) -> Int where {
  proof_ensure: result => nonneg(result),
} {
  if x < 0 {
    -x
  } else {
    x
  }
}

///|
/// 二元極小值：不大於任一輸入。
pub fn min2(
  a : Int,
  b : Int,
) -> Int where {
  proof_ensure: result => p_min_ok(a, b, result),
} {
  if a <= b {
    a
  } else {
    b
  }
}

///|
/// 二元極大值：不小於任一輸入。
pub fn max2(
  a : Int,
  b : Int,
) -> Int where {
  proof_ensure: result => p_max_ok(a, b, result),
} {
  if a <= b {
    b
  } else {
    a
  }
}

///|
/// 倒數至 0：遞迴終止性由 proof_decrease 提供。
pub fn countdown(
  n : Int,
) -> Int where {
  proof_decrease: n,
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => nonneg(result),
} {
  if n <= 0 {
    0
  } else {
    countdown(n - 1)
  }
}

///|
/// 正模約化：結果落在 [0, m)。
pub fn positive_mod(
  a : Int,
  m : Int,
) -> Int where {
  proof_require: p_pos_hyp(m),
  proof_ensure: result => in_range(result, m),
} {
  let r = a % m
  if r < 0 {
    r + m
  } else {
    r
  }
}

///|
/// 三角形數 n(n+1)/2：迴圈不變式 2s = i(i+1) 逐步保持，終值給出閉式。
pub fn triangular(
  n : Int,
) -> Int where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => 2 * result == n * (n + 1),
} {
  for i = 0, s = 0; i < n; {
    continue i + 1, s + i + 1
  } nobreak {
    s
  } where {
    proof_invariant: tri_ok(i, s),
    proof_invariant: 0 <= i && i <= n,
  }
}

///|
/// 整數平方根：由已證的遞迴核心啟動（契約完整）。
pub fn isqrt(
  n : Int,
) -> Int where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => isqrt_ok(n, result),
} {
  isqrt_rec(n, 0)
}

///|
/// 整數平方根（迴圈實作，供執行期測試用）。
pub fn isqrt_loop(n : Int) -> Int {
  for r = 0; (r + 1) * (r + 1) <= n; {
    continue r + 1
  } nobreak {
    r
  }
}

///|
/// 迭代斐波那契：維持 0 ≤ a ≤ b（單調 + 非負）。
pub fn fib_step(
  n : Int,
) -> (Int, Int) where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => fib_res_ok(result),
} {
  for i = 0, a = 0, b = 1; i < n; {
    continue i + 1, b, a + b
  } nobreak {
    (a, b)
  } where {
    proof_invariant: 0 <= a && a <= b,
    proof_invariant: 0 <= i && i <= n,
  }
}

///|
/// 階乘：非負輸入下結果恆正。
pub fn factorial(
  n : Int,
) -> Int where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => fact_pos(n, result),
} {
  for i = 0, f = 1; i < n; {
    continue i + 1, f * (i + 1)
  } nobreak {
    f
  } where {
    proof_invariant: f > 0,
    proof_invariant: 0 <= i && i <= n,
  }
}

///|
/// 歐幾里得演算法（遞迴核心）：以 proof_decrease 證終止，以雙向整除事項證完整規格。
/// 逆推整除性由已機器證明的 `@bridge.dvd_mod_back(a, b, g)` 構造性引理直接給出。
pub fn gcd_verified(
  a : Int,
  b : Int,
) -> Int where {
  proof_decrease: b,
  proof_require: p_gcd_hyp(a, b),
  proof_ensure: result => gcd_full_ok(a, b, result),
} {
  if b == 0 {
    a
  } else {
    let g = gcd_verified(b, a % b)
    @bridge.dvd_mod_back(a, b, g)
    g
  }
}

///|
/// 歐幾里得演算法（迴圈實作，供執行期測試與同源比較；其正確性由遞迴核心承擔）。
pub fn gcd_euclid_loop(a : Int, b : Int) -> Int {
  for x = a, y = b; y != 0; {
    continue y, x % y
  } nobreak {
    x
  }
}

///|
/// 試除法質數判定：不變式「已檢查區間無因子」保證 result = true ⇒ n 為質數。
pub fn is_prime_trial(
  n : Int,
) -> Bool where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => prime_sound(n, result),
} {
  if n < 2 {
    false
  } else {
    let composite = for d = 2; d < n; {
      if n % d == 0 {
        break true
      }
      continue d + 1
    } nobreak {
      false
    } where {
      proof_invariant: 2 <= d && d <= n,
      proof_invariant: ∀ e : Int, 2 <= e && e < d → n % e != 0,
    }
    !composite
  }
}

///|
/// 模重複平方（RSA / 離散對數核心）：由已證的遞迴核心啟動。
pub fn pow_mod(
  a : Int,
  e : Int,
  m : Int,
) -> Int where {
  proof_require: p_pow_hyp(e, m),
  proof_ensure: result => pow_mod_bound(result, m),
} {
  pow_mod_rec(positive_mod(a, m), e, m, positive_mod(1, m))
}

///|
/// 模重複平方（迴圈實作，供執行期測試用）。
pub fn pow_mod_loop(a : Int, e : Int, m : Int) -> Int {
  for r = 1 % m, b = a % m, k = e; k > 0; {
    let r2 = if k % 2 == 1 { r * b % m } else { r }
    continue r2, b * b % m, k / 2
  } nobreak {
    r
  }
}

///|
/// 2×2 行列式。
pub fn det2(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> Int where {
  proof_ensure: result => result == a * d - b * c,
} {
  a * d - b * c
}

///|
/// 2×2 跡。
pub fn trace2(
  a : Int,
  _b : Int,
  _c : Int,
  d : Int,
) -> Int where {
  proof_ensure: result => result == a + d,
} {
  a + d
}

///|
/// Cayley–Hamilton（2×2）：A² − tr(A)·A + det(A)·I = 0。
pub fn cayley_hamilton_2x2(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
) -> Bool where {
  proof_ensure: result => result == true,
} {
  let tr = a + d
  let det = a * d - b * c
  let p11 = a * a + b * c - tr * a + det
  let p12 = a * b + b * d - tr * b
  let p21 = c * a + d * c - tr * c
  let p22 = c * b + d * d - tr * d + det
  p11 == 0 && p12 == 0 && p21 == 0 && p22 == 0
}

///|
/// 行列式乘性：det(AB) = det(A)·det(B)（GL₂ 的群同態）。
pub fn det2_mul(
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  e : Int,
  f : Int,
  g : Int,
  h : Int,
) -> Bool where {
  proof_ensure: result => result == true,
} {
  let det_a = a * d - b * c
  let det_b = e * h - f * g
  let m11 = a * e + b * g
  let m12 = a * f + b * h
  let m21 = c * e + d * g
  let m22 = c * f + d * h
  m11 * m22 - m12 * m21 == det_a * det_b
}

///|
/// 整數平方根（遞迴版）：以 proof_decrease 顯式給出終止度量，並保留完整規格。
pub fn isqrt_rec(
  n : Int,
  r : Int,
) -> Int where {
  proof_decrease: measure_isqrt(n, r),
  proof_require: p_isqrt_hyp(n, r),
  proof_ensure: result => isqrt_ok(n, result),
} {
  if (r + 1) * (r + 1) <= n {
    isqrt_rec(n, r + 1)
  } else {
    r
  }
}

///|
/// 平方根包裝：由 r = 0 啟動遞迴版。
pub fn isqrt_full(
  n : Int,
) -> Int where {
  proof_require: p_nonneg_hyp(n),
  proof_ensure: result => isqrt_ok(n, result),
} {
  isqrt_rec(n, 0)
}

///|
/// 模重複平方（遞迴版）：維持 [0, m) 的完整規格，終止度量為 e。
pub fn pow_mod_rec(
  a : Int,
  e : Int,
  m : Int,
  r : Int,
) -> Int where {
  proof_decrease: e,
  proof_require: p_powr_hyp(a, e, m, r),
  proof_ensure: result => pow_mod_bound(result, m),
} {
  if e == 0 {
    r
  } else if e % 2 == 0 {
    pow_mod_rec(a * a % m, e / 2, m, r)
  } else {
    pow_mod_rec(a * a % m, e / 2, m, r * a % m)
  }
}
