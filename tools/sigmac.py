#!/usr/bin/env python3
"""
tools/sigmac.py —— Σ-密碼學領域特定語言 (sigma DSL) 外部建置圖轉譯器 (AOT Pre-Build Transpiler)

對接 MoonBit 官方建置系統 `moon.pkg` 之 `rule` 與 `dev_build` 機制：
  rule(name: "sigmac", command: "python3 tools/sigmac.py $input $output")
  dev_build(rule: "sigmac", input: "sigma/crypto_suite.sigma", output: "sigma/generated_suite.mbt")

執行 `moon check`、`moon build` 或 `moon test` 時，MoonBit 官方建置器自動調用本轉譯器，
將 `.sigma` 密碼學規格與政策宣告預編譯為類型安全、零警告之 MoonBit 源碼 `.mbt`。
"""

import re
import sys
from pathlib import Path


def parse_sigma_file(src: str):
    policies = []
    ciphers = []
    for raw_line in src.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("//"):
            continue
        m_pol = re.match(r"^policy\s+([a-zA-Z0-9_]+)\s*=\s*([a-zA-Z0-9_]+)\s*;$", line)
        if m_pol:
            policies.append((m_pol.group(1), m_pol.group(2)))
            continue
        m_cip = re.match(r"^cipher\s+([a-zA-Z0-9_]+)\s*=\s*(.+)\s*;$", line)
        if m_cip:
            ciphers.append((m_cip.group(1), m_cip.group(2).strip()))
            continue
    return policies, ciphers


def emit_moonbit(policies, ciphers) -> str:
    lines = [
        "///|",
        "/// sigma/generated_suite.mbt —— 由 `tools/sigmac.py` 透過 `moon.pkg` 之 `dev_build` 自動轉譯生成。",
        "/// 來源檔案：sigma/crypto_suite.sigma（請勿手動修改本檔案）。",
        "",
        "///|",
        "/// 由 `.sigma` 頂層 `policy` 宣告轉譯出的安全與優化政策表。",
        "pub fn generated_suite_policies() -> Array[(String, String)] {",
        "  [",
    ]
    for k, v in policies:
        lines.append(f'    ("{k}", "{v}"),')
    lines += [
        "  ]",
        "}",
        "",
        "///|",
        "/// 由 `.sigma` 頂層 `cipher` 宣告轉譯出的密碼學套件規格表。",
        "pub fn generated_suite_ciphers() -> Array[(String, String)] {",
        "  [",
    ]
    for name, expr in ciphers:
        escaped = expr.replace('"', '\\"')
        lines.append(f'    ("{name}", "{escaped}"),')
    lines += [
        "  ]",
        "}",
        "",
    ]
    for name, expr in ciphers:
        escaped = expr.replace('"', '\\"')
        lines += [
            "///|",
            f"/// AOT 轉譯生成之密碼學算子入口：`{name}`。",
            f"pub fn compiled_{name}() -> SigmaCert {{",
            f'  eval_cipher_spec("{name}", "{escaped}", default_policy_config())',
            "}",
            "",
        ]
    lines += [
        "///|",
        "/// 一鍵驗證 `sigma/crypto_suite.sigma` 轉譯出的全部密碼學套件與義務自證憑證。",
        "pub fn verify_all_compiled_ciphers() -> Bool {",
    ]
    if not ciphers:
        lines.append("  true")
    else:
        conds = [f"compiled_{name}().ok" for name, _ in ciphers]
        lines.append("  " + " &&\n  ".join(conds))
    lines += [
        "}",
        "",
    ]
    return "\n".join(lines)


def main():
    if len(sys.argv) != 3:
        print("用法: python3 tools/sigmac.py <input.sigma> <output.mbt>", file=sys.stderr)
        sys.exit(1)
    inp = Path(sys.argv[1])
    out = Path(sys.argv[2])
    src = inp.read_text(encoding="utf-8")
    policies, ciphers = parse_sigma_file(src)
    mbt_code = emit_moonbit(policies, ciphers)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(mbt_code, encoding="utf-8")


if __name__ == "__main__":
    main()
