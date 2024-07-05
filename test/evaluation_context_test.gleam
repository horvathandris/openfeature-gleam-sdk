import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should
import openfeature/evaluation_context.{type EvaluationContext, EvaluationContext}

pub fn main() {
  gleeunit.main()
}

type TestRecord {
  TestRecord(field1: Bool, field2: Int)
}

pub fn should_get_attribute_correctly_test() {
  let attributes =
    dict.new()
    |> dict.insert("bool_attribute", dynamic.from(True))
    |> dict.insert("string_attribute", dynamic.from("string"))
    |> dict.insert("int_attribute", dynamic.from(1))
    |> dict.insert("float_attribute", dynamic.from(3.14))
    |> dict.insert("record_attribute", dynamic.from(TestRecord(True, 1)))
  let context = EvaluationContext(None, attributes)

  evaluation_context.get_attribute(context, "bool_attribute")
  |> should.be_ok
  |> should.equal(dynamic.from(True))

  evaluation_context.get_attribute(context, "string_attribute")
  |> should.be_ok
  |> should.equal(dynamic.from("string"))

  evaluation_context.get_attribute(context, "int_attribute")
  |> should.be_ok
  |> should.equal(dynamic.from(1))

  evaluation_context.get_attribute(context, "float_attribute")
  |> should.be_ok
  |> should.equal(dynamic.from(3.14))

  evaluation_context.get_attribute(context, "record_attribute")
  |> should.be_ok
  |> should.equal(dynamic.from(TestRecord(True, 1)))
}

pub fn should_get_all_attributes_correctly_test() {
  let attributes =
    dict.new()
    |> dict.insert("bool_attribute", dynamic.from(True))
    |> dict.insert("string_attribute", dynamic.from("string"))
    |> dict.insert("int_attribute", dynamic.from(1))
    |> dict.insert("float_attribute", dynamic.from(3.14))
    |> dict.insert("record_attribute", dynamic.from(TestRecord(True, 1)))
  let context = EvaluationContext(None, attributes)

  let all_attributes = evaluation_context.get_all_attributes(context)

  all_attributes
  |> list.length
  |> should.equal(5)

  all_attributes
  |> list.contains(#("bool_attribute", dynamic.from(True)))
  |> should.be_true

  all_attributes
  |> list.contains(#("string_attribute", dynamic.from("string")))
  |> should.be_true

  all_attributes
  |> list.contains(#("int_attribute", dynamic.from(1)))
  |> should.be_true

  all_attributes
  |> list.contains(#("float_attribute", dynamic.from(3.14)))
  |> should.be_true

  all_attributes
  |> list.contains(#("record_attribute", dynamic.from(TestRecord(True, 1))))
  |> should.be_true
}

pub fn should_merge_context_attributes_correctly_test() {
  let initial_context_attributes =
    dict.new()
    |> dict.insert("attribute1", dynamic.from(True))
    |> dict.insert("attribute2", dynamic.from(1))
    |> dict.insert("attribute3", dynamic.from(3.14))
  let initial_context = EvaluationContext(None, initial_context_attributes)

  let overriding_context_attributes =
    dict.new()
    |> dict.insert("attribute1", dynamic.from(False))
    |> dict.insert("attribute3", dynamic.from("string"))
    |> dict.insert("attribute4", dynamic.from(TestRecord(True, 1)))
  let overriding_context =
    EvaluationContext(None, overriding_context_attributes)

  let merged_context =
    initial_context
    |> evaluation_context.merge(overriding_context)

  merged_context
  |> evaluation_context.get_attribute("attribute1")
  |> should.be_ok
  |> should.equal(dynamic.from(False))

  merged_context
  |> evaluation_context.get_attribute("attribute2")
  |> should.be_ok
  |> should.equal(dynamic.from(1))

  merged_context
  |> evaluation_context.get_attribute("attribute3")
  |> should.be_ok
  |> should.equal(dynamic.from("string"))

  merged_context
  |> evaluation_context.get_attribute("attribute4")
  |> should.be_ok
  |> should.equal(dynamic.from(TestRecord(True, 1)))
}

pub fn should_merge_context_targeting_keys_correctly_test() {
  let context1 = EvaluationContext(Some("old_key"), dict.new())
  let context2 = EvaluationContext(Some("new_key"), dict.new())
  let context3 = EvaluationContext(None, dict.new())

  context1
  |> evaluation_context.merge(context2)
  |> evaluation_context.merge(context3)
  |> fn(context: EvaluationContext) { context.targeting_key }
  |> should.be_some
  |> should.equal("new_key")
}
