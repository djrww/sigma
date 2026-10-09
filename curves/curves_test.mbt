///|
/// curves 黑箱測試：點群、結構、Hasse、扭轉、Tate 骨架、2/3-同源。
test "ec-basic" {
  match @curves.EC::make(17L, 1L, 1L) {
    None => abort("nonsingular expected")
    Some(e) => {
      let n = e.order()
      assert_true(n > 0L)
      assert_true(e.verify_hasse())
      assert_true(e.verify_structure())
      let (d1, d2) = e.group_structure()
      assert_eq(d1 * d2, n)
      assert_true(e.j_invariant() >= 0L)
    }
  }
}

///|
test "ec-twist" {
  match @curves.EC::make(19L, 1L, 1L) {
    None => abort("expected")
    Some(e) => assert_true(e.verify_twist())
  }
  match @curves.EC::make(23L, 2L, 3L) {
    None => abort("expected")
    Some(e) => assert_true(e.verify_twist())
  }
}

///|
test "ec-psi3" {
  match @curves.EC::make(17L, 1L, 1L) {
    None => abort("expected")
    Some(e) => assert_true(e.verify_psi3())
  }
  match @curves.EC::make(31L, 1L, 3L) {
    None => abort("expected")
    Some(e) => assert_true(e.verify_psi3())
  }
}

///|
test "two-isogeny" {
  let mut ok = 0
  let mut total = 0
  for p in [11L, 17L, 19L, 23L] {
    for a = 0L; a < 5L; a = a + 1L {
      match @curves.EC::make(p, a, 1L) {
        None => ()
        Some(e) =>
          for alpha in e.two_torsion_x() {
            total = total + 1
            if e.verify_two_isogeny(alpha) {
              ok = ok + 1
            }
          }
      }
    }
  }
  assert_eq(ok, total)
  assert_true(total > 0)
}

///|
test "three-isogeny" {
  // 檢驗 Vélu 3-同源公式：對每個有理 3-扭子群，陪域階須滿足 #{E'} ∈ {#E/3, #E}
  let mut ok = 0
  let mut total = 0
  for p in [13L, 19L, 31L, 37L] {
    for a = 0L; a < 6L; a = a + 1L {
      match @curves.EC::make(p, a, 2L) {
        None => ()
        Some(e) =>
          for r in e.points() {
            match r {
              @curves.EPoint::Inf => ()
              @curves.EPoint::Pt(x, y) =>
                if @curves.is_identity(e.mul(3L, r)) && y <= @core.zmod(-y, p) {
                  total = total + 1
                  if e.verify_three_isogeny(x, y) {
                    ok = ok + 1
                  }
                }
            }
          }
      }
    }
  }
  assert_true(total > 0)
  assert_eq(ok, total)
}
