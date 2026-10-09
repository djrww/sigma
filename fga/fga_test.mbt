///|
/// 有限生成阿貝爾群：結構定理與雙對偶/Ext-Tor 的執行期見證。
test "fga/structure and duality" {
  inspect(@fga.cyclic_group(12L).invariants()[0], content="12")
  inspect(
    @fga.product_group(@fga.cyclic_group(4L), @fga.cyclic_group(6L)).to_text(),
    content="Z/2 + Z/12",
  )
  inspect(@fga.elementary_abelian(3L, 2).to_text(), content="Z/3 + Z/3")
  inspect(@fga.cyclic_group(9L).is_p_group(3L), content="true")
  inspect(@fga.order_statistics(@fga.cyclic_group(6L)).length(), content="4")
  inspect(
    @fga.isomorphic_by_statistics(
      @fga.cyclic_group(100L),
      @fga.product_group(@fga.cyclic_group(4L), @fga.cyclic_group(25L)),
    ),
    content="true",
  )
  inspect(
    @fga.verify_partition_agreement(
      @fga.product_group(@fga.cyclic_group(4L), @fga.cyclic_group(4L)),
      2L,
    ),
    content="true",
  )
  inspect(
    @fga.verify_ext_eq_tor(@fga.cyclic_group(6L), @fga.cyclic_group(9L)),
    content="true",
  )
  inspect(@fga.p_primary(@fga.cyclic_group(12L), 2L).to_text(), content="Z/4")
  inspect(
    @fga.p_primary_decomposition(@fga.cyclic_group(12L)).length(),
    content="2",
  )
  assert_true(@fga.order_histogram(@fga.cyclic_group(6L)).length() > 0)
  assert_true(@fga.structure_diagram(@fga.cyclic_group(6L)).length() > 0)
}
