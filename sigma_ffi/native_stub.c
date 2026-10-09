#include <stdio.h>
#include <stdint.h>

extern int32_t sigma_ffi_ring_lwe(int32_t m0, int32_t m1, int32_t e0);
extern int32_t sigma_ffi_lattice_trapdoor(int32_t b11, int32_t b12, int32_t b22);
extern int32_t sigma_ffi_velu_isogeny(int32_t da, int32_t db);
extern int32_t sigma_ffi_hidden_subgroup_dlog(int32_t x1, int32_t x2);
extern int32_t sigma_ffi_padic_hensel(int32_t r0, int32_t pk);
extern int32_t sigma_ffi_supermatrix_commit(int32_t a, int32_t b, int32_t c, int32_t e);
extern int32_t sigma_ffi_kron_guarded(int32_t a1, int32_t a2);
extern int32_t sigma_ffi_selftest_digest(void);

int main(void) {
  int32_t c1 = sigma_ffi_ring_lwe(1, 0, 1);
  int32_t c2 = sigma_ffi_lattice_trapdoor(2, 1, 3);
  int32_t c3 = sigma_ffi_velu_isogeny(4, 9);
  int32_t c4 = sigma_ffi_hidden_subgroup_dlog(2, 4);
  int32_t c5 = sigma_ffi_padic_hensel(3, 7);
  int32_t c6 = sigma_ffi_supermatrix_commit(3, 2, 5, 4);
  int32_t c7 = sigma_ffi_kron_guarded(2, 3);
  int32_t digest = sigma_ffi_selftest_digest();
  printf(
    "[sigma_ffi Native C ABI Host] ring_lwe=%d trapdoor=%d isogeny=%d dlog=%d hensel=%d super=%d kron=%d digest=%d\n",
    c1, c2, c3, c4, c5, c6, c7, digest
  );
  return (digest == 6551) ? 0 : 1;
}
