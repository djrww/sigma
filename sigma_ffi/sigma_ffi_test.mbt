///|
/// sigma_ffi/sigma_ffi_test.mbt —— 方案 C 多後端 FFI 外語庫 (`foreign_library`) 測試：
/// 驗證 `#export_name("sigma_ffi_*")` 導出之八大密碼學整數 ABI 入口在
/// `wasm-gc`、`wasm`、`js` 與 `native` 四大後端上的一致性。
test "sigma_ffi/multi-backend-exported-abi" {
  assert_eq(@sigma_ffi.ffi_ring_lwe_ntt(1, 0, 1), 1016)
  assert_eq(@sigma_ffi.ffi_lattice_trapdoor(2, 1, 3), 553)
  assert_eq(@sigma_ffi.ffi_velu_isogeny_suite(4, 9), 1600)
  assert_eq(@sigma_ffi.ffi_hidden_subgroup_dlog(2, 4), 141)
  assert_eq(@sigma_ffi.ffi_padic_hensel_sl2(3, 7), 1011)
  assert_eq(@sigma_ffi.ffi_supermatrix_commit(3, 2, 5, 4), 158)
  assert_eq(@sigma_ffi.ffi_kron_guarded_cipher(2, 3), 1328)
  assert_eq(@sigma_ffi.ffi_sigma_selftest_digest(), 6551)
}
