#!/bin/sh
# 以原始 SMT-LIB（z3）獨立檢查 proof/bridges.smt2 中的取餘橋接陳述。
# 預期輸出：四個 "unsat"（各否定式不可滿足）。
cd "$(dirname "$0")/.." || exit 1
exec z3 proof/bridges.smt2
