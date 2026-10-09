///|
/// padic 黑箱測試：Hensel、Teichmüller、形式群律、形式對數、SL2 階、SO(3)。
test "hensel-sqrt" {
  // √2 mod 7^n
  assert_true(@padic.verify_hensel_sqrt(3L, 2L, 7L, 5))
  assert_true(@padic.verify_hensel_sqrt(2L, 4L, 7L, 4))
  assert_true(@padic.verify_hensel_sqrt(1L, 1L, 5L, 6))
}

///|
test "teichmuller" {
  assert_true(@padic.verify_teichmuller(3L, 7L, 4))
  assert_true(@padic.verify_teichmuller(2L, 5L, 3))
}

///|
test "ultrametric" {
  assert_true(@padic.verify_ultrametric(49L, 49L, 7L))
  assert_true(@padic.verify_ultrametric(7L, 14L, 7L))
  assert_true(@padic.verify_ultrametric(6L, 10L, 2L))
}

///|
test "formal-group-laws" {
  assert_true(@padic.verify_formal_group_axioms(6))
  assert_true(@padic.verify_mult_group_associativity())
  assert_true(@padic.verify_formal_log(6))
  assert_true(@padic.verify_formal_log_grouplaw(6))
}

///|
test "sl2-and-so3" {
  assert_true(@padic.verify_sl2_order(3L, 2))
  assert_true(@padic.verify_sl2_order(2L, 3))
  assert_true(@padic.verify_so3_discrete())
}
