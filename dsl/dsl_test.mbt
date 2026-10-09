///|
/// DSL 執行期測試：Σ-演算的求值結果須與核心演算法一致。
test "dsl/core agreement" {
  inspect(@dsl.run("snf([2 4; 6 8])"), content="[2 0; 0 4]")
  inspect(@dsl.run("hom(cyc(6),cyc(9))"), content="Z/3")
  inspect(@dsl.run("lll([1 0; 12 1])"), content="[1 0; 0 1]")
  inspect(@dsl.run("coker(diag(2,4))"), content="Z/2 + Z/4")
  inspect(@dsl.run("tor(cyc(12),cyc(18))"), content="Z/6")
  inspect(
    @dsl.equivalent("ext(cyc(6),cyc(9))", "tor(cyc(6),cyc(9))"),
    content="true",
  )
  inspect(
    @dsl.equivalent("horner(2,3,4,5,6)", "estrin(2,3,4,5,6)"),
    content="true",
  )
  inspect(@dsl.run("bezout(270,192)"), content="true")
  inspect(@dsl.run("cegis()"), content="true")
  inspect(@dsl.run("sigma_suite()"), content="true")
  inspect(@dsl.run("sigma_lwe()"), content="true")
  inspect(@dsl.run("sigma_trapdoor()"), content="true")
  inspect(@dsl.run("sigma_isogeny()"), content="true")
  inspect(@dsl.run("sigma_dlog()"), content="true")
  inspect(@dsl.run("sigma_padic()"), content="true")
  inspect(@dsl.run("sigma_zk()"), content="true")
  inspect(@dsl.run("sigma_kron()"), content="true")
}
