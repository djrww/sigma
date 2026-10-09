///|
/// sigma/sigma_test.mbt —— Σ-密碼學領域特定語言 (sigma DSL) 黑箱測試：
/// 檢驗七大政策機制、七大密碼學核心套件，以及對接官方 MoonBit 編譯器之四大方案 (A, B, C, D)。
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
test "sigma/scheme-A-and-B-aot-dev-build-and-formal-gates" {
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
  assert_true(@sigma.aot_transpiled_suite_manifest().contains("sigmac-aot-v2"))
}

///|
test "sigma/scheme-C-and-D-ffi-abi-and-virtual-hal-override" {
  let (hal_name, is_ct, hal_digest, equiv_ok) = @sigma.aot_hal_backend_status()
  // Scheme D: `sigma/moon.pkg` overrides `sigma_hal` with `sigma_hal_ct`!
  assert_eq(hal_name, "sigma-hal-ct-masked-hw")
  assert_eq(is_ct, true)
  // Exact same algebraic digest (1621736) as default `sigma-hal-default-sw`!
  assert_eq(hal_digest, 1621736)
  assert_eq(equiv_ok, true)
  // Scheme C: Integer-ABI cryptographic entrypoints
  assert_eq(@sigma.abi_ring_lwe_ntt(1, 0, 1), 1016)
  assert_eq(@sigma.abi_lattice_trapdoor(2, 1, 3), 553)
  assert_eq(@sigma.abi_velu_isogeny_suite(4, 9), 1600)
  assert_eq(@sigma.abi_hidden_subgroup_dlog(2, 4), 141)
  assert_eq(@sigma.abi_padic_hensel_sl2(3, 7), 1011)
  assert_eq(@sigma.abi_supermatrix_commit(3, 2, 5, 4), 158)
  assert_eq(@sigma.abi_kron_guarded_cipher(2, 3), 1328)
  assert_eq(@sigma.abi_sigma_selftest_digest(), 6551)
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
