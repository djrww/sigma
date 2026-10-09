# Σ-密碼學領域特定語言（`sigma` Crypto DSL）：架構設計、七大密碼學演算法應用、底層政策內嵌與自研轉譯器對接官方編譯器專論

> **專案里程碑與驗證指標**：
> - **語言與工具鏈**：MoonBit 最新穩定版 `moon 0.1.20260920` / `moonc v0.10.14` + `Why3 1.7.2` + `Z3 5.1.0` + `CVC5 1.4.2`
> - **套件規模**：**21 個套件**（11 個執行期套件含全新 `sigma/` + 10 個形式化驗證套件含全新 `proof/sigma/` + CLI `cmd/main`）
> - **語料庫與自證規模**：**3860 / 3860 條機器見證 100.00% 通過**（新增語料族 `L1`–`L4` 共 80 條 `sigma` 密碼學 DSL 見證 + `G1` 新增 9 條 `proof/sigma` 形式化定理）
> - **十大形式化證明套件**：**159 / 159 個驗證條件（VC）100% 機器消解（0 未決）**；**164 / 164 個帶約束定義已證**
> - **執行期單元測試**：**48 / 48 測試 100% 通過（0 警告、0 錯誤）**

---

## 一、架構總覽：如何把高階代數抽象、高效演算法與安全政策「嵌進 `sigma` DSL 底層」並徹底分離運算邏輯

傳統密碼學實作常將「安全政策檢查（如防溢位、常數時間代表元）」、「矩陣與多項式底層資料結構選擇」、「核心數學演算法（SNF/HNF/LLL/NTT/Vélu/Hensel）」與「高階密碼協定邏輯」混寫在同一層代碼中，導致難以審計且極易引入實作漏洞。

本階段在 `/home/user/supermatrix/sigma/` 與 `/home/user/supermatrix/proof/sigma/` 中設計並實作了 **`sigma` 密碼學領域特定語言（Sigma Cryptographic DSL）**，採用**四層嚴格解耦架構（Four-Layer Separation of Concerns）**：

```text
┌────────────────────────────────────────────────────────────────────────────┐
│ 第一層：宣告式協定與政策表層（Surface Syntax: `sigma/crypto_suite.sigma`）   │
│   * 僅宣告安全政策：`policy hadamard_guard = strict;`                       │
│   * 僅組合密碼原語：`cipher ring_lwe_kem = ring_lwe_ntt(...);`              │
│   * 完全不含迴圈、矩陣索引、模數歸約或記憶體配置細節                        │
└─────────────────────────────────────┬──────────────────────────────────────┘
                                      │ 解析與政策綁定 (`run_sigma_script`)
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│ 第二層：政策守衛、矩陣選型與代數超優化中間層（Policy & Optimizer Engine）    │
│   1. `hadamard_guard`   ：64-bit Bareiss 溢位攔截，自動轉向 KronBlockMat    │
│   2. `witness_obligatory`：強制每個密碼步驟產出可獨立檢核之 SigmaCert       │
│   3. `complexity_gate`  ：七大減複雜度措施與 G3/G4 超時／爆炸審計閘門       │
│   4. `egraph_opt`       ：E-Graph 等價飽和（Horner↔Estrin、CH 降階）        │
│   5. `cegis_synth`      ：CEGIS 合成（Karatsuba、四分之一平方、Bézout）     │
│   6. `mat2_backend`     ：Mat1 稠密矩陣 vs Mat2 五大結構化矩陣自動路由      │
│   7. `constant_time`    ：標準代表元 [0,q) 與無除法伴隨算子                 │
└──────────────────┬──────────────────────────────────────┬──────────────────┘
                   │ 執行期委派                            │ 雙軌代碼生成
                   ▼                                      ▼
┌──────────────────────────────────────┐ ┌───────────────────────────────────┐
│ 第三層：密碼學執行核與形式化證明核    │ │ 第四層：自研雙軌轉譯器與官方編譯  │
│ (`sigma/sigma.mbt` + `proof/sigma`)  │ │ (`tools/sigmac.py` + `transpile`) │
│ * 調度 core/fga/latt/spec/curves/    │ │ * AOT：`moon.pkg` `rule/dev_build`│
│   padic/synth/mat2 八大數學引擎      │ │   自動生成 `generated_suite.mbt`  │
│ * 對接十大 `proof/*` 套件（159 VC）  │ │ * 雙軌輸出：`.mbt` + `.mbtp`      │
└──────────────────────────────────────┘ └───────────────────────────────────┘
```

---

## 二、密碼學如何應用本專案強大而複雜的演算法（七大密碼學核心套件）

`sigma` DSL 將本專案原本分散於八個領域套件的複雜演算法，封裝為**七個開箱即用、自帶數學見證（`SigmaCert`）與 SMT 形式化規格（`proof/sigma`）的密碼學語言原語**：

| `sigma` 原語名稱 | 專攻密碼學領域 | 嵌入之專案底層演算法與結構 | 解決之核心密碼學問題與實測見證 |
|---|---|---|---|
| **1. `ring_lwe_ntt`** | **後量子格密碼**（Ring-LWE / ML-KEM / Kyber 多項式環密鑰封裝） | `@spec.fft`、`@spec.ifft`、`@spec.verify_circulant_diagonalization`、`@mat2.DispCircMat`、`@pspec.dft4_roundtrip_synth`、`@psigma.ring_lwe_sym_enc_dec_synth` | 在分圓環 $R_q = \mathbb{F}_q[X]/(X^N-1)$ 上以 $O(N \log N)$ 雙向 NTT 計算 $b(X) = a(X)s(X) + e(X)$；透過 `mat2::DispCircMat` 將公鑰循環矩陣由 $O(N^2)$ 壓縮為 $O(N)$ 首列生成元，並以 E-Graph 將多項式求值由 Horner 串列式轉為 Estrin $O(\log d)$ 平行樹。 |
| **2. `lattice_trapdoor`** | **格密碼公鑰壓縮與陷門簽章**（Micciancio HNF 公鑰、GPV 對偶格陷門、LLL/SVP/CVP） | `@core.hnf_full`、`@latt.lll_reduce`、`@latt.dual_basis`、`@latt.svp_box`、`@latt.cvp_box`、`@platt.lll_shear2_reduce_synth`、`@psigma.micciancio_hnf_trapdoor_indist_synth` | 以私鑰短基 $B_{\text{priv}}$ 的 Hermite 正規形 $H_{\text{pub}} = U \cdot B_{\text{priv}}$ 作為標準公鑰（么模矩陣 $U$ 隱藏短基幾何）；接收端利用精確有理數 LLL 約化與 GPV 對偶格雙正交陷門 $\langle B, B^*\rangle = I$ 解碼 CVP 含噪密文向量。 |
| **3. `velu_isogeny_suite`** | **後量子同源密碼與橢圓曲線密碼**（Vélu 2-/3-同源 CGL 雜湊、二次扭轉防禦、Tate 配對、SQIsign2D Kani 鑽石） | `@curves.EC`（`isogenous_by_2`、`isogenous_by_3`、`verify_twist`、`tate_skeleton`）、`@mat2.TropicalMat`、`@psynth.rosati_kani_synth`、`@psigma.velu_kani_2d_diamond_norm_synth` | 強制檢驗 Hasse 界與二次扭轉恆等式 $\#E(\mathbb{F}_p) + \#E'(\mathbb{F}_p) = 2p+2$ 以抵禦無效曲線與扭轉攻擊；以 `mat2::TropicalMat` min-plus 半環計算同源圖最短測地線路由；並內嵌 Kani $2\times 2$ 塊反對角同源鑽石核 $F^\dagger F = (\deg \alpha + \deg \beta)I_2$（支撐 2024–2026 前沿 SQIsign2D 後量子簽章）。 |
| **4. `hidden_subgroup_dlog`** | **阿貝爾群離散對數約化與同調承諾**（SNF 關係約化、Pohlig–Hellman、CRT 私鑰重組、Ext/Tor 對偶） | `@core.snf_full`、`@fga.group_from_relations`、`@fga.p_primary_decomposition`、`@synth.synth_bezout_cert`、`@pfga.crt_isomorphism_recon_synth`、`@psigma.pohlig_hellman_crt_dlog_synth` | 將任意多生成元關係矩陣公鑰 $\mathbb{Z}^n / A\mathbb{Z}^m$ 經雙邊么模 Smith 正規形 $UAV = D$ 對角化為循環不變因子鏈，再分解為 $p$-Sylow 主成分執行 Pohlig–Hellman 降維，最後以合成之 Bézout 憑證執行無量詞 CRT 私鑰重組。 |
| **5. `padic_hensel_sl2`** | **$p$-進密鑰提升、異常曲線防禦與非交換擴展圖雜湊**（Hensel 牛頓提升、形式對數、$\operatorname{SL}_2(\mathbb{Z}/p^n)$） | `@padic.hensel_lift_sqrt`、`@padic.teichmuller`、`@padic.verify_formal_log_grouplaw`、`@padic.sl2_order_formula`、`@mat2.verify_tropical_padic_newton_bound`、`@psigma.padic_hensel_key_lift_synth` | 利用牛頓–Hensel 二次收斂（$p^k \to p^{2k}$）在 $O(\log n)$ 步內將模 $p$ 初值提升為模 $p^n$ 多精度密鑰；透過形式對數同構 $L(F_m(X,Y)) = L(X)+L(Y)$ 審計形式群線性化風險；並驗證非交換 Cayley 擴展圖雜湊空間 $|\operatorname{SL}_2(\mathbb{Z}/p^n)| = p^{3n-2}(p^2-1)$。 |
| **6. `supermatrix_commit`** | **非交換超矩陣同態承諾與零知識遮罩**（Grassmann Berezinian、超跡消沒、辛極化配對） | `@mat2.GrassmannSuperMat`、`@spec.verify_supertrace_vanishes`、`@spec.verify_symplectic`、`@pspec.polarization_cubic_incexcl_synth`、`@psigma.grassmann_berezinian_zk_commit_synth` | 在反交換奇元 $\theta_1\theta_2 = -\theta_2\theta_1$ 上構造嚴格滿足同態乘法性 $\operatorname{Ber}(MN) = \operatorname{Ber}(M)\operatorname{Ber}(N)$ 的超矩陣承諾（消除第一代交換環矩陣 `-2acef` 的同態洩漏缺陷）；並利用超交換子超跡恆等消沒 $\operatorname{str}([M,N]) = 0$ 構造零知識恆零盲化遮罩。 |
| **7. `kron_guarded_cipher`** | **高維張量擴散層與代數防偽指紋**（Kronecker 溢位免疫 MDS 擴散、$\mathbb{F}_p[x]$ 鉛筆不變因子認證） | `@mat2.KronBlockMat`、`@mat2.verify_kron_avoids_bareiss_overflow`、`@mat2.compare_polymat_vs_mat1`、`@psigma.hadamard_guard_kron_route_synth` | 當高維區塊密碼擴散層採用 $A \otimes B \otimes C$（$8\times 8$）時，`policy hadamard_guard = strict` 自動攔截第一代稠密 Bareiss 的 64-bit 整數溢位（`-28773728843`），路由至 `KronBlockMat::det_fast()` 在 $2\times 2$ 葉節點算得精確行列式 `+33871089681`（算子數由 512 降至 24）；並以 $\mathbb{F}_p[x]$ 鉛筆 SNF 分離同跡同行列式的偽造矩陣。 |

---

## 三、現存七大政策與機制如何編寫入 `sigma` DSL

在 `sigma/sigma.mbt` 與 `sigma/crypto_suite.sigma` 中，我們將專案歷輪累積的七項關鍵安全政策與工程機制鑄造為語言級 `policy` 指令：

1. **`policy hadamard_guard = strict;`（Hadamard 64-bit 溢位守衛政策）**：
   - 在執行行列式、SNF 或 LLL 前強制呼叫 `Mat::guard_hadamard()`（檢查 $n \le 6$ 且 $b^n n! \le 2^{60}$）與 `KronBlockMat::leaves_hadamard_safe()`。一旦稠密展開可能突破 `Int64` 上限，語言調度器自動將運算轉向 `mat2::KronBlockMat` 的結構化葉節點公式 $\det(A \otimes B) = (\det A)^{\dim B}(\det B)^{\dim A}$。
2. **`policy witness_obligatory = enforce;`（義務自證憑證政策）**：
   - 語言底層禁止「僅回傳數值而無見證」的黑箱呼叫。每個 `cipher` 運算皆回傳 `SigmaCert` 結構，內含雙邊么模矩陣 $(U, V)$、Bézout 餘因子 $(u, v)$、NTT 往返驗證或對偶格雙正交憑證，且 `ok` 欄位必須為 `true`。
3. **`policy complexity_gate = audit;`（形式化減複雜度與 `G3`/`G4` 審計閘門政策）**：
   - 將第七輪形式化證明的七大減複雜度措施（見證 Skolem 化、Proof-by-Call 引理鏈、去迴圈單步核、級數截斷、清分母多項式化、小秩特化、Mat2 結構壓縮）以及 `G3`（`T-TO-01`–`T-TO-09` 超時定理）與 `G4`（`ALG-CE-01`–`ALG-CE-10` 組合爆炸演算法）直接掛載於每個 `SigmaCert.complexity_status` 中，使密碼協定設計者清楚掌握每個算子的形式化證明邊界。
4. **`policy egraph_opt = on;`（E-Graph 等價飽和代數超優化政策）**：
   - 自動調用 `@synth.superoptimize` 將代數算式在等價類中重寫為最低乘法成本形式（如二次矩陣冪透過 Cayley–Hamilton 線性化、多項式求值由 Horner 轉為 Estrin 平行樹）。
5. **`policy cegis_synth = on;`（CEGIS 反例引導合成政策）**：
   - 自動調用 `@synth.cegis_synth_karatsuba_im`、`@synth.cegis_synth_cayley_hamilton_coeffs` 與 `@synth.verify_cegis_guard_repair` 合成無乘法器／降階係數與除法前條件守衛。
6. **`policy mat2_backend = auto;`（第二代矩陣體系自動選型政策）**：
   - 依密碼原語的代數結構自動選取最佳矩陣表示：分圓環自動選 `DispCircMat`、超對稱承諾自動選 `GrassmannSuperMat`、同源圖路由自動選 `TropicalMat`、張量擴散層自動選 `KronBlockMat`、相似性認證自動選 `PolyMat`。
7. **`policy constant_time = canonical;`（標準代表元與無除法正規化政策）**：
   - 強制所有模算術透過 `@core.zmod` 歸約至唯一非負區間 $[0, q)$，多項式透過 `PolyFp::to_monic` 歸一化，線性求解優先採用無除法伴隨算子 `@psynth.adjugate_solve_synth`，消除分支與可變延遲除法帶來的時序旁道風險。

---

## 四、自研轉譯器架構與對接 MoonBit 官方編譯器（`moonc` / `moon`）之四大建議做法

為使 `.sigma` 密碼學程式既能享受 DSL 的高階抽象，又能直接獲得 MoonBit 官方編譯器（`moonc v0.10.14`）的極速編譯、跨平台代碼生成與 `moon prove` 演繹驗證，我們實作並總結了以下**由淺入深的四大對接方案**：

### 方案一：利用 `moon.pkg` 原生 `rule` 與 `dev_build` 嵌入官方建置圖（已實作落地 — 官方推薦首選）

MoonBit 最新版套件配置語言 `moon.pkg`（取代舊版 `moon.pkg.json` 的 `pre-build`）提供了原生的建置規則宣告 `rule` 與 `dev_build`。我們在 [`sigma/moon.pkg`](sigma/moon.pkg) 中直接寫入：

```moonbit
rule(name: "sigmac", command: "python3 tools/sigmac.py $input $output")

dev_build(
  rule: "sigmac",
  input: "crypto_suite.sigma",
  output: "generated_suite.mbt",
)
```

- **運作機制**：當開發者執行任何官方命令（`moon check`、`moon build`、`moon test`、`moon run`）時，`moon` 的 `n2` 建置引擎會自動偵測 `sigma/crypto_suite.sigma` 的變更，先調用自研 AOT 轉譯器 [`tools/sigmac.py`](tools/sigmac.py) 將 `.sigma` 轉譯為 [`sigma/generated_suite.mbt`](sigma/generated_suite.mbt)，再交由 `moonc` 進行強型別檢查與目標碼編譯。
- **優勢**：零外部 Makefile 依賴、增量編譯快取由 `moon` 官方統一管理、產出之 `generated_suite.mbt` 自動跳過重複格式化並可直接隨倉庫發布。

### 方案二：自研雙軌形式化轉譯器 `.sigma` $\to$ (`.mbt` 執行碼 + `.mbtp` 證明規格)（已實作落地）

在 [`sigma/sigma.mbt`](sigma/sigma.mbt) 中，我們以純 MoonBit 實作了自研雙軌轉譯器 `transpile_to_moonbit(src)` 與 `transpile_to_mbtp(src)`（可透過 `moon run cmd/main -- transpile` 直接調用）：

1. **執行軌（`.mbt`）**：自動生成帶 `where { proof_require: ..., proof_ensure: res => sigma_<cipher>_post(...) }` 形式化合約與 `#export_name("sigma_<cipher>")` 屬性的 MoonBit 函數；
2. **邏輯軌（`.mbtp`）**：同步生成對應的 `pub predicate` 與 `pub lemma`，可直接放入 `"proof-enabled": true` 的驗證套件（如 [`proof/sigma/`](proof/sigma/)），由 `moon prove proof/sigma --why3-config why3-long.conf` 透過 Why3 + Z3/CVC5 完成 100% 形式化驗證。

### 方案三：透過 `#export_name` 與 `foreign_library` 對接官方四大編譯後端（Wasm-GC / Wasm / Native C / JS）

MoonBit 官方編譯器支援多後端編譯。自研轉譯器在生成的每個密碼學入口函數上自動標註 `#export_name("sigma_<cipher>")`（遵循 MoonBit v0.10.14 規範，使用合法 C 識別符）：

- **對接雲端與瀏覽器（`wasm-gc` / `wasm` / `js`）**：
  在 `moon.pkg` 設定 `pkgtype(kind: "foreign_library")` 後，執行 `moon build --target wasm-gc --release` 或 `moon build --target js --release`，即可產出極小體積的 WebAssembly 模組或 ES Module，供瀏覽器零知識證明客戶端或邊緣節點直接呼叫 `sigma_ring_lwe_kem` 等匯出符號。
- **對接原生系統與硬體密碼加速卡（`native` C 後端）**：
  執行 `moon build --target native --release` 時，`moonc` 將轉譯出的 `.mbt` 編譯為高優化 C 源碼並調用系統 `gcc`/`clang`（可在 `moon.pkg` 的 `options(link: { "native": { "cc-flags": "-O3 -march=native" } })` 中開啟 AVX2/AVX-512 向量化指令），實現與底層密碼硬體（HSM / 網卡）的零拷貝對接。

### 方案四：利用 `moon.pkg` 之 `virtual` / `implement` / `overrides` 實現可插拔密碼算術後端（進階架構建議）

針對同一份 `.sigma` 密碼學協定需要在「形式化精確驗證環境」、「常數時間嵌入式環境」與「GPU/SIMD 高吞吐環境」之間無縫切換的需求，建議採用 MoonBit 官方的 **Virtual Package（虛擬套件）** 機制：

1. 將底層有限域與矩陣算子宣告為虛擬介面套件（在 `moon.pkg` 標註 `options(virtual: { "has-default": true })`）；
2. 提供多套實作套件（例如基於 `core::Mat` 精確整數的參考實作、基於 `mat2` 結構化壓縮矩陣的演算法實作、以及透過 C FFI 綁定硬體 NTT/AES-NI 的實作，各自標註 `options(implement: "sigma/supermatrix/crypto_hal")`）；
3. 在頂層執行檔或測試套件的 `moon.pkg` 中僅需一行 `options(overrides: ["..."])`，即可在不改動任何一行 `.sigma` DSL 源碼的情況下切換底層密碼算術引擎。

---

## 五、快速重現與檢驗指令

```bash
export PATH="/usr/local/bin:$HOME/.moon/bin:$PATH"

# 1. 執行 sigma DSL 報告（展示七大政策、七大密碼學原語 SigmaCert 與 AOT 預編譯結果）
moon run --target wasm-gc --release cmd/main -- sigma

# 2. 執行自研雙軌轉譯器（將標準 .sigma 腳本即時轉譯為 .mbt 與 .mbtp 源碼）
moon run --target wasm-gc --release cmd/main -- transpile

# 3. 驗證新增之第十形式化證明套件 proof/sigma（9 / 9 VC 全部通過）
moon prove proof/sigma --why3-config why3-long.conf

# 4. 執行全專案 48 項單元測試與跨套件自檢（3860 / 3860 語料條目 100% 通過）
moon test --target wasm-gc
moon run --target wasm-gc --release cmd/main -- selftest
```
