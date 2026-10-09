///|
/// sigma_hal/hal_test.mbt —— 方案 D 虛擬套件 (`virtual: { "has-default": true }`) 預設實作測試：
/// 在未加載 `overrides` 的情況下，驗證預設純軟體參考後端 (`"sigma-hal-default-sw"`) 之代數基準值。
test "sigma_hal/default-virtual-backend" {
  assert_eq(@sigma_hal.hal_backend_name(), "sigma-hal-default-sw")
  assert_eq(@sigma_hal.hal_is_constant_time(), false)
  assert_eq(@sigma_hal.hal_ct_select(1, 42, 99), 42)
  assert_eq(@sigma_hal.hal_ct_select(0, 42, 99), 99)
  let (y0, y1) = @sigma_hal.hal_ntt_butterfly(5, 3, 9, 17)
  assert_eq(y0, 15)
  assert_eq(y1, 12)
  assert_eq(@sigma_hal.hal_lwe_blinded_decode(14, 7, 1, 5, 17), 1)
  assert_eq(@sigma_hal.hal_kron_det_2_4(2, 36), 20736)
  assert_eq(@sigma_hal.hal_audit_digest(), 1621736)
}
