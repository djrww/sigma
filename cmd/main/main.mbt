///|
/// Σ-超矩陣框架的命令列入口。
fn main {
  let args = @env.args()
  let mode = if args.length() > 1 { args[1] } else { "help" }
  if mode == "stats" {
    let es = @corpus.build()
    println(@corpus.stats(es))
    println("check_size(3000) = \{@corpus.check_size(es)}")
  } else if mode == "corpus-md" {
    println(@corpus.render_markdown(@corpus.build()))
  } else if mode == "corpus-csv" {
    println(@corpus.render_csv(@corpus.build()))
  } else if mode == "corpus-json" {
    println(@corpus.render_json(@corpus.build()))
  } else if mode == "dsl" {
    let prog = if args.length() > 2 { args[2] } else { "snf([2 4; 6 8])" }
    println(@dsl.run(prog))
  } else if mode == "synth" {
    println(@synth.render_synth_report())
  } else if mode == "mat2" {
    println(@mat2.render_mat2_report())
  } else if mode == "sigma" {
    println(@sigma.render_sigma_report())
  } else if mode == "transpile" {
    let src = if args.length() > 2 {
      args[2]
    } else {
      @sigma.standard_sigma_script()
    }
    println("// === 1. 生成之 MoonBit 源碼 (.mbt) ===")
    println(@sigma.transpile_to_moonbit(src))
    println("// === 2. 生成之形式化規格 (.mbtp) ===")
    println(@sigma.transpile_to_mbtp(src))
  } else if mode == "proof-audit" {
    println(@corpus.render_proof_audit_report())
  } else if mode == "selftest" {
    println("== Σ-超矩陣 自檢 ==")
    let m = @core.Mat::of_rows([[2L, 4L], [6L, 8L]])
    let (u, d, v) = @core.snf_full(m)
    println(
      "core:  SNF 憑證 = \{@core.verify_snf_full(m, u, d, v)}  D = \{d.diag_text()}",
    )
    println(
      "fga:   Ext≅Tor = \{@fga.verify_ext_eq_tor(@fga.cyclic_group(6L), @fga.cyclic_group(9L))}",
    )
    let b = @core.Mat::of_rows([[1L, 0L], [12L, 1L]])
    let (bp, bu) = @latt.lll_reduce(b)
    println(
      "latt:  LLL 憑證 = \{@latt.verify_lll(b, bp, bu)}  b' = \{bp.to_text()}",
    )
    println(
      "spec:  FFT 往返 = \{@spec.verify_fft_roundtrip([1L, 2L, 3L, 4L], @spec.nth_root(4, @spec.fermat_p()), @spec.fermat_p())}",
    )
    println(
      "curve: Hasse+結構 = \{match @curves.EC::make(19L, 1L, 1L) { None => false; Some(e) => e.verify_hasse() && e.verify_structure() }}",
    )
    println(
      "padic: Hensel = \{@padic.verify_hensel_sqrt(3L, 2L, 7L, 5)}  形式群 = \{@padic.verify_formal_group_axioms(6)}",
    )
    println(
      "dsl:   互通等價 = \{@dsl.equivalent("ext(cyc(6),cyc(9))", "tor(cyc(6),cyc(9))")}",
    )
    println(
      "synth: E-Graph超優化 = \{@synth.verify_superopt(@synth.AlgExpr::Pow2(@synth.AlgExpr::Dual(@synth.AlgExpr::Dual(@synth.AlgExpr::VarA))))}  CEGIS合成 = \{@synth.cegis_synth_karatsuba_im().verified}  Horner≅Estrin = \{@dsl.equivalent("horner(2,3,4,5,6)", "estrin(2,3,4,5,6)")}",
    )
    println(
      "mat2:  Grassmann超行列式 = \{@mat2.compare_berezinian_mat1_vs_mat2(2, 3, 5, 7, 11, 13).0}  多項式SNF分離 = \{@mat2.compare_polymat_vs_mat1(17L).0}  Tropical測地線 = \{@mat2.compare_tropical_geodesic_vs_mat1().0}",
    )
    println(
      "sigma: 密碼學DSL七大套件 = \{@sigma.verify_all_compiled_ciphers()}  AOT預編譯算子數 = \{@sigma.generated_suite_ciphers().length()}",
    )
    let (pv, pt, pd, pu) = @corpus.summary()
    println(
      "proof: 十大套件 VC = \{pv}/\{pv + pt} 已證  帶約束定義 = \{pd}/\{pd + pu} 已證  超時略過定理 = \{@corpus.skipped_timeout_theorems().length()}  組合爆炸略過演算法 = \{@corpus.skipped_exploded_algorithms().length()}",
    )
  } else {
    println("Σ-超矩陣框架（supermatrix）")
    println(
      "模式：stats | corpus-md | corpus-csv | corpus-json | dsl <程式> | synth | mat2 | sigma | transpile | proof-audit | selftest",
    )
  }
}
