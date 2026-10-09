# Σ-超矩陣框架（sigma/supermatrix）

> 公理：**全部（超）矩陣化** — 一切群、格、曲線、群概形與模空間的演算法，都歸約為
> 「帶整數矩陣的（超）運算 + 機器可檢核的見證」，使演算法總數超過 3000 條，
> 並在組合衍生的演算法中逼出世上首次出現的「極品演算法」。

本專案以 **MoonBit 最新穩定版**（`moon 0.1.20260920` / `moonc v0.10.14`，2026-09-21 發布）實作，
由**二十一套件（11 個執行期套件含 `sigma` 密碼學 DSL + 10 個形式化驗證套件含 `proof/sigma`）+ 一個 CLI**組成，交付 **3860 條定理／定義／算式／義務自證**（硬指標 3000），
**機器見證通過率 3860 / 3860（100.00%）**；其中十大形式化證明套件之 **164 個帶約束定義（159 個驗證條件）100% 由 Why3 + z3／cvc5 形式化機器證明**（`moon prove` 活動套件 **0 未決、0 超時**），並將實測觸發 SMT 超時的 **9 條定理（`G3: T-TO-01..09`）** 與採取七大減複雜度措施後仍組合爆炸的 **10 條演算法（`G4: ALG-CE-01..10`）** 完整略過並記錄於帳本與最終報告中。

本專案提供四份核心研究與審計專論：
- [`SIGMA_DSL_CRYPTO_REPORT.md`](SIGMA_DSL_CRYPTO_REPORT.md)：**Σ-密碼學領域特定語言（`sigma` Crypto DSL）：架構設計、七大密碼學演算法應用、底層政策內嵌與自研轉譯器對接官方編譯器專論**（對應 `sigma/` + `proof/sigma/` + `tools/sigmac.py` + 語料族 `L1`–`L4`）；
- [`FORMAL_PROOF_REPORT.md`](FORMAL_PROOF_REPORT.md)：**全領域定理與演算法形式化證明、超時定理略過紀錄（`T-TO-01`–`T-TO-09`）與組合爆炸演算法審計報告（`ALG-CE-01`–`ALG-CE-10`）**；
- [`SECOND_MATRIX_REPORT.md`](SECOND_MATRIX_REPORT.md)：**第二種矩陣可能性之詳盡規劃、五型選型與與第一代矩陣（`core::Mat`）之差異結果實證報告**（對應 `mat2/` + `proof/mat2/` + 語料族 `J1`–`J5`）；
- [`SYNTHESIS.md`](SYNTHESIS.md)：**形式化在代碼生成與演算法生成中的八大衍生賦能機制（Beyond Verification）**（對應 `synth/` + `proof/synth/` + 語料族 `I1`–`I8`）。

---

## 1. 快速開始

```text
export PATH="$HOME/.moon/bin:$PATH"
cd supermatrix

moon check                     # 型別與警告檢查：0 errors / 0 warnings (自動觸發 dev_build 轉譯 .sigma)
moon test --target wasm-gc     # 執行期測試：48 / 48 通過
for pkg in proof/algebra proof/bridge proof/synth proof/mat2 proof/fga_snf proof/latt proof/spec proof/curves_padic proof/sigma proof; do
  moon prove "$pkg" --why3-config why3-long.conf
done                           # 十大形式化套件：159 / 159 VC 已證（0 未決）
python3 tools/sync_proof.py    # 同步生成 corpus/proof_ledger.mbt（G1=164, G2=0, G3=9, G4=10）
moon run cmd/main --target wasm-gc -- sigma         # Σ-密碼學領域特定語言 (sigma DSL) 執行與政策審計報告
moon run cmd/main --target wasm-gc -- transpile     # 自研轉譯器將 .sigma 雙軌轉譯為 .mbt 與 .mbtp
moon run cmd/main --target wasm-gc -- stats         # 語料統計（3860 / 3860 全數通過）
moon run cmd/main --target wasm-gc -- proof-audit   # 全領域形式化證明、超時定理與組合爆炸演算法審計報告
moon run cmd/main --target wasm-gc -- mat2          # 第二代矩陣體系 vs 第一代矩陣實證對照報告
moon run cmd/main --target wasm-gc -- synth         # 形式化驅動代碼與演算法生成實證報告
moon run cmd/main --target wasm-gc -- selftest      # 跨套件自檢
```

CLI 模式：`stats`｜`corpus-md`｜`corpus-csv`｜`corpus-json`｜`dsl <程式>`｜`synth`｜`mat2`｜`sigma`｜`transpile`｜`proof-audit`｜`selftest`。

---

## 2. 十大形式化驗證套件（159 / 159 VC 已證）

| 證明套件 | 已證 VC | 未決 VC | 帶約束定義 | 涵蓋領域與減複雜度核心 |
|---|---:|---:|---:|---|
| `proof/algebra` | 16 | 0 | 17 | 模同態、整除見證鏈、極化純量核、2×2 Cayley–Hamilton、$\operatorname{GL}_2$ 行列式乘性 |
| `proof/bridge` | 18 | 0 | 17 | 微步驟引理 `m1`–`m4`、前向封閉 `dvd_mod_step`、**Proof-by-Call 構造性逆推 `dvd_mod_back`** |
| `proof/synth` | 22 | 0 | 22 | Horner/Estrin、Karatsuba、CH 降階、無除法伴隨求解、Bézout 步、蝶形 DFT、循環 FFT 對角化、Rosati–Kani、Hensel 提升、歐幾里得除法修補 |
| `proof/mat2` | 11 | 0 | 12 | Grassmann 奇偶外積、**非零奇部 Berezinian 完整乘法性 vs 交換環 `-2acef` 缺陷定理**、Kronecker 跡與行列式分解、多項式鉛筆判別式分離、Tropical 半環與 $p$-進牛頓下界、位移交換子零化 |
| `proof/fga_snf` | 19 | 0 | 20 | SNF $(\gcd,\operatorname{lcm})$ 核、雙邊憑證 $UAV=D$、行列消去不變式、2×2 么模逆元、HNF 副對角橋接、秩–零化度結構定理、Hom/Ext/Tor/Tensor、Pontryagin 雙對偶、Lagrange、$p^k$-撓、初等 $p$-群、**CRT Bézout 同構**、有理數 `Frac`、**$3\times 3$ Bareiss 消去與 Sylvester 恆等式** |
| `proof/latt` | 13 | 0 | 13 | Gram 對稱非負、**協體積 Lagrange / Cauchy–Schwarz 恆等式 $\det(BB^T)=(\det B)^2$**、2D/3D LLL 么模逆元核、尺寸約化單步、對偶格雙正交、SVP Hermite 界、CVP 距離、平行四邊形律 |
| `proof/spec` | 14 | 0 | 14 | **4 點雙向傅立葉蝶形往返互逆 $F_4^*F_4(x)=4x$**、卷積定理、循環特徵對角化、2D/3D 伴隨內積、辛塊剪切與對合、**偶／奇分次超交換子超跡消沒**、塊三角 Berezinian、二次與**三次容斥極化恆等式** |
| `proof/curves_padic` | 15 | 0 | 15 | 橢圓曲線 Hasse 界、**二次扭轉點數守恆 $\#E+\#E'=2p+2$**、Vélu 2-/3-同源係數、Tate 模 Frobenius 方程、Teichmüller 提升、**乘法形式群三公理**、二階形式對數、$|\operatorname{SL}_2(\mathbb{Z}/p^n)|$ 遞推、$\operatorname{SO}(3,\mathbb{Z})$ 正交群、$p$-進超度量、平面曲線虧格與 Kani $4g^2$、DSL 等價律 |
| `proof/sigma` | 9 | 0 | 9 | **`sigma` 密碼學 DSL 核心協定**：Ring-LWE 加解密往返、Micciancio HNF 么模隱藏與 GPV 陷門還原、Vélu–Kani 2D 同源正交鑽石、Pohlig–Hellman CRT 重組、Hensel 密鑰提升、Grassmann Berezinian 同態承諾與超跡零知識遮罩、Hadamard 守衛張量路由 |
| `proof` | 22 | 0 | 25 | 絕對值、正模約化、三角形數、整數平方根 `isqrt`、質數試除健全性、模冪、**無條件完全證明之 `gcd_verified`** |
| **合計** | **159** | **0** | **164** | **另略過並記錄：超時定理 9 條（`G3`）、組合爆炸演算法 10 條（`G4`）** |
