///|
/// corpus/proof_ledger.mbt —— 由 tools/sync_proof.py 自動生成（勿手改）。
/// 來源：_build/verif/proof/**/*.proof.json（`moon prove` 的結構化報告）。

///|
/// 已被 Why3 + z3/cvc5 消解的帶約束定義（SMT 機器證明，G1）。
pub fn proved_goals() -> Array[(String, String)] {
  [
    ("abs_verified", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("abs_nonneg", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("min2", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("max2", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("countdown", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("positive_mod", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("triangular", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("isqrt", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("isqrt_loop", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("fib_step", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("factorial", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("gcd_verified", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("gcd_euclid_loop", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("is_prime_trial", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("pow_mod", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("pow_mod_loop", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("det2", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("trace2", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("cayley_hamilton_2x2", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("det2_mul", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("isqrt_rec", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("isqrt_full", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("pow_mod_rec", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("measure_isqrt", "proof/fn｜Why3+z3 全部驗證條件消解"),
    ("divisor_le", "proof/lemma｜Why3+z3 全部驗證條件消解"),
    ("fwd_bridge", "proof/lemma｜Why3+z3 全部驗證條件消解"),
    ("step_b_wit", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    ("step_rem_wit", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    ("step_a_wit", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    ("step_mul_mod", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    ("dvd_mod_back", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    (
      "ec_hasse_trace_order_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "ec_quadratic_twist_sum_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "velu_two_isogeny_coeff_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "velu_three_isogeny_coeff_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "tate_frobenius_cayley_hamilton_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "teichmuller_newton_step_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "formal_group_mult_axioms_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "formal_log_deg2_grouplaw_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "sl2_zpn_order_skeleton_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "so3_discrete_orthogonality_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "padic_ultrametric_witness_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "abelian_variety_kani_genus_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "dsl_canonical_equivalence_synth", "curves_padic/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("snf_diag_gcd_lcm_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    (
      "snf_bilateral_cert2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("elem_row_add_det2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    ("elem_col_add_det2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    (
      "elem_row_swap_det2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("unimodular_inv2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    ("hnf_upper_det2_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    (
      "rank_nullity_structure_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "hom_ext_tor_tensor_cyclic_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "pontryagin_bidual_invariants_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "lagrange_quotient_order_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "p_torsion_exponent_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "elementary_abelian_p_group_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "crt_isomorphism_recon_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("frac_ring_laws_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    (
      "integer_linear_solve_cert_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("bareiss3_det_synth", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    ("gram2_sym_nonneg_synth", "latt/fn｜Why3+z3 全部驗證條件消解"),
    (
      "gram2_covolume_lagrange_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("lll_shear2_reduce_synth", "latt/fn｜Why3+z3 全部驗證條件消解"),
    (
      "lll_unit_lower3_reduce_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "lll_size_reduce_step2_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "dual_lattice2_biorthogonal_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("dual_lower_tri2_det_synth", "latt/fn｜Why3+z3 全部驗證條件消解"),
    (
      "svp_lll_hermite_bound2_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("cvp_diag2_distance_synth", "latt/fn｜Why3+z3 全部驗證條件消解"),
    (
      "parallelogram_norm_law2_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "unimodular_gram_det_invariance_synth", "latt/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("grassmann_even_mul_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    ("grassmann_odd_wedge_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    (
      "ber_grassmann_multiplicative_synth", "mat2/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "ber_commutative_defect_synth", "mat2/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("kronecker_trace2_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    ("kronecker_det_diag2_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    (
      "poly_pencil_separation_synth", "mat2/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("tropical_assoc_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    ("tropical_distrib_synth", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    (
      "tropical_det2_valuation_synth", "mat2/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "displacement_circulant2_synth", "mat2/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("dft4_roundtrip_synth", "spec/fn｜Why3+z3 全部驗證條件消解"),
    ("convolution_theorem2_synth", "spec/fn｜Why3+z3 全部驗證條件消解"),
    (
      "circulant_eigen_diag2_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "adjoint_inner_product2_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "adjoint_inner_product3_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "symplectic_block_shear_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "symplectic_j_involution_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "supertrace_even_commutator_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "supertrace_odd_anticommutator_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "berezinian_block_triangular_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "polarization_quadratic2_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    (
      "polarization_cubic_incexcl_synth", "spec/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("horner3_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("gauss_karatsuba_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("ch_power2_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("adjugate_solve_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("bezout_step_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("quarter_square_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("butterfly_roundtrip_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("butterfly_transform_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    (
      "brahmagupta_fibonacci_synth", "synth/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("euclid_div_mod_repaired", "synth/fn｜Why3+z3 全部驗證條件消解"),
    (
      "symplectic_self_pairing_synth", "synth/fn｜Why3+z3 全部驗證條件消解",
    ),
    ("circulant2_fft_diag_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("symplectic_inv_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("transpose_mul2_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("trace_cyclic2_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("rosati_kani_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("hensel_sqrt_step_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("bidual2_involution_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("estrin3_synth", "synth/fn｜Why3+z3 全部驗證條件消解"),
    ("abs_logic", "algebra/fn｜Why3+z3 全部驗證條件消解"),
    ("mod_add", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("mod_mul", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_trans_witness", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_add_witness", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_sub_witness", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("lin_congr_witness", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("even_double", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("abs_mul", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_div_exact", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("snf_chain", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("mod_range", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("zero_unique", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("polarization_scalar", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("ch2_11", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("ch2_22", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("det2_mul_lemma", "algebra/lemma｜Why3+z3 全部驗證條件消解"),
    ("m1", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("m2", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("m3", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("m4", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("wmod", "bridge/fn｜Why3+z3 全部驗證條件消解"),
    ("fwd_split", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_mod_step_w", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_mod_back_w", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("dvd_mod_step", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("m2r", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    ("m3r", "bridge/lemma｜Why3+z3 全部驗證條件消解"),
    (
      "lemma_formal_mult_assoc", "curves_padic/lemma｜Why3+z3 全部驗證條件消解",
    ),
    (
      "lemma_twist_legendre_cancel", "curves_padic/lemma｜Why3+z3 全部驗證條件消解",
    ),
    ("imin", "fga_snf/fn｜Why3+z3 全部驗證條件消解"),
    (
      "lemma_snf_gcd_lcm_prod", "fga_snf/lemma｜Why3+z3 全部驗證條件消解",
    ),
    ("lemma_crt_congruence", "fga_snf/lemma｜Why3+z3 全部驗證條件消解"),
    (
      "lemma_lagrange_2d_identity", "latt/lemma｜Why3+z3 全部驗證條件消解",
    ),
    (
      "lemma_parallelogram_scalar", "latt/lemma｜Why3+z3 全部驗證條件消解",
    ),
    ("tmin", "mat2/fn｜Why3+z3 全部驗證條件消解"),
    (
      "lemma_cubic_polarization_scalar", "spec/lemma｜Why3+z3 全部驗證條件消解",
    ),
    (
      "lemma_supercommutator_odd_trace", "spec/lemma｜Why3+z3 全部驗證條件消解",
    ),
    ("lemma_circulant_comm", "synth/lemma｜Why3+z3 全部驗證條件消解"),
    ("lemma_horner_step", "synth/lemma｜Why3+z3 全部驗證條件消解"),
    ("lemma_kani_det", "synth/lemma｜Why3+z3 全部驗證條件消解"),
  ]
}

///|
/// 活動套件中未決者（G2）：目前為 0。
pub fn unproved_goals() -> Array[(String, String)] {
  []
}

///|
/// 實測觸發 SMT 超時而略過並記錄之定理清單（G3）。
pub fn skipped_timeout_theorems() -> Array[(String, String, String, String)] {
  [
    (
      "T-TO-01: hnf_upper_det2_implicit_groebner", "族A1/H7｜11 變數 HNF 隱式 Gröbner 消去（無副對角橋接項 h12·h21）",
      "u11*u22-u12*u21=1 ∧ u21*a11+u22*a21=0 ⟹ a11*a22-a12*a21 = h11*h22", "Z3 5.1.0: Timeout (2.0s) / CVC5 1.4.2: Timeout (2.0s)｜已略過原式，改以顯式副對角橋接於 proof/fga_snf::hnf_upper_det2_synth 證明",
    ),
    (
      "T-TO-02: crt_direct_mod_mn", "族B1/H6｜中國剩餘定理直接模乘積 % (m*n) 唯一性定理（無顯式商見證）",
      "gcd(m,n)=1 ∧ x%m=y%m ∧ x%n=y%n ⟹ x%(m*n) = y%(m*n)", "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（符號乘積模數非線性取餘 NIA 不可判定）｜已略過原式，改以 Bézout 餘因子見證於 proof/fga_snf::crt_isomorphism_recon_synth 證明",
    ),
    (
      "T-TO-03: bezout_signed_mod_div", "族A1/I1｜一般有號係數 Bézout 線性組合 (a*u + b*v) % d == 0 直接取餘定理",
      "a>0 ∧ b>0 ∧ d>0 ∧ a%d=0 ∧ b%d=0 ⟹ ∀u,v∈Z, (a*u+b*v)%d = 0",
      "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（截斷除法 ComputerDivision 跨零正負號分支爆炸）｜已略過原式，改以顯式商見證於 proof/algebra::dvd_add_witness 與 proof/synth::bezout_step_synth 證明",
    ),
    (
      "T-TO-04: euclid_mod_back_unskolemized", "族G1/I8｜歐幾里得單步取餘逆推無 Skolem 見證直接引理",
      "a>=0 ∧ b>0 ∧ d>0 ∧ b%d=0 ∧ (a%b)%d=0 ⟹ a%d = 0", "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（E-matching 無法自動合成複合見證項 k2*(a/b)+kr）｜已略過無見證直接式，改以 Proof-by-Call 四步構造鏈於 proof/bridge::dvd_mod_back 證明",
    ),
    (
      "T-TO-05: velu_rational_map_mod_p", "族E3/H1｜有限域 F_p 上 Vélu 2-同源有理映射與模逆元 inv_dx 直接 % p 同餘定理",
      "((x-α)*inv_dx)%p=1 ∧ (α³+aα+b)%p=0 ⟹ φ_Vélu(x) 有理分式與多項式展開模 p 同餘",
      "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（5 階非線性多項式耦合符號質數模取餘與模逆元）｜已略過 % p 有理式，改於多項式環證得 proof/curves_padic::velu_two_isogeny_coeff_synth",
    ),
    (
      "T-TO-06: ntt4_butterfly_mod_p", "族D1/H9｜有限域 F_p 上 4 點 NTT 本原根 w² ≡ -1 (mod p) 逐線 % p 蝶形反演定理",
      "(w*w+1)%p=0 ⟹ (((x1+w*x3)%p)*((1-w)%p) + ((x1-w*x3)%p)*((1+w)%p))%p = (2*(x1+x3))%p",
      "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（多層巢狀 % p 商變數膨脹與非線性理想 w²+1）｜已略過逐線 % p 式，改於商環 Z[ω]/(ω²+1) 證得 proof/spec::dft4_roundtrip_synth",
    ),
    (
      "T-TO-07: ultrametric_direct_mod_pk", "族E6/H10｜p-進超度量不等式在雙層符號模數 pk % p == 0 下之直接 % pk 與 % p 傳遞定理",
      "pk%p=0 ∧ a%pk=0 ∧ b%pk=0 ∧ a+b!=0 ⟹ (a+b)%pk=0 ∧ (a+b)%p=0", "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（雙層符號模數鏈式非線性整除分裂）｜已略過直接模鏈式，改以賦值見證於 proof/curves_padic::padic_ultrametric_witness_synth 證明",
    ),
    (
      "T-TO-08: twist_euler_mod_p", "族E2｜有限域二次扭轉之非平方剩餘全稱量詞 ∀y, (y² - rhs) % p != 0 定理",
      "p%4=3 ∧ (d²-1)%p=0 ∧ d%p!=1 ⟹ (∀y, (y²-rhs)%p!=0) → (∀z, (z²-d²*rhs)%p!=0)",
      "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（全稱量詞交替非線性二次剩餘模 p）｜已略過量詞模 p 式，改證 Legendre 符號消去核 proof/curves_padic::ec_quadratic_twist_sum_synth",
    ),
    (
      "T-TO-09: hensel_lift_direct_mod", "族E5/I7｜Hensel 平方根二次提升直接 % (pk * pk) 模平方取餘定理",
      "((x0²-c)+2*x0*t*pk)%(pk*pk)=0 ⟹ ((x0+t*pk)²-c)%(pk*pk)=0", "Z3 5.1.0: Timeout / CVC5 1.4.2: Timeout（平方模數 pk*pk 與 4 階展開項之非線性取餘）｜已略過直接模平方式，改以餘因子見證合成於 proof/synth::hensel_sqrt_step_synth 證明",
    ),
  ]
}

///|
/// 採取各種減複雜度措施後仍組合爆炸而略過並記錄之演算法清單（G4）。
pub fn skipped_exploded_algorithms() -> Array[(String, String, String, String)] {
  [
    (
      "ALG-CE-01: core::snf_full / core::hnf_full", "core/snf.mbt｜任意 m×n 稠密整數矩陣之雙迴圈交替歐幾里得行列消去與非整除修補演算法",
      "已採取措施：R1(分離雙邊憑證 UAV=D)、R2(降為 2×2 純量元組)、R3(拆解單步行列倍加與交換)、展開 8 步有界迴圈",
      "實測 CVC5: Unknown (incomplete) / Z3: Timeout（每步 3 分支 × 整數除法 q=m21/m11 × 4 階行列式平方不變式致路徑組合爆炸）｜已略過完整迴圈，改證單步與雙邊憑證核 proof/fga_snf::snf_diag_gcd_lcm_synth",
    ),
    (
      "ALG-CE-02: core::Mat::det (Bareiss n>=4 Loop)", "core/det.mbt｜n>=4 稠密矩陣之 Bareiss 無分數高斯消去三重迴圈演算法",
      "已採取措施：R2(展開為無迴圈純量 SSA：n=2, n=3, n=4)、R5(第二代 KronBlockMat 階層張量樹分解)",
      "n=2 與 n=3 (bareiss3_det_synth) 成功秒證；惟 n>=4 (16 變數、5 次巢狀整除、8 階 Sylvester 多項式) 實測 CVC5/Z3 雙雙 Timeout｜已略過 n>=4 稠密 Bareiss，改證 n=3 核與 KronBlockMat 樹分解",
    ),
    (
      "ALG-CE-03: latt::lll_reduce / latt::gram_schmidt", "latt/latt.mbt｜一般 n 維格之有理數 Gram–Schmidt 正交化與 Lovász 條件交換迴圈演算法",
      "已採取措施：R1(分離 verify_lll 憑證)、R2(降為 2D/3D 整數基)、R3(單步尺寸約化 lll_size_reduce_step2_synth)、展開 8 步 2D 交換迴圈",
      "2D 完整迴圈含 q=dot/n1 非線性截斷與 n2<n1 交換分支，分裂出 9 個 VC 中 3 個後置條件 CVC5/Z3 Timeout｜已略過完整 Lovász 迴圈，改證 2D/3D 么模約化核與尺寸約化單步不變式",
    ),
    (
      "ALG-CE-04: latt::svp_box / latt::cvp_box", "latt/latt.mbt｜格上最短向量 SVP 與最近向量 CVP 之指數級係數盒 [-K,K]^n 窮舉搜尋演算法",
      "已採取措施：R2(固定 2D 對角格)、R6(熱帶賦值與 LLL Hermite 下界鬆弛 ‖b1‖² <= 2^{n-1}λ1²)",
      "完整迴圈需走訪 (2K+1)^n 格點並對動態進位解碼維護全稱極小值不變式 ∀c∈[-K,K]^n，狀態空間隨 n 指數爆炸｜已略過盒窮舉迴圈，改證 Hermite 界與 CVP 距離對稱非負核",
    ),
    (
      "ALG-CE-05: fga::all_subgroups / fga::subgroup_lattice", "fga/enum.mbt｜有限生成阿貝爾群之元素笛卡兒積窮舉、子群生成閉包 BFS 不動點與 Hasse 覆蓋圖演算法",
      "已採取措施：R1(分離 Lagrange 階整除驗證)、R2(限制小階群)、代數不變因子分解",
      "subgroup_closure 需在動態集合上做群加法不動點飽和，subgroup_lattice 需 O(|S|³·|G|) 三重迴圈檢驗覆蓋關係，WP 集合量詞爆炸｜已略過子群枚舉迴圈，改證 Lagrange 商群整除與 Hom/Ext/Tor/Dual 定理",
    ),
    (
      "ALG-CE-06: spec::fft / spec::ifft (General Radix-2 N=2^k)", "spec/ops.mbt｜任意 N=2^k 長度有限域 Cooley–Tukey 遞迴奇偶分治快速傅立葉變換演算法",
      "已採取措施：R2(展開 N=2 與 N=4 蝶形網絡)、R5(DispCircMat 位移秩生成元壓縮)、代數商環化",
      "一般 N=2^k 遞迴動態配置 even/odd 子陣列並耦合本原根冪次 w^k mod p，二階結構歸納與幾何級數正交和在 SMT 中組合爆炸｜已略過任意 2^k 遞迴陣列版，改證 N=2,4 蝶形往返與 Parseval 核",
    ),
    (
      "ALG-CE-07: curves::EC::points / group_structure / sl2_order_bruteforce", "curves/ec.mbt & padic/padic.mbt｜有限域橢圓曲線 O(p²) 點群窮舉、雙生成元搜尋與 SL₂(Z/p^n) O(p^{4n}) 四重窮舉演算法",
      "已採取措施：R1(提取 Hasse 界與 Frobenius 跡同餘規格)、以閉式公式 p^{3n-2}(p²-1) 替代 p=5,n>=3 窮舉",
      "點群窮舉需對 ∀x,y∈[0,p) 掃描三次曲線解空間，SL₂ 窮舉在 p=5,n=3 已達 1.56×10^8 狀態｜已略過暴力枚舉迴圈，改證 Hasse 跡階定理、二次扭轉和與 SL₂ 李代數核遞推定理",
    ),
    (
      "ALG-CE-08: padic::Series::compose / padic::lift_to_ternary", "padic/padic.mbt & padic/fgpoly.mbt｜任意截斷階數 D 之形式冪級數複合與三元多項式 F(F(X,Y),Z) 展開演算法",
      "已採取措施：R2(提取乘法形式群律 X+Y+XY 精確三元結合律與形式對數二階同態核)",
      "lift_to_ternary 在截斷階數 D 下產生 C(D+3,3) 個稀疏單項式並執行 O(D^6) 巢狀卷積，陣列索引與單項式合併迴圈在 WP 中爆炸｜已略過任意階稀疏多項式迴圈，改證形式群三公理與二階形式對數同態",
    ),
    (
      "ALG-CE-09: mat2::poly_pencil_snf2 / mat2::PolyFp::div_mod", "mat2/mat2.mbt｜有限域多項式環 F_p[x] 帶模逆元歸一化之長除法、擴展歐幾里得與 λ-矩陣雙邊 SNF 消去演算法",
      "已採取措施：R2(提取 2×2 特徵鉛筆 xI-A 之跡與判別式分離定理 poly_pencil_separation_synth)",
      "多項式長除法迴圈每步依最高次項係數呼叫 invmod(lead, p) 並動態縮減次數 deg(r)，耦合模 p 逆元與多項式次數良基歸納致組合爆炸｜已略過一般次數多項式消去迴圈，改證特徵鉛筆判別式分離定理",
    ),
    (
      "ALG-CE-10: synth::superoptimize / cegis_synth_* / dsl::eval", "synth/synth.mbt & dsl/dsl.mbt｜代數 AST 等式飽和重寫不動點迴圈、CEGIS 候選空間搜尋與遞迴下降語法剖析器",
      "已採取措施：R1/R3(將 E-Graph 每條重寫規則、CEGIS 合成結果與 DSL 規範形等價律逐一拆出為獨立算子)",
      "對遞迴代數資料型別 (AlgExpr/Expr) 執行不動點飽和迴圈與字串剖析會產生互遞迴結構歸納與無界樹深 VC｜已略過元層搜尋與剖析器迴圈，改於 proof/synth(22 VC) 與 proof/curves_padic 100% 證明所有重寫規則與合成算子",
    ),
  ]
}

///|
/// 總結：(已證 VC 數, 未決 VC 數, 已證定義數, 未決定義數)。
pub fn summary() -> (Int, Int, Int, Int) {
  (150, 0, 155, 0)
}
