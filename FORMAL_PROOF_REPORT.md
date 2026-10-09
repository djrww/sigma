# Σ-超矩陣框架：全領域定理與演算法形式化證明、超時定理略過紀錄與組合爆炸演算法審計報告

> **執行環境與驗證工具鏈**：
> - **語言與編譯器**：MoonBit 最新穩定版 `moon 0.1.20260920` / `moonc v0.10.14`（2026-09-21 發布）
> - **驗證條件生成器**：MoonBit 內建演繹驗證器（`moon prove`）+ `Why3 1.7.2`（Weakest Precondition 演算 + `split_vc` + `compute_specified`）
> - **後端 SMT 求解器**：`Z3 5.1.0`（主求解器）+ `CVC5 1.4.2`（輔助非線性算術求解器）
> - **全局驗證成果**：
>   - **九大形式化證明套件**：**150 / 150 個驗證條件（VC）100% 機器消解（未決 0）**；
>   - **帶約束形式化定義（族 `G1`）**：**155 / 155 個定義 100% 通過證明（未決 0）**；
>   - **實測觸發 SMT 超時而略過並記錄之定理（族 `G3`）**：**9 條（`T-TO-01` – `T-TO-09`）**；
>   - **採取各種減複雜度措施後仍組合爆炸而略過並記錄之演算法（族 `G4`）**：**10 條（`ALG-CE-01` – `ALG-CE-10`）**；
>   - **全專案語料庫（A1–K4）**：**3771 / 3771 條機器見證 100.00% 通過**。

---

## 一、九大形式化驗證套件總覽（150 / 150 VC 全部消解）

為徹底避免跨領域量詞公理互相污染（Axiom Context Pollution），本專案將全領域定理與減複雜度演算法核拆分為**九個正交的形式化驗證套件**，每個套件均通過 `moon prove <pkg> --why3-config why3-long.conf` 100% 驗證：

| 序號 | 驗證套件路徑 | 已證 VC 數 | 未決 VC 數 | 帶約束定義數 | 對應語料族 | 涵蓋之核心定理與演算法核 |
|---|---|---:|---:|---:|---|---|
| 1 | `proof/algebra` | **16** | 0 | 17 | `A1`, `D6`, `G1` | 模加／模乘同態、整除見證傳遞／加減封閉、線性同餘核、Smith 不變因子鏈、極化純量核、2×2 Cayley–Hamilton、$\operatorname{GL}_2$ 行列式乘性 |
| 2 | `proof/bridge` | **18** | 0 | 17 | `G1`, `I8` | 截斷除法微引理 `m1`–`m4`、前向封閉 `dvd_mod_step`、鏡像引理 `m2r`/`m3r`、**Proof-by-Call 構造性逆推 `dvd_mod_back`** |
| 3 | `proof/synth` | **22** | 0 | 22 | `I1`–`I8`, `G1` | Horner 與 Estrin 多項式求值合成、Gauss–Karatsuba 3 乘法、CH 二次冪線性化、伴隨無除法求解、Bézout 單步見證、四分之一平方折減、二點蝶形 DFT 與 Parseval、Brahmagupta 範數、**全整數域歐幾里得除法修補**、辛消去、循環 FFT 對角化、Rosati–Kani 同源、Hensel 二次提升見證、雙重對偶消去 |
| 4 | `proof/mat2` | **11** | 0 | 12 | `J1`–`J5`, `G1` | Grassmann 奇偶外積、**非零奇部 Berezinian 完整乘法性 vs 第一代交換矩陣 `-2acef` 缺陷定理**、Kronecker 張量跡與行列式分解、多項式特徵鉛筆判別式分離、Tropical 半環結合／分配律與 $p$-進牛頓下界、循環位移交換子零化 |
| 5 | `proof/fga_snf` | **19** | 0 | 20 | `A1`–`A4`, `B1`–`B6`, `H6`, `H8`, `K1` | 對角 SNF $(\gcd,\operatorname{lcm})$ 與乘積守恆、雙邊么模憑證 $UAV=D$、基本行列消去不變式、2×2 么模逆元、HNF 主對角行列式橋接、秩–零化度結構定理、Hom/Ext/Tor/Tensor 同構、Pontryagin 雙對偶、Lagrange 商群階整除、$p^k$-撓指數截斷、初等貝爾 $p$-群、**CRT Bézout 同構構造**、有理數 `Frac` 算術律、**$3\times 3$ Bareiss 無分數消去與 Sylvester 恆等式** |
| 6 | `proof/latt` | **13** | 0 | 13 | `C1`–`C5`, `H7`, `K2` | Gram 矩陣對稱與非負、**協體積平方 Lagrange / Cauchy–Schwarz 恆等式 $\det(BB^T)=(\det B)^2\ge 0$**、2D/3D LLL 么模約化逆元核、尺寸約化單步不變式、對偶格雙正交性、SVP Hermite 界、CVP 距離對稱非負、平行四邊形範數律、么模協體積守恆 |
| 7 | `proof/spec` | **14** | 0 | 14 | `D1`–`D6`, `H9`, `K3` | **4 點雙向傅立葉蝶形變換往返互逆 $F_4^* F_4(x)=4x$**、卷積定理、循環算子特徵對角化、2D/3D 伴隨映射內積恆等式、辛雙環塊剪切 $S^TJS=J$ 與 $J^2=-I$、**偶交換子與奇反交換子超跡消沒 $\operatorname{str}([M,N])=0$**、塊三角 Berezinian、二次型極化、**三次型容斥極化恆等式 $\sum(-1)^{3-|S|}P(\sum u_i)=6uvw$** |
| 8 | `proof/curves_padic` | **15** | 0 | 15 | `E1`–`E6`, `F1`, `H1`–`H5`, `H10`, `K4` | 橢圓曲線 Hasse 界與點群階、**二次扭轉點數守恆 $\#E+\#E'=2p+2$**、Vélu 2-同源與 3-同源係數變換、Tate 模 Frobenius 特徵方程 $\Phi^2-t\Phi+pI=0$、Teichmüller 提升同餘見證、**乘法形式群律 $X+Y+XY$ 結合／交換／單位三公理**、二階形式對數同態、離散李群 $|\operatorname{SL}_2(\mathbb{Z}/p^n)|=p^{3n-2}(p^2-1)$ 李代數核遞推、$\operatorname{SO}(3,\mathbb{Z})$ 正交旋轉群、$p$-進超度量見證、平面曲線虧格與 Kani $4g^2$ 維度帳、DSL 四大規範形等價律 |
| 9 | `proof` | **22** | 0 | 25 | `G1` | 絕對值、二元極值、遞迴終止、正模約化、三角形數閉式、**整數平方根 `isqrt` 完整規格**、斐波那契單調不變式、階乘正性、**無條件完全證明之歐幾里得演算法 `gcd_verified`（含全稱極大性）**、試除法質數判定健全性、模重複平方 `pow_mod` |
| **合計** | **9 套件** | **150** | **0** | **155** | **全族 A–K** | **100% 機器證明通過（0 未決、0 超時）** |

---

## 二、為消解定理與演算法所採取的「七大減複雜度措施（Measures R1–R7）」

在對全專案 9 大領域套件與 3771 條語料進行形式化證明時，直接將執行期陣列迴圈或非線性模算式丟給 Why3 + SMT 會立即觸發狀態空間或量詞實例化爆炸。我們系統性採取了以下**七大減複雜度措施**：

1. **措施 R1：演算法搜尋迴圈與自帶憑證驗證器分離（Certifying Kernel Separation）**
   - 將「如何找到么模變換 $U, V$」的啟發式／迭代搜尋，轉化為驗證雙邊憑證 $U \cdot A \cdot V = D$（`snf_bilateral_cert2_synth`）、LLL 么模逆元 $U \cdot B = I$（`lll_shear2_reduce_synth`、`lll_unit_lower3_reduce_synth`）與伴隨無除法求解 $A^{\text{adj}}(Av) = (\det A)v$（`adjugate_solve_synth`）。
2. **措施 R2：固定低維純量代數投影（Fixed-Dimension Scalar Projection）**
   - 將 `FixedArray[Int64]` 上的雙層／三層索引迴圈投影為暫存器純量元組（$2\times 2$、$3\times 3$ 矩陣、4 點蝶形 DFT、三次多項式 Horner/Estrin），消除陣列別名（Array Aliasing）與全稱索引量詞 $\forall i, j$。憑藉此措施，我們成功讓 Z3/CVC5 自動證出**含整數除法的 $3\times 3$ Bareiss 無分數高斯消去與 Sylvester 行列式恆等式（`bareiss3_det_synth`）**！
3. **措施 R3：迴圈單步微引理拆解（Single-Step Loop Body Isolation）**
   - 將多步迭代演算法拆解為單步轉移不變式：如擴展歐幾里得單步 Bézout 係數更新（`bezout_step_synth`）、Hensel 二次牛頓步（`hensel_sqrt_step_synth`）、Teichmüller 提升步（`teichmuller_newton_step_synth`）、格尺寸約化單步（`lll_size_reduce_step2_synth`）與基本行列消去單步（`elem_row_add_det2_synth`）。
4. **措施 R4：量詞 Skolem 化與 `Proof-by-Call` 見證函數傳遞（Witness Skolemization）**
   - 將非線性取餘 `a % d == 0` 改寫為顯式商見證 `a == d * k`，並透過 `.mbt` 程式側函數呼叫（如 `@bridge.dvd_mod_back(a, b, g)`、`crt_isomorphism_recon_synth`）交由 Why3 的 WP 演算做語法 $\beta$-歸約，徹底繞開 SMT 全稱量詞 E-matching 盲區。
5. **措施 R5：第二代矩陣結構降維（`mat2` Structural Decomposition）**
   - 以 `KronBlockMat` 張量樹葉分解取代高維稠密張量展開（將 $4\times 4 / 8\times 8$ 行列式證明降為 $2\times 2$ 葉節點冪次定理 `kronecker_det_diag2_synth`），並以 `DispCircMat` 位移秩生成元取代稠密循環矩陣。
6. **措施 R6：熱帶半環與超度量賦值鬆弛（Tropical & Ultrametric Relaxation）**
   - 以 $(\min, +)$ 熱帶永久式下界（`tropical_det2_valuation_synth`）取代展開完整 $p$-進級數行列式。
7. **措施 R7：公理語境衛生學與九套件獨立分包（Axiom Context Hygiene）**
   - 嚴格將每個證明套件控制在 11–22 個 VC 內，避免無關的量詞公理進入同一 `.mlw` 理論檔案。

---

## 三、實測觸發 SMT 超時而略過並記錄之定理清單（族 `G3`：`T-TO-01` – `T-TO-09`）

在將全專案定理逐一翻譯為 `.mbtp` 邏輯引理與 `.mbt` 契約函數並交由 `Why3 1.7.2 + Z3 5.1.0 + CVC5 1.4.2`（時限策略 0.2s → 1s → `split_vc` → 2s，500,000 步）實測時，以下 **9 條定理的直接形式化原式** 觸發了 **Z3 與 CVC5 雙雙 Timeout**。我們按指示**將這些超時原式從活動驗證套件中略過**，在語料庫 `G3` 族與本報告中完整記錄其超時診斷，並同時在活動套件中提供經減複雜度措施改寫後的**已證替代定理**：

| 編號 | 略過之超時定理名稱與所屬領域 | 觸發 SMT 超時之形式化原式（Why3 / `.mbtp`） | 實測求解器結果（Z3 5.1.0 / CVC5 1.4.2） | 超時根本原因剖析（Root Cause） | 活動套件中之已證替代方案 |
|---|---|---|---|---|---|
| **T-TO-01** | `hnf_upper_det2_implicit_groebner`<br>（族 `A1`/`H7`：HNF 隱式 Gröbner 消去） | 在 11 變數 (`u11..u22, a11..a22, h11, h12, h22`) 下給定 `u11*u22-u12*u21 == 1` 與 `u21*a11+u22*a21 == 0`，直接要求證 `a11*a22 - a12*a21 == h11 * h22`（不顯式構造副對角交叉項 `h12 * h21`） | `CVC5`: **Timeout**<br>`Z3`: **Timeout**<br>（於 `.mbt` SSA 綁定下耗盡時限） | 程式側產生 `o0..o7` 共 8 個中間 SSA 常數與 11 個自由變數；SMT 必須在無提示下執行 11 變數 4 階非線性多項式理想之 Gröbner 基消去，才能發現需將零項 `u21*a11+u22*a21` 乘上 `h12` 才能拼出行列式乘積恆等式。 | 於 `proof/fga_snf::hnf_upper_det2_synth` 顯式引入副對角零化橋接項 `h11*h22 - h12*h21`，**0.1s 內消解**。 |
| **T-TO-02** | `crt_direct_mod_mn`<br>（族 `B1`/`H6`：中國剩餘定理直接模乘積唯一性） | `m > 1 && n > 1 && m*u + n*v == 1 && x >= 0 && y >= 0 && x % m == y % m && x % n == y % n ⟹ x % (m * n) == y % (m * n)` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 模數 `m * n` 為兩個符號變數之非線性乘積，且含三個不同模數 (`% m`, `% n`, `% (m*n)`) 的非線性歐幾里得取餘；在 Peano/NIA 算術中，含符號乘積模數的直接取餘屬於不可判定片段，求解器陷入無限商分裂。 | 略過直接 `% (m*n)` 式；改用措施 R4（Bézout 餘因子見證）於 `proof/fga_snf::crt_isomorphism_recon_synth` 與 `lemma_crt_congruence` 證明同構解構造。 |
| **T-TO-03** | `bezout_signed_mod_div`<br>（族 `A1`/`I1`：有號 Bézout 線性組合直接取餘整除） | `a > 0 && b > 0 && d > 0 && a % d == 0 && b % d == 0 ⟹ (a * u + b * v) % d == 0`（其中 $u, v \in \mathbb{Z}$ 可為負數） | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | MoonBit/Why3 整數 `%` 採用 `ComputerDivision`（向零截斷除法）。當 $u, v$ 可正可負時，`a*u + b*v` 的正負號不定，導致截斷除法恆等式在正負區間分裂出指數級 case splits，且欠缺顯式商見證 `k1 = a/d, k2 = b/d`。 | 略過有號直接 `% d` 式；改以顯式商見證於 `proof/algebra::dvd_add_witness`、`dvd_sub_witness` 與 `proof/synth::bezout_step_synth` 證明。 |
| **T-TO-04** | `euclid_mod_back_unskolemized`<br>（族 `G1`/`I8`：歐幾里得取餘逆推無 Skolem 見證引理） | `a >= 0 && b > 0 && d > 0 && b % d == 0 && (a % b) % d == 0 ⟹ a % d == 0`（單步直接蘊含，無中間見證函數） | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 要證 `a % d == 0`，必須先由 `b % d == 0` 與 `(a % b) % d == 0` 同時取出商 `k2 = b/d` 與 `kr = (a%b)/d`，再合成非線性複合見證項 `k = k2*(a/b) + kr`。SMT 的 E-matching 觸發器無法憑空猜出該三層複合算術項。 | 略過無見證單步式；改以措施 R4（Proof-by-Call 四步函數呼叫鏈 `step_b_wit` → `step_rem_wit` → `step_a_wit` → `step_mul_mod`）於 `proof/bridge::dvd_mod_back` 構造性證畢。 |
| **T-TO-05** | `velu_rational_map_mod_p`<br>（族 `E3`/`H1`：有限域 $\mathbb{F}_p$ Vélu 2-同源有理映射直接 `% p` 同餘） | `p > 5 && (α³+aα+b)%p == 0 && ((x-α)*inv_dx)%p == 1 ⟹ ((x(x-α)² + (3α²+a)(x-α) + 2(α³+aα))*inv_dx²)%p == (x + (3α²+a)*inv_dx + 2(α³+aα)*inv_dx²)%p` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 同時耦合 5 階非線性多項式、符號質數模取餘 `% p` 以及模逆元關係 `((x-α)*inv_dx) % p == 1`；SMT 對每次乘法後的 `% p` 需引入新商變數 $q_i$，導致 5 階多項式與商變數交叉相乘爆炸。 | 略過含 `inv_dx % p` 之有理分式模同餘；改於整數多項式環證明 Vélu 2-/3-同源係數變換核 `proof/curves_padic::velu_two_isogeny_coeff_synth` 與 `velu_three_isogeny_coeff_synth`。 |
| **T-TO-06** | `ntt4_butterfly_mod_p`<br>（族 `D1`/`H9`：有限域 4 點 NTT 本原根 $\omega^2\equiv -1\pmod p$ 逐線 `% p` 反演） | `p > 5 && (w*w + 1) % p == 0 ⟹ (((x1 + w*x3) % p) * ((1 - w) % p) + ((x1 - w*x3) % p) * ((1 + w) % p)) % p == (2 * (x1 + x3)) % p` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 蝶形網絡每條中間連線均套用 `% p`，產生 5 個巢狀非線性取餘商變數，且需利用非線性模理想 `(w*w + 1) % p == 0` 消去二次項 $w^2$；NIA 求解器無法在多層 `% p` 內部執行理想約化。 | 略過逐線 `% p` 式；改於代數商環 $\mathbb{Z}[\omega]/(\omega^2+1)$ 實作並證明 4 點蝶形往返定理 `proof/spec::dft4_roundtrip_synth`。 |
| **T-TO-07** | `ultrametric_direct_mod_pk`<br>（族 `E6`/`H10`：$p$-進超度量雙層符號模數 `pk % p == 0` 直接取餘傳遞） | `p >= 2 && pk > p && pk % p == 0 && a % pk == 0 && b % pk == 0 && a + b != 0 ⟹ (a + b) % pk == 0 && (a + b) % p == 0` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 涉及雙層符號模數 `pk` 與 `p` 的鏈式非線性取餘（`a % pk == 0`、`pk % p == 0` 推導 `(a+b) % p == 0`），且 $a, b$ 可正可負（`a + b != 0`），觸發 `ComputerDivision` 正負號與雙重商變數乘積爆炸。 | 略過直接雙層 `%` 式；改以顯式賦值見證 $a = p^{\min} k_a, b = p^{\min} k_b$ 於 `proof/curves_padic::padic_ultrametric_witness_synth` 證明。 |
| **T-TO-08** | `twist_euler_mod_p`<br>（族 `E2`：二次扭轉非平方剩餘全稱量詞模 $p$ 定理） | `p > 3 && p % 4 == 3 && (d*d - 1) % p == 0 && d % p != 1 && rhs % p != 0 ⟹ (∀y, (y*y - rhs) % p != 0) → (∀z, (z*z - d*d*rhs) % p != 0)` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 在後置條件中交替出現兩個全稱量詞 $\forall y, \forall z$ 與模符號質數 $p$ 的二次多項式 `(z*z - d*d*rhs) % p`；SMT 無法自動構造模逆元變數變換 $y = z \cdot d^{-1} \bmod p$ 來實例化前件量詞。 | 略過帶量詞二次剩餘模 $p$ 式；改證 Legendre 特徵逐點相消與扭轉點數守恆定理 `proof/curves_padic::ec_quadratic_twist_sum_synth`。 |
| **T-TO-09** | `hensel_lift_direct_mod`<br>（族 `E5`/`I7`：Hensel 平方根二次提升直接 `% (pk * pk)` 模平方定理） | `pk > 1 && ((x0*x0 - c) + 2*x0*t*pk) % (pk * pk) == 0 ⟹ ((x0 + t*pk)*(x0 + t*pk) - c) % (pk * pk) == 0` | `CVC5`: **Timeout**<br>`Z3`: **Timeout** | 除數本身為符號平方項 `pk * pk`，被除數展開後含 4 階非線性項 `t * t * pk * pk`；SMT 求解器在未展開平方式前無法穿透 `% (pk * pk)` 識別出多出的項恰為模數 `pk * pk` 的 `t * t` 倍。 | 略過直接 `% (pk * pk)` 式；改以顯式餘因子見證構造 `(x0 + t*pk, m + t*t)` 於 `proof/synth::hensel_sqrt_step_synth` 證明。 |

---

## 四、採取各種減複雜度措施後仍組合爆炸而略過並記錄之演算法清單（族 `G4`：`ALG-CE-01` – `ALG-CE-10`）

針對全專案 9 大執行期套件中的所有演算法，我們先全面實施了第二節所述的**減複雜度措施 `R1`–`R7`**（包含：提取雙邊憑證驗證器、將陣列投影為 $2\times 2 / 3\times 3$ 純量元組、拆解迴圈單步不變式、展開固定步數迴圈、改用第二代 `KronBlockMat` / `DispCircMat` 結構）。

經過上述減複雜度措施後，絕大多數演算法的核心算子與單步不變式皆已成功納入九大證明套件（共 150 個 VC 全部證畢）；**惟以下 10 個完整演算法本體**，即使在採取純量元組化、有界迴圈展開或子步驟拆解等減複雜度措施後，其完整控制流或高階代數展開在 WP / Why3 / SMT 中**仍然發生路徑、次數或量詞組合爆炸**。我們按指示**略過其完整迴圈之直接 WP 驗證**，將實測爆炸數據與已證替代核完整記錄如下：

| 編號 | 略過之組合爆炸演算法與所在模組 | 已採取的減複雜度措施（Measures Tried） | 實測組合爆炸現象與精確邊界（Why3 / Z3 / CVC5 實測數據） | 已成功形式化證明之演算法核（Active Proved Kernels） |
|---|---|---|---|---|---|
| **ALG-CE-01** | `core::snf_full` & `core::hnf_full`<br>（`core/snf.mbt`：任意 $m\times n$ 稠密矩陣雙迴圈交替歐幾里得行列消去與非整除主元修補演算法） | **R1**（分離 $UAV=D$ 憑證）、**R2**（將 `FixedArray` 降為 $2\times 2$ 4-元組 `(m11,m12,m21,m22)`）、**R3**（拆出單步行列倍加與交換）、並實測**展開 8 步有界交替歐幾里得迴圈** `alg_ce_snf2_full_loop` | 即使降為 $2\times 2$ 純量並限制 `step < 8`，每步仍含 `m21 != 0`、`m11 == 0`、`q = m21 / m11` 三分支與 4 階行列式平方不變式 `(m11*m22 - m12*m21)² == det²`；實測 **CVC5 回傳 `Unknown (unknown + incomplete)`，Z3 回傳 `Timeout`**。若推廣至 $m\times n$ 含非整除修補則路徑數達 $>2^{3k}$。 | 於 `proof/fga_snf` 100% 證明：<br>1. `snf_diag_gcd_lcm_synth`（對角核）<br>2. `snf_bilateral_cert2_synth`（雙邊憑證）<br>3. `elem_row_add_det2_synth`、`elem_col_add_det2_synth`、`elem_row_swap_det2_synth`（三種單步消去算子）<br>4. `hnf_upper_det2_synth`（HNF 行列式橋接） |
| **ALG-CE-02** | `core::Mat::det`（$n \ge 4$ Bareiss 無分數高斯消去三重迴圈）<br>（`core/det.mbt`） | **R2**（消除迴圈與陣列，完全展開為純量 SSA 算式：實測 $n=2$、$n=3$、`alg_ce_bareiss4_det` $n=4$）、**R5**（改用第二代 `KronBlockMat` 張量樹分解） | **精確爆炸邊界實測**：<br>- **$n=2$（`det2`）**：1 VC，0.05s 證畢；<br>- **$n=3$（`bareiss3_det_synth`，9 變數、1 次整除 `/ a11`、4 階多項式）**：**6 個 VC 全部證畢（1.3s）**！<br>- **$n=4$（`alg_ce_bareiss4_det`，16 變數、5 次巢狀整除 `/ a11` 與 `/ m22`、8 階 Sylvester 多項式 24 項展開）**：5 個除零檢查 VC 通過，但**主後置條件 VC 在 CVC5 與 Z3 雙雙 Timeout**！ | 於 `proof` 與 `proof/fga_snf` 證明 $n=2$ (`det2`) 與 **$n=3$ 完整 Bareiss 消去 (`bareiss3_det_synth`)**；對 $n \ge 4$ 張量結構改於 `proof/mat2` 證明 `kronecker_det_diag2_synth`。 |
| **ALG-CE-03** | `latt::lll_reduce` & `latt::gram_schmidt`<br>（`latt/latt.mbt`：一般 $n$ 維格有理數 Gram–Schmidt 正交化與 Lovász 條件交換迴圈） | **R1**（分離么模與正交憑證）、**R2**（降為 2D/3D 整數基並消除 `Frac` 分母）、**R3**（拆出單步尺寸約化）、並實測**展開 8 步 2D Gauss/LLL 交換迴圈** `alg_ce_lll2_full_loop` | 在 `alg_ce_lll2_full_loop` 中，每步計算 `q = (ux*vx + uy*vy) / (ux² + uy²)` 並依 `n2 < n1` 分支交換基底；Why3 `split_vc` 分裂出 **9 個 VC**，其中 6 個不變式保持 VC 通過，但 **3 個涉及 `q = dot / n1` 終止條件 `4*dot² <= n1²` 之非線性後置條件 VC 在 CVC5 與 Z3 雙雙 Timeout**。一般 $n$ 維更需全主子式乘積位勢函數 $D = \prod \det(G_i)$。 | 於 `proof/latt` 100% 證明：<br>1. `gram2_covolume_lagrange_synth`（協體積恆等式）<br>2. `lll_size_reduce_step2_synth`（尺寸約化單步不變式）<br>3. `lll_shear2_reduce_synth`（2D 精確 LLL 核）<br>4. `lll_unit_lower3_reduce_synth`（3D 么模下三角 LLL 核） |
| **ALG-CE-04** | `latt::svp_box` & `latt::cvp_box`<br>（`latt/latt.mbt`：格上最短向量 SVP 與最近向量 CVP 之 $[-K, K]^n$ 指數盒窮舉搜尋演算法） | **R2**（固定為 2D 對角／剪切格）、**R6**（以 LLL Hermite 界 $\|b_1\|^2 \le 2^{n-1}\lambda_1^2$ 與熱帶賦值下界鬆弛取代精確盒窮舉） | `svp_box` 與 `cvp_box` 外層迴圈走訪 `total = (2k+1)^n` 個狀態，內層迴圈以 `% base` 與 `/ base` 解碼 $n$ 維座標並更新全局最小值；在 WP 中維護「已掃描之 $(2K+1)^n$ 前綴子集皆不小於 `best`」需對進位解碼函數作全稱量詞歸納，狀態數隨維度 $n$ 指數爆炸。 | 於 `proof/latt` 100% 證明：<br>1. `svp_lll_hermite_bound2_synth`（SVP Hermite 近似界）<br>2. `cvp_diag2_distance_synth`（CVP 候選格點距離平方非負與對稱性）<br>3. `parallelogram_norm_law2_synth`（範數平行四邊形律） |
| **ALG-CE-05** | `fga::all_subgroups`, `fga::subgroup_lattice` & `fga::elements`<br>（`fga/enum.mbt`：有限阿貝爾群元素笛卡兒積窮舉、子群生成閉包 BFS 不動點與 Hasse 覆蓋圖構造） | **R1**（提取 Lagrange 階整除驗證與不變因子分解）、**R2**（限制於小階阿貝爾群與初等 $p$-群） | `subgroup_closure` 使用佇列執行群加法 $\oplus$ 閉包直至集合大小不再增長（無界不動點迴圈），`subgroup_lattice` 再對所有子群三元組 $(H_i, H_j, H_k)$ 執行 $O(|S|^3 \cdot |G|)$ 包含性測試以消去非直接覆蓋邊；集合相等性與動態陣列在 WP 中產生二階集合量詞爆炸。 | 於 `proof/fga_snf` 100% 證明：<br>1. `lagrange_quotient_order_synth`（Lagrange 階整除定理）<br>2. `p_torsion_exponent_synth`（$p^k$-撓子群階計數）<br>3. `elementary_abelian_p_group_synth`（初等 $p$-群階與零化律）<br>4. `hom_ext_tor_tensor_cyclic_synth` & `pontryagin_bidual_invariants_synth` |
| **ALG-CE-06** | `spec::fft` & `spec::ifft`（任意 $N = 2^k$ 遞迴奇偶分治快速傅立葉變換）<br>（`spec/ops.mbt`） | **R2**（展開 $N=2$ 與 $N=4$ 無迴圈蝶形網絡）、**R5**（以第二代 `DispCircMat` 位移生成元壓縮循環矩陣）、改於商環 $\mathbb{Z}[\omega]/(\omega^2+1)$ 消去逐線 `% p` | 一般 $N = 2^k$ 之 `fft(a, w, p)` 在遞迴中動態配置 `even` 與 `odd` 陣列，並以迴圈計算旋轉因子冪次 `wk = (wk * w) % p`；要對任意 $k$ 證明 `ifft(fft(v)) == v`，需在遞迴陣列切片上形式化本原根幾何級數正交關係 $\sum_{j=0}^{N-1} \omega^{(m-r)j} \equiv N\delta_{mr}\pmod p$，同時觸發遞迴陣列別名與 `T-TO-06` 模算術超時。 | 於 `proof/synth` 與 `proof/spec` 100% 證明：<br>1. `butterfly_roundtrip_synth` & `butterfly_transform_synth`（2 點蝶形往返與 Parseval）<br>2. `dft4_roundtrip_synth`（**4 點 Radix-2 雙向蝶形往返互逆**）<br>3. `convolution_theorem2_synth` & `circulant_eigen_diag2_synth`（卷積定理與循環對角化） |
| **ALG-CE-07** | `curves::EC::points`, `EC::group_structure`, `isogeny_graph` & `padic::sl2_order_bruteforce`<br>（`curves/ec.mbt` & `padic/padic.mbt`：有限域點群 $O(p^2)$ 窮舉、雙生成元搜尋與 $\operatorname{SL}_2(\mathbb{Z}/p^n)$ $O(p^{4n})$ 四重迴圈窮舉） | **R1**（提取 Hasse 界、Frobenius 跡同餘與結構分解關係 `#E = p + 1 - t = d1 * d2`）、以閉式李群公式 $p^{3n-2}(p^2-1)$ 取代四重迴圈窮舉 | `EC::points` 需雙重迴圈掃描 $(x,y)\in [0,p)^2$ 測試三次同餘 $(y^2 - x^3 - ax - b)\bmod p == 0$；`sl2_order_bruteforce` 掃描 $a,b,c,d \in [0, p^n)$ 測試 $(ad-bc)\bmod p^n == 1$（在 $p=5, n=3$ 時達 $125^4 = 2.44\times 10^8$ 次迭代，連執行期都需切為閉式公式）。 | 於 `proof/curves_padic` 100% 證明：<br>1. `ec_hasse_trace_order_synth`（Hasse 界與點群階）<br>2. `ec_quadratic_twist_sum_synth`（二次扭轉點數守恆）<br>3. `tate_frobenius_cayley_hamilton_synth`（Tate 模 Frobenius 方程）<br>4. `sl2_zpn_order_skeleton_synth` & `so3_discrete_orthogonality_synth` |
| **ALG-CE-08** | `padic::Series::compose` & `padic::lift_to_ternary`<br>（`padic/padic.mbt` & `padic/fgpoly.mbt`：任意截斷階數 $D$ 之形式冪級數複合與三元多項式 $F(F(X,Y),Z)$ 展開演算法） | **R2**（提取乘法形式群律 $F_m(X,Y)=X+Y+XY$ 之精確代數多項式與二階形式對數 $2L_2(T)=2T-T^2$） | `lift_to_ternary(f, deg)` 將二元多項式複合為三元稀疏多項式陣列 `Array[(Int, Int, Int, Int64)]`，在截斷次數 $D$ 下包含 $\binom{D+3}{3}$ 個單項式，每次乘法與同類項合併需 $O(D^6)$ 巢狀迴圈與有理係數 `Frac` 通分，在 WP 中造成動態陣列與多項式次數爆炸。 | 於 `proof/curves_padic` 100% 證明：<br>1. `formal_group_mult_axioms_synth`（乘法形式群律之單位、交換與**三元結合律**）<br>2. `formal_log_deg2_grouplaw_synth`（二階形式對數群同態） |
| **ALG-CE-09** | `mat2::poly_pencil_snf2` & `mat2::PolyFp::div_mod` / `gcd`<br>（`mat2/mat2.mbt`：有限域多項式環 $\mathbb{F}_p[x]$ 帶模逆元歸一化之長除法、擴展歐幾里得與 $\lambda$-矩陣雙邊消去演算法） | **R2**（提取 $2\times 2$ 特徵鉛筆 $xI - A$ 之行列式、跡與特徵判別式 $\Delta = \operatorname{tr}(A)^2 - 4\det(A)$ 分離算子） | `PolyFp::div_mod` 在 `while r.deg() >= b.deg()` 迴圈中每步呼叫 `invmod(lead_b, p)` 計算最高次項商係數並更新係數陣列；`poly_pencil_snf2` 外層再嵌套行列消去與非整除修補，同時結合了 `ALG-CE-01` 的多分支消去與 `T-TO-05` 的模 $p$ 逆元非線性算術。 | 於 `proof/mat2` 100% 證明：<br>1. `poly_pencil_separation_synth`（證明么模剪切族與雙曲 Frobenius 族在 $\det=1$ 下由多項式鉛筆判別式 $\Delta = 0$ vs $k(k+4) > 0$ 嚴格分離） |
| **ALG-CE-10** | `synth::superoptimize`, `synth::cegis_synth_*`, `synth::cvec_mine_equivalences` & `dsl::parse_program` / `eval`<br>（`synth/synth.mbt` & `dsl/dsl.mbt`：代數 AST 等式飽和不動點迴圈、CEGIS 候選搜尋與遞迴下降語法剖析器） | **R1/R3**（將 E-Graph 內部的每一條代數重寫規則、CEGIS 合成出的目標演算法、以及 DSL 的每一條規範形等價律拆出為獨立純量算子） | 元層（Meta-level）重寫引擎 `superoptimize` 在遞迴代數資料型別 `AlgExpr` 上執行樹狀模式匹配直至不動點；`dsl::parse_program` 在字串 Token 流上執行互遞迴下降剖析。對無界深度 AST 與字串陣列做直接 WP 驗證會產生互遞迴結構歸納爆炸。 | 於 `proof/synth`（22 VC）與 `proof/curves_padic`（`dsl_canonical_equivalence_synth`）**100% 證明所有被 E-Graph 使用的重寫規則、CEGIS 合成出的目標算子（Karatsuba、CH、修補除法）與 DSL 四大規範形等價律**。 |

---

## 五、全專案一鍵重現與檢核指令

```bash
export PATH="$HOME/.moon/bin:$PATH"
cd /home/user/supermatrix

# 1. 逐一執行九大形式化證明套件（150 / 150 VC 全部消解，0 未決）
for pkg in proof/algebra proof/bridge proof/synth proof/mat2 proof/fga_snf proof/latt proof/spec proof/curves_padic proof; do
  moon prove "$pkg" --why3-config why3-long.conf
done

# 2. 同步形式化證明帳本（自動生成 corpus/proof_ledger.mbt：G1=155, G2=0, G3=9, G4=10）
python3 tools/sync_proof.py

# 3. 靜態型別檢查與 45 個執行期單元測試（100% 通過）
moon check
moon test --target wasm-gc

# 4. 輸出全領域形式化證明與略過項目審計報告（含 T-TO-01..09 與 ALG-CE-01..10）
moon run cmd/main --target wasm-gc -- proof-audit

# 5. 輸出全語料庫統計（3771 / 3771 條，100.00% 通過）
moon run cmd/main --target wasm-gc -- stats
```
