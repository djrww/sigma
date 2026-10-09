///|
/// 執行期測試（與 SMT 證明互補）：
///   1. 形式化層的具體取值；
///   2. 已證的遞迴核心與獨立迴圈實作、參考實作三方交叉驗證；
///   3. G2 未決橋接引理的**實例**交叉驗證（全稱陳述見 proof/bridges.smt2）。
test "proof/runtime values" {
  inspect(@proof.abs_verified(-7), content="7")
  inspect(@proof.min2(3, 9), content="3")
  inspect(@proof.max2(3, 9), content="9")
  inspect(@proof.positive_mod(-3, 7), content="4")
  inspect(@proof.triangular(100), content="5050")
  inspect(@proof.factorial(5), content="120")
  inspect(@proof.is_prime_trial(97), content="true")
  inspect(@proof.is_prime_trial(91), content="false")
  inspect(@proof.det2(3, 8, 4, 6), content="-14")
  inspect(@proof.trace2(3, 8, 4, 6), content="9")
  inspect(@proof.cayley_hamilton_2x2(3, 8, 4, 6), content="true")
  inspect(@proof.det2_mul(1, 2, 3, 4, 5, 6, 7, 8), content="true")
  inspect(@proof.fib_step(10).1, content="89")
}

///|
/// 參考 gcd（暴力試除）：與已證的遞迴核心、獨立迴圈實作三方比對。
fn gcd_reference(a : Int, b : Int) -> Int {
  let mut g = 1
  let mut d = 1
  while d <= a && d <= b {
    if a % d == 0 && b % d == 0 {
      g = d
    }
    d = d + 1
  }
  g
}

///|
test "proof/gcd three-way cross-check" {
  let cases : Array[(Int, Int)] = [
    (12, 18),
    (270, 192),
    (1, 1),
    (17, 5),
    (100, 75),
    (81, 27),
  ]
  for (a, b) in cases {
    if @proof.gcd_verified(a, b) != gcd_reference(a, b) {
      fail("gcd mismatch at \\{a},\\{b}")
    }
    if @proof.gcd_euclid_loop(a, b) != @proof.gcd_verified(a, b) {
      fail("loop/recursion mismatch at \\{a},\\{b}")
    }
  }
  for a = 1; a <= 40; a = a + 1 {
    for b = a; b <= 40; b = b + 1 {
      if @proof.gcd_verified(a, b) != gcd_reference(a, b) {
        fail("grid gcd mismatch at \\{a},\\{b}")
      }
    }
  }
}

///|
test "proof/loop and recursion agree" {
  for n = 0; n <= 60; n = n + 1 {
    if @proof.isqrt_full(n) != @proof.isqrt(n) {
      fail("isqrt mismatch at \\{n}")
    }
    if @proof.isqrt_loop(n) != @proof.isqrt(n) {
      fail("isqrt loop mismatch at \\{n}")
    }
  }
  for e = 0; e <= 24; e = e + 1 {
    if @proof.pow_mod_loop(7, e, 97) != @proof.pow_mod(7, e, 97) {
      fail("pow_mod loop mismatch at \\{e}")
    }
  }
}

///|
/// G2 橋接引理的實例驗證：凡 d | a、d | b 者，皆有 d | a mod b 且 d | a（逆推）。
test "proof/bridge instances (G2 cross-check)" {
  for a = 1; a <= 60; a = a + 1 {
    for b = 1; b <= 60; b = b + 1 {
      for d = 1; d <= 12; d = d + 1 {
        if a % d == 0 && b % d == 0 {
          let r = a % b
          if r % d != 0 {
            fail("forward bridge fails: a=\{a} b=\{b} d=\{d}")
          }
        }
      }
    }
  }
  for a = 1; a <= 60; a = a + 1 {
    for b = 1; b <= 60; b = b + 1 {
      for d = 1; d <= 12; d = d + 1 {
        if b % d == 0 && a % b % d == 0 && a % d != 0 {
          fail("backward bridge fails: a=\{a} b=\{b} d=\{d}")
        }
      }
    }
  }
}
