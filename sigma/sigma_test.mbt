///|
/// sigma/sigma_test.mbt —— Σ-密碼學領域特定語言 (sigma DSL) 黑箱測試：
/// 檢驗七大政策機制、七大密碼學核心套件、AOT `dev_build` 轉譯與 `.mbt`/`.mbtp` 雙軌代碼生成。
test "sigma/policies-and-script-execution" {
  let src = @sigma.standard_sigma_script()
  let (cfg, certs) = @sigma.run_sigma_script(src)
  assert_eq(cfg.hadamard_guard, "strict")
  assert_eq(cfg.witness_obligatory, "enforce")
  assert_eq(cfg.complexity_gate, "audit")
  assert_eq(cfg.egraph_opt, "on")
  assert_eq(cfg.cegis_synth, "on")
  assert_eq(cfg.mat2_backend, "auto")
  assert_eq(cfg.constant_time, "canonical")
  assert_eq(certs.length(), 7)
  for c in certs {
    assert_true(c.ok)
  }
}

///|
test "sigma/aot-dev-build-transpiled-suite" {
  assert_eq(@sigma.generated_suite_policies().length(), 7)
  assert_eq(@sigma.generated_suite_ciphers().length(), 7)
  assert_true(@sigma.compiled_ring_lwe_kem().ok)
  assert_true(@sigma.compiled_lattice_gpv_trapdoor().ok)
  assert_true(@sigma.compiled_isogeny_velu_kani().ok)
  assert_true(@sigma.compiled_group_dlog_snf().ok)
  assert_true(@sigma.compiled_padic_sl2_suite().ok)
  assert_true(@sigma.compiled_super_berezinian_zk().ok)
  assert_true(@sigma.compiled_kron_poly_auth().ok)
  assert_true(@sigma.verify_all_compiled_ciphers())
}

///|
test "sigma/self-developed-transpiler-mbt-and-mbtp" {
  let src = @sigma.standard_sigma_script()
  let mbt_code = @sigma.transpile_to_moonbit(src)
  let mbtp_code = @sigma.transpile_to_mbtp(src)
  let report = @sigma.render_sigma_report()
  assert_true(mbt_code.contains("#export_name(\"sigma_ring_lwe_kem\")"))
  assert_true(mbt_code.contains("proof_ensure:"))
  assert_true(mbtp_code.contains("pub predicate sigma_ring_lwe_kem_post"))
  assert_true(mbtp_code.contains("pub lemma sigma_ring_lwe_kem_soundness"))
  assert_true(report.contains("PASS"))
}
