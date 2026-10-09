///|
/// sigma/generated_suite.mbt —— 由 `tools/sigmac.py` 透過 `moon.pkg` 之 `dev_build` 自動轉譯生成。
/// 來源檔案：sigma/crypto_suite.sigma（請勿手動修改本檔案）。

///|
/// 由 `.sigma` 頂層 `policy` 宣告轉譯出的安全與優化政策表。
pub fn generated_suite_policies() -> Array[(String, String)] {
  [
    ("hadamard_guard", "strict"),
    ("witness_obligatory", "enforce"),
    ("complexity_gate", "audit"),
    ("egraph_opt", "on"),
    ("cegis_synth", "on"),
    ("mat2_backend", "auto"),
    ("constant_time", "canonical"),
  ]
}

///|
/// 由 `.sigma` 頂層 `cipher` 宣告轉譯出的密碼學套件規格表。
pub fn generated_suite_ciphers() -> Array[(String, String)] {
  [
    ("ring_lwe_kem", "ring_lwe_ntt([3, 1, 4, 1], [1, 0, 1, 0], [0, 1, 0, 0], 17)"),
    ("lattice_gpv_trapdoor", "lattice_trapdoor([[2, 1], [1, 3]], [5, 7], 2)"),
    ("isogeny_velu_kani", "velu_isogeny_suite(19, 1, 1, 3, 5)"),
    ("group_dlog_snf", "hidden_subgroup_dlog([[6, 0], [0, 15]], 14, 9)"),
    ("padic_sl2_suite", "padic_hensel_sl2(3, 2, 7, 4)"),
    ("super_berezinian_zk", "supermatrix_commit(3, 2, 5, 4, 1, 7)"),
    ("kron_poly_auth", "kron_guarded_cipher(17)"),
  ]
}

///|
/// AOT 轉譯生成之密碼學算子入口：`ring_lwe_kem`。
pub fn compiled_ring_lwe_kem() -> SigmaCert {
  eval_cipher_spec("ring_lwe_kem", "ring_lwe_ntt([3, 1, 4, 1], [1, 0, 1, 0], [0, 1, 0, 0], 17)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`lattice_gpv_trapdoor`。
pub fn compiled_lattice_gpv_trapdoor() -> SigmaCert {
  eval_cipher_spec("lattice_gpv_trapdoor", "lattice_trapdoor([[2, 1], [1, 3]], [5, 7], 2)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`isogeny_velu_kani`。
pub fn compiled_isogeny_velu_kani() -> SigmaCert {
  eval_cipher_spec("isogeny_velu_kani", "velu_isogeny_suite(19, 1, 1, 3, 5)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`group_dlog_snf`。
pub fn compiled_group_dlog_snf() -> SigmaCert {
  eval_cipher_spec("group_dlog_snf", "hidden_subgroup_dlog([[6, 0], [0, 15]], 14, 9)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`padic_sl2_suite`。
pub fn compiled_padic_sl2_suite() -> SigmaCert {
  eval_cipher_spec("padic_sl2_suite", "padic_hensel_sl2(3, 2, 7, 4)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`super_berezinian_zk`。
pub fn compiled_super_berezinian_zk() -> SigmaCert {
  eval_cipher_spec("super_berezinian_zk", "supermatrix_commit(3, 2, 5, 4, 1, 7)", default_policy_config())
}

///|
/// AOT 轉譯生成之密碼學算子入口：`kron_poly_auth`。
pub fn compiled_kron_poly_auth() -> SigmaCert {
  eval_cipher_spec("kron_poly_auth", "kron_guarded_cipher(17)", default_policy_config())
}

///|
/// 一鍵驗證 `sigma/crypto_suite.sigma` 轉譯出的全部密碼學套件與義務自證憑證。
pub fn verify_all_compiled_ciphers() -> Bool {
  compiled_ring_lwe_kem().ok &&
  compiled_lattice_gpv_trapdoor().ok &&
  compiled_isogeny_velu_kani().ok &&
  compiled_group_dlog_snf().ok &&
  compiled_padic_sl2_suite().ok &&
  compiled_super_berezinian_zk().ok &&
  compiled_kron_poly_auth().ok
}
