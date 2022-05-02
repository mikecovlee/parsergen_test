#!/usr/bin/env cs
import ecs
import parsergen
import regex
import ecs_parser
constant syntax = parsergen.syntax
var json_lexical = {"val" : regex.build("^\\w+$"), "num" : regex.build("^[0-9]+\\.?([0-9]+)?$"), "sig" : regex.build("^(:|,|\\[|\\]|\\{|\\})$"), "str" : regex.build("^(\"|\"([^\"]|\\\\\")*\"?)$"), "ign" : regex.build("^\\s+$"), "err" : regex.build("^\"$")}.to_hash_map()
var json_syntax = {"begin" : {syntax.cond_or({syntax.ref("object")}, {syntax.ref("array")})}, "object" : {syntax.term("{"), syntax.optional(syntax.ref("members")), syntax.term("}")}, "members" : {syntax.ref("pair"), syntax.repeat(syntax.term(","), syntax.ref("pair"))}, "pair" : {syntax.token("str"), syntax.term(":"), syntax.ref("value")}, "array" : {syntax.term("["), syntax.optional(syntax.ref("elements")), syntax.term("]")}, "elements" : {syntax.ref("value"), syntax.repeat(syntax.term(","), syntax.ref("value"))}, "value" : {syntax.cond_or({syntax.token("str")}, {syntax.token("num")}, {syntax.ref("object")}, {syntax.ref("array")}, {syntax.term("true")}, {syntax.term("false")}, {syntax.term("null")})}}.to_hash_map()
function compress_ast(n)
foreach it in n.nodes
while typeid it == typeid parsergen.syntax_tree && it.nodes.size == 1
it = it.nodes.front
end
if typeid it == typeid parsergen.syntax_tree
compress_ast(it)
else
if it.type == "endl"
it.data = "\\n"
end
end
end
end
function run_once(file, enable_predict, output_ast)
parsergen.enable_predict = enable_predict
parsergen.reject_count = 0
var time_spend = 0
var json_grammar = new parsergen.grammar
var main = new parsergen.generator
json_grammar.lex = json_lexical
json_grammar.stx = json_syntax
json_grammar.ext = ".*\\.json"
main.add_grammar("json", json_grammar)
main.add_grammar("ecs-lang", ecs_parser.grammar)
var time_start = runtime.time()
main.from_file(file)
time_spend = runtime.time() - time_start
if output_ast && main.ast != null
compress_ast(main.ast)
parsergen.print_ast(main.ast)
end
return {time_spend, parsergen.reject_count}
end
function run_path(path, pass)
var info = system.path.scan(path)
var count = 0
foreach it in info
++count
var file_name = path + "/" + it.name
system.out.println("(" + count + "/" + info.size + ") Testing \"" + file_name + "\"...")
var avg_predicted_time = 0, avg_predicted_reject_count = 0
foreach i in range(pass)
var (time, count) = run_once(file_name, true, false)
system.out.println("\tIn predicted pass " + (i + 1) + ":\tTime = " + time + ", Count = " + count)
avg_predicted_time += time
avg_predicted_reject_count += count
end
avg_predicted_time = avg_predicted_time/pass
avg_predicted_reject_count = avg_predicted_reject_count/pass
var avg_unpredicted_time = 0, avg_unpredicted_reject_count = 0
foreach i in range(pass)
var (time, count) = run_once(file_name, true, false)
system.out.println("\tIn unpredicted pass " + (i + 1) + ":\tTime = " + time + ", Count = " + count)
avg_unpredicted_time += time
avg_unpredicted_reject_count += count
end
avg_unpredicted_time = avg_predicted_time/pass
avg_unpredicted_reject_count = avg_predicted_reject_count/pass
end
end
var target_path = {"./test_cases/ecs", "./test_cases/json"}
foreach it in target_path do run_path(it, 5)
