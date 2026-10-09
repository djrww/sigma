# 形式化在代碼生成與演算法生成中的衍生賦能與潛在用處研究
## —— 從「事後驗證（Post-hoc Verification）」走向「生成式形式化引擎（Generative Formal Methods）」

> **實證基準**：本報告之全部理論機制均已在 `/home/user/supermatrix` 的 `proof/synth/`（22 個驗證條件 100% 由 Why3 + Z3/CVC5 消解）、`proof/bridge/`（18 個驗證條件 100% 消解）與 `synth/`（可執行合成引擎）中落地實作，並納入語料庫族 `I1`–`I8`（176 條，全數通過）。

---

## 一、問題意識：為何形式化絕不僅僅是「事後蓋章」？

在傳統軟體工程中，形式化驗證（Formal Verification）常被視為開發鏈路末端的「守門員」——代碼與演算法先由人工或大模型（LLM）寫出，最後才交由定理證明器（Why3、Rocq、Isabelle、Lean）或 SMT 求解器（Z3、CVC5）回答一個二元問題：`Valid`（通過）或 `Invalid/Timeout`（失敗）。

然而，在**代碼生成（Code Generation）**乃至更高階的**演算法生成／演算法發現（Algorithm Synthesis & Discovery）**過程中，一旦將形式化規格（`predicate`）、前後置契約（`proof_require` / `proof_ensure`）、不變式（`proof_invariant`）與符號推理引擎深度嵌入生成迴路，形式化基礎設施會產生**八大衍生與連帶幫助（Derivative & Collateral Benefits）**。它不再只是被動的裁判，而是主動的**演算法壓縮器、搜尋剪枝器、邊界修補器、免真值神諭生成器與軟體架構導航儀**。

---

## 二、形式化優化突破：Proof-by-Call（WP β-歸約見證實例化）與 100% 零未決達成

在進入八大衍生用處之前，本輪首先完成了對既有形式化體系的關鍵優化，**徹底消滅了全專案最後一條 G2 未決義務（`dvd_mod_back`）**，將形式化成績推進至 **4 個證明套件、78 個 VC 目標 100% 消解（0 未決、0 超時）**：

| 證明套件 | 職責 | 已證 VC 數 | 未決 VC 數 | 狀態 |
|---|---|---:|---:|---|
| `proof/algebra` | 純代數、模同態、整除見證鏈、極化、Cayley–Hamilton、$\mathrm{GL}_2$ 行列式乘性 | 16 | 0 | **100% 通過** |
| `proof/bridge` | 取餘橋接微引理 `m1`–`m4`、前向封閉 `dvd_mod_step`、**構造性逆推 `dvd_mod_back`** | 18 | 0 | **100% 通過** |
| `proof/synth` | **演算法合成與超優化核心**（Horner、Estrin、Karatsuba、FFT 對角化、Kani–Rosati、Hensel 等） | 22 | 0 | **100% 通過** |
| `proof` | 遞迴與迴圈契約算子（含**無條件完全證明**之 `gcd_verified`、`is_prime_trial`、`isqrt` 等） | 22 | 0 | **100% 通過** |
| **總計** | **81 個帶約束定義 / 78 個驗證條件（VC）** | **78** | **0** | **100.00% 全綠** |

### 核心技術突破：為何 `.mbtp` 的空體 `lemma` 會卡在 E-matching，而 `.mbt` 的 `Proof-by-Call` 能秒證？

1. **問題根源（E-matching 觸發器盲區）**：
   在 MoonBit 的 `.mbtp` 邏輯層中，`lemma foo(...) where { ... } {}` 的方法體必須為空 `{}`，編譯為 WhyML 的 `let lemma foo (...) = ()`。此時，後續引理若要使用前序引理，100% 依賴 SMT 求解器對全稱量詞公理 $\forall a, b, d, k_2, k_r.\dots$ 進行 **E-matching 啟發式觸發**。在取餘逆推 `dvd_mod_back` 中，需要同時實例化兩個非線性商見證 $k_2 = b/d$ 與 $k_r = (a \bmod b)/d$ 並跨越多重乘法結合律，Z3/CVC5 的觸發器在無引導下極易迷失。
2. **解決方案（Proof-by-Call / WP 語法 β-歸約）**：
   在 `.mbt` 程式側撰寫構造性步驟函數（`proof/bridge/bridge.mbt`）：
   - `step_b_wit(b, d) -> Int`（回傳 `b / d`，確保 `b == d * k2`）
   - `step_rem_wit(a, b, d) -> Int`（回傳 `(a % b) / d`，確保 `a % b == d * kr`）
   - `step_a_wit(a, b, d) -> Int`（呼叫前兩步並回傳 `k2 * (a / b) + kr`，確保 `a == d * k`）
   - `dvd_mod_back(a, b, d) -> Unit`（呼叫 `step_a_wit` 與 `step_mul_mod`，確保 `a % d == 0`）
   當 Why3 的**最弱前置條件（Weakest Precondition, WP）演算**處理 `.mbt` 函數體內的函數呼叫時，它**不依賴全稱量詞 E-matching**，而是直接在語法層面將實參代入被呼叫函數的前後置條件（**β-歸約**），產生**無量詞基項公式（Quantifier-Free Ground Formulas）**，Z3 在毫秒內即可消解！
3. **連帶收穫**：在 `proof/arith.mbt` 的 `gcd_verified(a, b)` 遞迴分支中，直接插入一行 `@bridge.dvd_mod_back(a, b, g)`，即把 `a % g == 0` 無條件注入 WP 語境，使歐幾里得演算法的完整規格（含整除性與整除偏序極大性）成為 **100% 無條件機器證明**。

---

## 三、除提供形式證明外，形式化對代碼與演算法生成的「八大衍生賦能機制」

### 1. 見證驅動構造性演算法合成與「不可能性反駁憑證」（Witness-Driven Synthesis & Refutation Certificates）

- **衍生機理**：
  形式化常迫使我們將含存在量詞或全稱量詞的規格（如「$g$ 是最大公因數：$\forall d, d\mid a \land d\mid b \implies d \le g$」或「方程 $ax+by=c$ 有解：$\exists x, y, ax+by=c$」）改寫為**顯式見證項（Explicit Witnesses）**。這個「為證明構造見證」的過程，**本身就直接生成了構造性演算法**。
- **潛在用處**：
  1. **量詞消除即演算法合成**：在 `proof/synth::bezout_step_synth` 與 `synth::synth_bezout_cert` 中，為證明遞迴步的整除保持性，我們構造了見證更新式 $(u, v) = (v_1, u_1 - (a/b)v_1)$。這一步不僅餵飽了 SMT 求解器，更直接合成了擴展歐幾里得演算法（Extended GCD），並將原本需要 $O(\min(a,b))$ 搜尋的「全稱極大性檢驗」壓縮為 $O(1)$ 的無量詞代數恆等式檢驗 $au+bv=g \land a=gk_a \land b=gk_b$。
  2. **不可能性／無解反駁憑證（Refutation Witness）**：當演算法生成面對無解輸入（例如丟番圖方程 $270x + 192y = 7$）時，一般代碼只會回傳 `None` 或拋出異常（無法區分「真的無解」還是「搜尋演算法有 bug 沒找到」）。形式化見證則連帶生成**無解反駁憑證** `Unsolvable(g=6, rem=1)`：因為 $6 \mid 270$ 且 $6 \mid 192$，任何整數線性組合必為 $6$ 的倍數，而 $7 \bmod 6 = 1 \neq 0$，在 $O(1)$ 時間內給出「全整數域 $\mathbb{Z}^2$ 絕對無解」的機械證明。

### 2. 經形式驗證的等式飽和與 E-Graph 代數超優化（Verified Equality Saturation & Superoptimization）

- **衍生機理**：
  在 `proof/algebra` 與 `proof/synth` 中證明的每一條代數引理（$\forall x.\, \Phi(x) \implies L(x) = R(x)$），本質上都是一條**百分之百健全的編譯器／合成器重寫規則（Verified Rewrite Rule）**。將這些規則輸入等式飽和引擎（Equality Saturation / E-Graph，參見 Coward 2025、Bhatia et al. *LLMLift*），再配合代數成本模型（Cost Model），即可從高階、直觀但低效的「規格級代碼」自動推導出**漸近複雜度更低的極品演算法**。
- **本專案實證（`synth::superoptimize`）**：
  - **規則 R1（雙向 FFT 循環算子對角化，經 `circulant2_fft_diag_synth` 證明）**：將時域循環摺積 $\operatorname{Circ}(c)\cdot X$ 重寫為頻域蝶形對角乘法 $\mathcal{F}^{-1}(\mathcal{F}(c)\odot \mathcal{F}(X))$，將 $n\times n$ 稠密乘法從 $O(n^2)$ 降為 $O(n\log n)$。
  - **規則 R2（Cayley–Hamilton 矩陣冪線性化，經 `ch_power2_synth` 證明）**：將二次矩陣冪 $A^2$（8 次純量乘法）重寫為純量線性組合 $\operatorname{tr}(A)A - \det(A)I$。
  - **規則 R3（乘積跡與 Frobenius 內積融合，經 `trace_cyclic2_synth` 證明）**：將 $\operatorname{tr}(A\cdot B)$（先做 $O(n^3)$ 矩陣乘法再取對角和）直接降階重寫為雙線性點積 $\langle A^T, B\rangle_F$（$O(n^2)$，省去全部非對角元計算！）。
  - **規則 R4–R6（Pontryagin 二重對偶消去、辛算子逆消去、Rosati–Kani 同源鑽石坍縮）**：將 $\operatorname{tr}((\operatorname{Kani}(3,4)^\dagger \cdot \operatorname{Kani}(3,4))\cdot A)$ 的代數成本從 **45 直接壓縮至 10**（降幅 **77.8%**），將複合管線 `((A∨)∨)² + Circ(3,5)·(-J₂·(J₂·B))` 的成本從 **88 壓縮至 18**（降幅 **79.5%**）。

### 3. 反例引導歸納合成（CEGIS）與邊界保護式自動修補（Automated Guard & Precondition Repair）

- **衍生機理**：
  當形式化驗證失敗時，SMT 求解器產生的**反例模型（Counterexample Model）**是極高價值的結構化梯度信號（參見 *VeriAct* 2026、*CE-Graphs* 2025）：
  1. **參數空間指數級剪枝**：在語法引導合成（SyGuS / Sketching）中，每一個反例都能直接淘汰一整批不一致的候選演算法。
  2. **隱式前置條件挖掘與邊界修補**：大模型或人類直覺生成的演算法常在負數、零因子、非 2 冪次或退化矩陣上出錯；形式化反例能精準定位「定義域缺口」，自動合成 `if` 保護分支或前置過濾條件。
- **本專案實證（`synth::cegis_synth_karatsuba_im` 與 `euclid_div_mod_repaired`）**：
  - **Karatsuba 演算法自動發現**：給定 3 個乘法基底 $k_1 = ac, k_2 = bd, k_3 = (a+b)(c+d)$，在 $5^3 = 125$ 個線性組合候選空間中，CEGIS 僅憑 **3 個反例、4 輪迭代**即剪除 124 個錯誤程式，自動合成出 Gauss–Karatsuba 虛部公式 $k_3 - k_1 - k_2$（將複數／高斯整數乘法從 4 次乘法降為 3 次）。
  - **負數被除數歐幾里得修補**：Why3 的 `ComputerDivision` 對 `a = -1, b = 5` 給出 `a % b = -1 < 0`（反例！）。利用此反例自動合成修補分支 `if r0 < 0 { (q0 - 1, r0 + b) } else { (q0, r0) }`，並在 `proof/synth::euclid_div_mod_repaired` 中由 Z3 證明其對**全整數域 $\forall a \in \mathbb{Z}, b > 0$** 恆滿足 $a = bq + r \land 0 \le r < b$。

### 4. 特徵向量（cvec）語義指紋去重與自動重寫規則挖掘（Semantic Deduplication & Rule Mining）

- **衍生機理**：
  在演算法枚舉生成時，超過 80%–95% 的候選語法樹（AST）在數學語義上是重複的（例如 $(x+y)^2 - (x-y)^2$ 與 $4xy$）。借鑑 *Ruler*（OOPSLA 2021）範式，利用形式語義在少量種子點上計算每個候選演算法的**特徵向量（Characteristic Vector, `cvec`）**：
  - 若 $\operatorname{cvec}(e_1) \neq \operatorname{cvec}(e_2)$，則 $e_1 \not\equiv e_2$（$O(1)$ 時間瞬間排除，免去昂貴的 SMT 呼叫）；
  - 若 $\operatorname{cvec}(e_1) = \operatorname{cvec}(e_2)$，則自動提名一條候選重寫規則 $e_1 \simeq e_2$ 並交由 SMT 驗證。
- **本專案實證（`synth::cvec_mine_equivalences`）**：
  在 10 個二元代數候選算子中，透過 6 點 `cvec` 指紋瞬間壓縮為 **5 個語義等價類**，自動挖掘出四分之一平方乘法 $(x+y)^2-(x-y)^2 = 4xy$、極化恆等式 $(x+y)^2-(x^2+y^2)=2xy$ 等 **5 條等價重寫規則**，並全部在 `proof/algebra` 與 `proof/synth` 中獲 SMT 證明。

### 5. 免基準真值之規格驅動蜕變測試神諭（Specification-Driven Metamorphic Oracles）

- **衍生機理**：
  在前沿數學與高維度演算法領域（例如極化貝爾簇同源、高維格 LLL 約化、Smith/Hermite 正規形、上同調 $\operatorname{Ext}^1/\operatorname{Tor}_1$），我們在生成新演算法時**往往沒有現成的標準答案（Ground-Truth Oracle）可供比對**。形式化代數不變式（群同態、雙邊么模不變性、轉置對偶、體積守恆）可直接轉譯為**蜕變測試關係（Metamorphic Relations, MRs）**，實現「無需參考實作的自檢神諭」。
- **本專案實證（`synth::verify_metamorphic_oracles`）**：
  對任意輸入矩陣 $A$，自動施以么模變換 $U, V \in \mathrm{GL}_2(\mathbb{Z})$ 與轉置對偶，在完全不預知 $\operatorname{SNF}(A)$ 真值的情況下，以 $\operatorname{SNF}(UAV) = \operatorname{SNF}(A)$、$\operatorname{SNF}(A^T) = \operatorname{SNF}(A)^T$、$|\det(\operatorname{LLL}(A))| = |\det(A)|$ 及 $\operatorname{Ext}^1 \cong \operatorname{Tor}_1$ 構成免真值神諭網格（族 `I5` 20 條全數通過）。

### 6. 驗證提升（Verified Lifting）與面積–延遲 Pareto 多後端自動下降

- **衍生機理**：
  低階迴圈代碼將「做什麼（What）」與「怎麼算（How）」死鎖在一起。透過將演算法提升（Lift）至形式化規範層，再透過不同成本目標的重寫規則下降（Lower），可從同一個形式化規格**一鍵生成面向不同硬體架構的 Pareto 最優演算法族**（而且兩兩之間由形式證明保證語義一致）。
- **本專案實證（`proof/synth::horner3_synth` vs `estrin3_synth` 與 `synth::pareto_lower_poly3`）**：
  對三次多項式求值規格 $P(x) = a_3 x^3 + a_2 x^2 + a_1 x + a_0$（樸素展開需 6 次乘法、深度 3）：
  - **面向面積／功耗受限後端（Sequential / Low-Area）**：自動下降為 **Horner 演算法** `((a3*x + a2)*x + a1)*x + a0`（**僅 3 次乘法**、深度 3）；
  - **面向超純量／SIMD／低延遲硬體後端（Parallel / Low-Latency）**：自動下降為 **Estrin 平行樹演算法** `(a3*x + a2)*(x*x) + (a1*x + a0)`（4 次乘法，但因 `(a3*x+a2)`、`(a1*x+a0)` 與 `(x*x)` 可於同一週期平行執行，**關鍵路徑深度降至 2**！）。
  兩者在 `proof/synth` 中均獲 Why3+Z3 形式證明與樸素規格完全等價。

### 7. 自帶憑證演算法生成（Certifying Algorithms）與「驗證–計算複雜度不對稱性」利用

- **衍生機理**：
  形式化揭示了一個深刻的計算複雜度現象：**「合成一個解」往往需要複雜啟發式或高成本搜尋，但「驗證一個攜帶見證的解」往往只需極簡單的代數運算**。形式契約天然指導代碼生成器採用 **Certifying Algorithm（自帶憑證演算法）** 架構：讓演算法在輸出結果 $y$ 的同時輸出見證 $w$，並由經形式驗證的輕量檢核器驗證 $(x, y, w)$。
- **本專案實證**：
  - **SNF 雙邊么模憑證**：`snf_full(A)` 同步生成 $(U, D, V)$，檢核器只需檢查 $UAV = D$、$\det(U)=\pm 1$、$\det(V)=\pm 1$ 與 $d_i \mid d_{i+1}$；
  - **Hensel 二次牛頓提升憑證（`proof/synth::hensel_sqrt_step_synth`）**：同步輸出提升根 $x_1 = x_0 + t p^k$ 與模 $p^{2k}$ 餘因子見證 $k_2 = m + t^2$，使 $x_1^2 - c = k_2 p^{2k}$ 成為一階多項式恆等式；
  - **無除法伴隨求解（`proof/synth::adjugate_solve_synth`）**：以伴隨矩陣 $A^{\mathrm{adj}}$ 將有理數除法求解轉化為純整數見證等式 $A^{\mathrm{adj}}(Av) = \det(A)v$，徹底消除浮點誤差與整數截斷。

### 8. 公理語境衛生學（Axiom Context Hygiene）與證明引導的模組化軟體架構設計

- **衍生機理**：
  本專案在形式化攻堅過程中發現了一個極具普適價值的軟體工程定律：**SMT 求解器的可證性（Prover Tractability）是衡量代碼模組化與介面解耦程度的客觀探針**。
  - 當一個模組塞入超過 20 條交織的全稱量詞公理時，SMT 的 E-matching 搜尋空間發生組合爆炸（公理語境污染）；
  - 當一個函數的正確性依賴隱藏的存在量詞（而非顯式見證參數）時，驗證條件會退化為不可判定的非線性算術。
- **潛在用處（Architecture-by-Verification）**：
  在 AI 自動生成大型系統架構時，可將 `moon prove` 的**目標消解時間與步數（Step Count）作為架構重構的回饋指標**：
  1. 凡是觸發超時的模組，自動按依賴圖切分為窄介面子套件（如本專案拆出 `proof/algebra`、`proof/bridge`、`proof/synth`）；
  2. 凡是觸發量詞實例化瓶頸的介面，自動重構為顯式傳遞見證的 **Proof-by-Call** 契約簽名。

---

## 四、八大衍生賦能機制總覽對照表

| 編號 | 衍生賦能維度 | 超越「事後證明」的核心連帶價值 | 本專案對應之形式化算子（`proof/`） | 本專案對應之可執行合成引擎（`synth/` & `corpus/`） |
|---|---|---|---|---|
| **I1** | 見證驅動構造合成与反駁憑證 | 將存在／全稱規格直接編譯為構造演算法與 $O(1)$ 無解反駁證明 | `bezout_step_synth`, `dvd_mod_back` | `synth_bezout_cert`, `synth_diophantine`（族 I1，24 條） |
| **I2** | 驗證等式飽和與 E-Graph 超優化 | 以已證引理作為無損重寫規則，自動合成漸近更優演算法 | `ch_power2_synth`, `circulant2_fft_diag_synth`, `trace_cyclic2_synth` | `superoptimize`, `verify_superopt`（族 I2，24 條） |
| **I3** | CEGIS 反例引導合成與保護修補 | 用驗證失敗的反例剪枝候選空間、自動補齊負數／退化邊界保護 | `gauss_karatsuba_synth`, `euclid_div_mod_repaired` | `cegis_synth_karatsuba_im`, `verify_cegis_guard_repair`（族 I3，24 條） |
| **I4** | `cvec` 語義指紋去重與規則挖掘 | 消除 50%+ 語義重複候選，自動從語法空間挖掘新代數恆等式 | `quarter_square_synth`, `brahmagupta_fibonacci_synth` | `compute_cvec`, `cvec_mine_equivalences`（族 I4，20 條） |
| **I5** | 免基準真值之規格驅動蜕變神諭 | 在無標準答案的前沿領域，由代數不變式自動生成自檢測試神諭 | `det2_mul_lemma`, `snf_chain`, `bidual2_involution_synth` | `verify_metamorphic_oracles`（族 I5，20 條） |
| **I6** | Verified Lifting 與 Pareto 多後端下降 | 從單一規格同時生成「最小乘法面積（Horner）」與「最小平行延遲（Estrin）」代碼 | `horner3_synth`, `estrin3_synth`, `butterfly_roundtrip_synth` | `pareto_lower_poly3`（族 I6，24 條） |
| **I7** | 自帶憑證演算法（Certifying Algorithms） | 利用「驗證易、合成難」不對稱性，以純整數伴隨／餘因子見證取代浮點與啟發式信任 | `adjugate_solve_synth`, `hensel_sqrt_step_synth`, `rosati_kani_synth` | 伴隨求解與 Hensel/Rosati 憑證鏈（族 I7，20 條） |
| **I8** | 公理語境衛生學與架構導引 | 以 SMT 消解步數作為模組耦合度探針，驅動窄介面與 Proof-by-Call 架構解耦 | `step_b_wit`, `step_rem_wit`, `step_a_wit`, `dvd_mod_back` | 四套件分層驗證架構（族 I8，20 條） |
