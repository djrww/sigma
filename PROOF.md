# Σ-超矩陣框架：形式化驗證快速索引（Verification Quick Reference）

> 完整定理逐族對照、七大減複雜度措施、9 條實測超時略過定理（`T-TO-01`–`T-TO-09`）與 10 條組合爆炸略過演算法（`ALG-CE-01`–`ALG-CE-10`）之詳盡報告，請參閱 [`FORMAL_PROOF_REPORT.md`](FORMAL_PROOF_REPORT.md)。

## 1. 一鍵重現全專案形式化證明

```bash
export PATH="$HOME/.moon/bin:/usr/local/bin:$PATH"
for pkg in proof/algebra proof/bridge proof/synth proof/mat2 proof/fga_snf proof/latt proof/spec proof/curves_padic proof; do
  moon prove "$pkg" --why3-config why3-long.conf
done
python3 tools/sync_proof.py
```

## 2. 九大驗證套件匯總（150 / 150 VC 已證，0 未決）

| 套件 | 已證 VC | 未決 VC | 帶約束定義 | 核心領域 |
|---|---:|---:|---:|---|
| `proof/algebra` | 16 | 0 | 17 | 模同態、整除見證鏈、極化純量核、2×2 Cayley–Hamilton、$\operatorname{GL}_2$ 行列式乘性 |
| `proof/bridge` | 18 | 0 | 17 | 截斷除法微引理 `m1`–`m4`、前向封閉 `dvd_mod_step`、Proof-by-Call 逆推 `dvd_mod_back` |
| `proof/synth` | 22 | 0 | 22 | Horner/Estrin、Karatsuba、CH 降階、無除法伴隨求解、Bézout 步、蝶形 DFT、Rosati–Kani、Hensel 提升 |
| `proof/mat2` | 11 | 0 | 12 | Grassmann 超矩陣 Berezinian 乘法性、Kronecker 跡與行列式、多項式鉛筆、Tropical 半環、位移交換子 |
| `proof/fga_snf` | 19 | 0 | 20 | SNF/HNF 代數核、阿貝爾群結構定理、Hom/Ext/Tor/Tensor、Pontryagin 雙對偶、CRT、3×3 Bareiss Sylvester 恆等式 |
| `proof/latt` | 13 | 0 | 13 | Gram 對稱非負、協體積 Lagrange 恆等式、2D/3D LLL 么模逆元、尺寸約化、對偶格雙正交、SVP/CVP、平行四邊形律 |
| `proof/spec` | 14 | 0 | 14 | 4 點雙向傅立葉蝶形往返互逆、卷積定理、循環對角化、2D/3D 伴隨、辛剪切、偶／奇分次超跡消沒、三次容斥極化 |
| `proof/curves_padic` | 15 | 0 | 15 | Hasse 界、二次扭轉點數守恆、Vélu 2-/3-同源、Tate 模、Teichmüller、乘法形式群三公理、形式對數、$\operatorname{SL}_2/\operatorname{SO}(3)$、DSL 等價律 |
| `proof` | 22 | 0 | 25 | 絕對值、正模約化、三角形數、整數平方根 `isqrt`、質數試除健全性、模冪、無條件完全證明之 `gcd_verified` |
| **合計** | **150** | **0** | **155** | **另於 `G3`/`G4` 略過並記錄：超時定理 9 條、組合爆炸演算法 10 條** |
