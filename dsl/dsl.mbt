///|
/// dsl/dsl.mbt —— Σ-演算（Sigma-Calculus）：本框架的嵌入式 DSL。
///
/// 設計動機（對應命題「全部喺同一個框架入面互通」）：
///   分解、組合、商、同態、張量、Ext、上同調、格約化、可除判定、
///   雅可比構造、Mordell–Weil、Tate 模、Pontryagin 對偶
/// 在 DSL 中都是「同一個值域上的算子」；值域帶規範形（canonical form），
/// 於是「兩條語句是否等價」被化約為「規範形是否相同」——可機器判定。
///
/// 語法：
///   program  := stmt (";" stmt)*
///   stmt     := call | expr
///   expr     := term (("+"|"-") term)*
///   term     := unary ("*" unary)*
///   unary    := "-" unary | atom
///   atom     := INT | IDENT | "[" rows "]" | "(" expr ")" | IDENT "(" args ")"
///   rows     := row (";" row)* ; row := expr (","? expr)*

///|
/// 記號。
pub enum Tok {
  TNum(Int64)
  TId(String)
  TLP
  TRP
  TLB
  TRB
  TSemi
  TComma
  TPlus
  TMinus
  TStar
  TEnd
} derive(Eq)

///|
/// 顯式提升 Eq 方法為 Tok 常規方法（v0.10.14 起隱式提升已棄用）。
pub extend Tok with Eq::{not_equal, equal}

///|
/// 詞法分析。
pub fn tokenize(src : String) -> Array[Tok] {
  let out : Array[Tok] = []
  let n = src.length()
  let mut i = 0
  while i < n {
    let c = match src.get_char(i) {
      Some(ch) => ch
      None => ' '
    }
    if c == ' ' || c == '\n' || c == '\t' || c == '\r' {
      i = i + 1
      continue
    }
    if c == '#' {
      // 註解到行尾
      while i < n {
        let ch = match src.get_char(i) {
          Some(x) => x
          None => ' '
        }
        if ch == '\n' {
          break
        }
        i = i + 1
      }
      continue
    }
    if c.is_ascii_digit() {
      let mut v = 0L
      while i < n {
        let ch = match src.get_char(i) {
          Some(x) => x
          None => ' '
        }
        if !ch.is_ascii_digit() {
          break
        }
        v = v * 10L + (ch.to_int() - 48).to_int64()
        i = i + 1
      }
      out.push(TNum(v))
      continue
    }
    if c.is_ascii_alphabetic() || c == '_' {
      let sb = StringBuilder()
      while i < n {
        let ch = match src.get_char(i) {
          Some(x) => x
          None => ' '
        }
        if ch.is_ascii_alphabetic() || ch.is_ascii_digit() || ch == '_' {
          sb.write_char(ch)
          i = i + 1
        } else {
          break
        }
      }
      out.push(TId(sb.to_string()))
      continue
    }
    let tok = match c {
      '(' => TLP
      ')' => TRP
      '[' => TLB
      ']' => TRB
      ';' => TSemi
      ',' => TComma
      '+' => TPlus
      '-' => TMinus
      '*' => TStar
      _ => TId("?")
    }
    out.push(tok)
    i = i + 1
  }
  out.push(TEnd)
  out
}

///|
/// 抽象語法。
pub enum Expr {
  ENum(Int64)
  EId(String)
  EMat(Array[Array[Expr]])
  ECall(String, Array[Expr])
  EBin(String, Expr, Expr)
  ENeg(Expr)
}

///|
/// 解析器（遞迴下降）。
pub struct Parser {
  toks : Array[Tok]
  mut pos : Int
}

///|
/// 建立解析器。
pub fn Parser::new(toks : Array[Tok]) -> Parser {
  { toks, pos: 0, }
}

///|
/// 當前記號。
pub fn Parser::peek(self : Parser) -> Tok {
  if self.pos < self.toks.length() {
    self.toks[self.pos]
  } else {
    TEnd
  }
}

///|
/// 前進一格。
pub fn Parser::bump(self : Parser) -> Unit {
  self.pos = self.pos + 1
}

///|
/// 解析完整程式。
pub fn parse_program(src : String) -> Array[Expr] {
  let p = Parser::new(tokenize(src))
  let out : Array[Expr] = []
  while true {
    match p.peek() {
      TEnd => break
      TSemi => p.bump()
      _ => {
        out.push(parse_expr(p))
        match p.peek() {
          TSemi => p.bump()
          TEnd => ()
          _ => p.bump()
        }
      }
    }
  }
  out
}

///|
/// 加減層。
fn parse_expr(p : Parser) -> Expr {
  let mut left = parse_term(p)
  while true {
    match p.peek() {
      TPlus => {
        p.bump()
        left = EBin("+", left, parse_term(p))
      }
      TMinus => {
        p.bump()
        left = EBin("-", left, parse_term(p))
      }
      _ => break
    }
  }
  left
}

///|
/// 乘層。
fn parse_term(p : Parser) -> Expr {
  let mut left = parse_unary(p)
  while true {
    match p.peek() {
      TStar => {
        p.bump()
        left = EBin("*", left, parse_unary(p))
      }
      _ => break
    }
  }
  left
}

///|
/// 一元負號與原子。
fn parse_unary(p : Parser) -> Expr {
  match p.peek() {
    TMinus => {
      p.bump()
      ENeg(parse_unary(p))
    }
    _ => parse_atom(p)
  }
}

///|
/// 原子：數字、識別字、矩陣、括號、呼叫。
fn parse_atom(p : Parser) -> Expr {
  match p.peek() {
    TNum(v) => {
      p.bump()
      ENum(v)
    }
    TId(name) => {
      p.bump()
      match p.peek() {
        TLP => {
          p.bump()
          let args : Array[Expr] = []
          if p.peek() != TRP {
            args.push(parse_expr(p))
            while p.peek() == TComma {
              p.bump()
              args.push(parse_expr(p))
            }
          }
          if p.peek() == TRP {
            p.bump()
          }
          ECall(name, args)
        }
        _ => EId(name)
      }
    }
    TLP => {
      p.bump()
      let e = parse_expr(p)
      if p.peek() == TRP {
        p.bump()
      }
      e
    }
    TLB => {
      p.bump()
      let rows : Array[Array[Expr]] = []
      let row : Array[Expr] = []
      rows.push(row)
      while true {
        match p.peek() {
          TRB => {
            p.bump()
            break
          }
          TSemi => {
            p.bump()
            rows.push([])
          }
          TComma => p.bump()
          _ => {
            let e = parse_expr(p)
            rows[rows.length() - 1].push(e)
          }
        }
      }
      EMat(rows)
    }
    _ => {
      p.bump()
      ENum(0L)
    }
  }
}

///|
/// 值域（統一框架的單一值域）。
pub enum Value {
  VInt(Int64)
  VMat(@core.Mat)
  VGroup(@fga.AbGroup)
  VBool(Bool)
  VText(String)
}

///|
/// 規範形：等價判定即規範形比較。
pub fn canonical(v : Value) -> String {
  match v {
    VInt(x) => "int:" + x.to_string()
    VMat(m) => "mat:" + @core.snf_diag(m).diag_text()
    VGroup(g) => "grp:" + g.to_text()
    VBool(b) => "bool:" + (if b { "T" } else { "F" })
    VText(s) => "txt:" + s
  }
}

///|
/// 值的文本輸出。
pub fn Value::to_text(self : Value) -> String {
  match self {
    VInt(x) => x.to_string()
    VMat(m) => m.to_text()
    VGroup(g) => g.to_text()
    VBool(b) => if b { "true" } else { "false" }
    VText(s) => s
  }
}

///|
/// 求值。
pub fn eval(e : Expr) -> Value {
  match e {
    ENum(v) => VInt(v)
    EId(_n) => VText("未綁定識別字")
    EMat(rows) => {
      let rs : Array[Array[Int64]] = []
      for r in rows {
        let rr : Array[Int64] = []
        for x in r {
          rr.push(as_int(eval(x)))
        }
        rs.push(rr)
      }
      VMat(@core.Mat::of_rows(rs))
    }
    ENeg(x) =>
      match eval(x) {
        VInt(v) => VInt(-v)
        VMat(m) => VMat(m.scale(-1L))
        other => other
      }
    EBin(op, x, y) => {
      let a = eval(x)
      let b = eval(y)
      match op {
        "+" =>
          match (a, b) {
            (VInt(i), VInt(j)) => VInt(i + j)
            (VMat(m), VMat(n)) => VMat(m.add(n))
            _ => VText("型別錯誤:+")
          }
        "-" =>
          match (a, b) {
            (VInt(i), VInt(j)) => VInt(i - j)
            (VMat(m), VMat(n)) => VMat(m.sub(n))
            _ => VText("型別錯誤:-")
          }
        "*" =>
          match (a, b) {
            (VInt(i), VInt(j)) => VInt(i * j)
            (VInt(k), VMat(m)) => VMat(m.scale(k))
            (VMat(m), VInt(k)) => VMat(m.scale(k))
            (VMat(m), VMat(n)) => VMat(m.mul(n))
            _ => VText("型別錯誤:*")
          }
        _ => VText("未知運算")
      }
    }
    ECall(name, args) => call_builtin(name, args)
  }
}

///|
/// 取整數值。
fn as_int(v : Value) -> Int64 {
  match v {
    VInt(x) => x
    _ => 0L
  }
}

///|
/// 取矩陣值。
fn as_mat(v : Value) -> @core.Mat {
  match v {
    VMat(m) => m
    VInt(x) => @core.Mat::of_rows([[x]])
    _ => @core.Mat::zero(1, 1)
  }
}

///|
/// 取群值。
fn as_group(v : Value) -> @fga.AbGroup {
  match v {
    VGroup(g) => g
    VInt(x) => @fga.cyclic_group(x)
    _ => @fga.trivial_group()
  }
}

///|
/// 內建算子表（統一框架的全部入口）。
pub fn call_builtin(name : String, args : Array[Expr]) -> Value {
  match name {
    // —— 矩陣與標準形 ——
    "id" => VMat(@core.Mat::ident(as_int(eval(args[0])).to_int()))
    "diag" => {
      let ds : Array[Int64] = []
      for a in args {
        ds.push(as_int(eval(a)))
      }
      VMat(@core.Mat::diag(ds))
    }
    "snf" => VMat(@core.snf_diag(as_mat(eval(args[0]))))
    "det" => VInt(as_mat(eval(args[0])).det())
    "rank" => VInt(as_mat(eval(args[0])).rank().to_int64())
    "hnf" => VMat(@core.hnf(as_mat(eval(args[0]))))
    "tr" => VMat(as_mat(eval(args[0])).transpose())
    "gram" => VMat(@latt.gram(as_mat(eval(args[0]))))
    "ker" => {
      let b = @core.kernel_basis(as_mat(eval(args[0])))
      VMat(@core.Mat::of_rows(b))
    }
    "lll" => {
      let (bp, _u) = @latt.lll_reduce(as_mat(eval(args[0])))
      VMat(bp)
    }
    // —— 群與同調代數 ——
    "cyc" => VGroup(@fga.cyclic_group(as_int(eval(args[0]))))
    "free" => VGroup(@fga.free_group(as_int(eval(args[0])).to_int()))
    "triv" => VGroup(@fga.trivial_group())
    "coker" => VGroup(@fga.group_from_relations(as_mat(eval(args[0]))))
    "hom" =>
      VGroup(@fga.hom_group(as_group(eval(args[0])), as_group(eval(args[1]))))
    "ext" =>
      VGroup(@fga.ext_group(as_group(eval(args[0])), as_group(eval(args[1]))))
    "tor" =>
      VGroup(@fga.tor_group(as_group(eval(args[0])), as_group(eval(args[1]))))
    "tensor" =>
      VGroup(
        @fga.tensor_group(as_group(eval(args[0])), as_group(eval(args[1]))),
      )
    "dual" => VGroup(@fga.dual_group(as_group(eval(args[0]))))
    "pn" =>
      VGroup(
        @fga.p_n_torsion(
          as_group(eval(args[0])),
          as_int(eval(args[1])),
          as_int(eval(args[2])).to_int(),
        ),
      )
    "div" => VBool(@fga.is_divisible_fg(as_group(eval(args[0]))))
    "ord" => VInt(as_group(eval(args[0])).order())
    // —— 自證型算子 ——
    "eq" => VBool(canonical(eval(args[0])) == canonical(eval(args[1])))
    "checksnf" => {
      let m = as_mat(eval(args[0]))
      let (u, d, v) = @core.snf_full(m)
      VBool(@core.verify_snf_full(m, u, d, v))
    }
    "checklll" => {
      let b = as_mat(eval(args[0]))
      let (bp, u) = @latt.lll_reduce(b)
      VBool(@latt.verify_lll(b, bp, u))
    }
    "tensor_tor" =>
      VBool(
        @fga.verify_tensor_torsion(
          as_group(eval(args[0])),
          as_group(eval(args[1])),
        ),
      )
    "bidual" => VBool(@fga.verify_bidual(as_group(eval(args[0]))))
    "crt" =>
      VBool(@fga.verify_crt(as_int(eval(args[0])), as_int(eval(args[1]))))
    "hensel" =>
      VBool(
        @padic.verify_hensel_sqrt(
          as_int(eval(args[0])),
          as_int(eval(args[1])),
          as_int(eval(args[2])),
          as_int(eval(args[3])).to_int(),
        ),
      )
    "sl2" =>
      VBool(
        @padic.verify_sl2_order(
          as_int(eval(args[0])),
          as_int(eval(args[1])).to_int(),
        ),
      )
    "hasse" =>
      match
        @curves.EC::make(
          as_int(eval(args[0])),
          as_int(eval(args[1])),
          as_int(eval(args[2])),
        ) {
        None => VBool(false)
        Some(e) => VBool(e.verify_hasse() && e.verify_structure())
      }
    "psi3" =>
      match
        @curves.EC::make(
          as_int(eval(args[0])),
          as_int(eval(args[1])),
          as_int(eval(args[2])),
        ) {
        None => VBool(false)
        Some(e) => VBool(e.verify_psi3())
      }
    "fftok" => {
      let m = as_mat(eval(args[0]))
      let p = @spec.fermat_p()
      VBool(
        @spec.verify_fft_roundtrip(m.row(0), @spec.nth_root(m.ncols(), p), p),
      )
    }
    // —— 形式化驅動代碼生成與演算法合成算子 ——
    "horner" =>
      VInt(
        @psynth.horner3_synth(
          as_int(eval(args[0])).to_int(),
          as_int(eval(args[1])).to_int(),
          as_int(eval(args[2])).to_int(),
          as_int(eval(args[3])).to_int(),
          as_int(eval(args[4])).to_int(),
        ).to_int64(),
      )
    "estrin" =>
      VInt(
        @psynth.estrin3_synth(
          as_int(eval(args[0])).to_int(),
          as_int(eval(args[1])).to_int(),
          as_int(eval(args[2])).to_int(),
          as_int(eval(args[3])).to_int(),
          as_int(eval(args[4])).to_int(),
        ).to_int64(),
      )
    "bezout" => {
      let a = as_int(eval(args[0])).to_int()
      let b = as_int(eval(args[1])).to_int()
      let c = @synth.synth_bezout_cert(a, b)
      VBool(@synth.verify_bezout_cert(a, b, c))
    }
    "cegis" => VBool(@synth.cegis_synth_karatsuba_im().verified)
    // —— sigma 密碼學領域特定語言（Crypto DSL）內嵌算子 ——
    "sigma_suite" => VBool(@sigma.verify_all_compiled_ciphers())
    "sigma_lwe" => VBool(@sigma.compiled_ring_lwe_kem().ok)
    "sigma_trapdoor" => VBool(@sigma.compiled_lattice_gpv_trapdoor().ok)
    "sigma_isogeny" => VBool(@sigma.compiled_isogeny_velu_kani().ok)
    "sigma_dlog" => VBool(@sigma.compiled_group_dlog_snf().ok)
    "sigma_padic" => VBool(@sigma.compiled_padic_sl2_suite().ok)
    "sigma_zk" => VBool(@sigma.compiled_super_berezinian_zk().ok)
    "sigma_kron" => VBool(@sigma.compiled_kron_poly_auth().ok)
    "text" => VText(eval(args[0]).to_text())
    _ => VText("未知算子:" + name)
  }
}

///|
/// 執行程式並回傳最後一式的文本結果。
pub fn run(src : String) -> String {
  let prog = parse_program(src)
  let mut last = VText("(空程式)")
  for st in prog {
    last = eval(st)
  }
  last.to_text()
}

///|
/// 等價判定：Σ-演算層的「互通」——兩條語句等價 ⟺ 規範形相同。
pub fn equivalent(src1 : String, src2 : String) -> Bool {
  let p1 = parse_program(src1)
  let p2 = parse_program(src2)
  if p1.length() == 0 || p2.length() == 0 {
    return p1.length() == p2.length()
  }
  canonical(eval(p1[0])) == canonical(eval(p2[0]))
}
