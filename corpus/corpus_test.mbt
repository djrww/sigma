///|
/// 語料庫不變式測試：總量、族覆蓋、機器見證與兩份渲染的一致性。
test "corpus/invariants" {
  let es = @corpus.build()
  inspect(@corpus.check_size(es), content="true")
  inspect(es.length() >= 3000, content="true")
  let fams : Map[String, Int] = Map([])
  let kinds : Map[String, Int] = Map([])
  let mut bad = 0
  for e in es {
    fams[e.family] = 1
    kinds[e.kind] = 1
    if e.id == "" || e.statement == "" || e.formula == "" {
      bad = bad + 1
    }
  }
  inspect(bad, content="0")
  inspect(fams.length() >= 28, content="true")
  inspect(kinds.length(), content="4")
  let md = @corpus.render_markdown(es)
  let csv = @corpus.render_csv(es)
  let js = @corpus.render_json(es)
  inspect(md.length() > 100000, content="true")
  inspect(csv.split("\n").length() >= 3000, content="true")
  inspect(js.contains("\"family\""), content="true")
  inspect(@corpus.stats(es).contains("check"), content="false")
}

///|
test "corpus/formal_proof_10_packages_and_skipped_audit" {
  let (pv, pt, pd, pu) = @corpus.summary()
  inspect(pv, content="168")
  inspect(pt, content="0")
  inspect(pd, content="173")
  inspect(pu, content="0")
  inspect(@corpus.skipped_timeout_theorems().length(), content="9")
  inspect(@corpus.skipped_exploded_algorithms().length(), content="10")
  let audit = @corpus.render_proof_audit_report()
  inspect(audit.contains("T-TO-01"), content="true")
  inspect(audit.contains("T-TO-09"), content="true")
  inspect(audit.contains("ALG-CE-01"), content="true")
  inspect(audit.contains("ALG-CE-10"), content="true")
  let es = @corpus.build()
  let mut all_pass = true
  for e in es {
    if !e.ok {
      all_pass = false
    }
  }
  inspect(all_pass, content="true")
}
