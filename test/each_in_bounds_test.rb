# frozen_string_literal: true

require_relative "test_helper"

class TestEachInBounds < Minitest::Test
  def setup
    Bubblezone.new_global
    Bubblezone.clear_all
  end

  def test_each_in_bounds_yields_matching_zones
    layout = [
      Bubblezone.mark("btn1", "Button 1"),
      Bubblezone.mark("btn2", "Button 2"),
    ].join("\n")
    scan_and_wait(layout)

    found = []
    Bubblezone.each_in_bounds(2, 0) { |id, _zone| found << id }

    assert_equal ["btn1"], found
  end

  def test_each_in_bounds_yields_multiple_overlapping_zones
    text = Bubblezone.mark("outer", Bubblezone.mark("inner", "Text"))
    scan_and_wait(text)

    found = []
    Bubblezone.each_in_bounds(0, 0) { |id, _zone| found << id }

    assert_includes found, "inner"
    assert_includes found, "outer"
  end

  def test_each_in_bounds_returns_enumerator_without_block
    layout = Bubblezone.mark("enum_test", "Content")
    scan_and_wait(layout)

    enum = Bubblezone.each_in_bounds(0, 0)
    assert_kind_of Enumerator, enum

    result = enum.first
    assert_equal "enum_test", result[0]
  end

  def test_each_in_bounds_yields_nothing_for_miss
    layout = Bubblezone.mark("miss_test", "Short")
    scan_and_wait(layout)

    found = []
    Bubblezone.each_in_bounds(100, 100) { |id, _zone| found << id }

    assert_empty found
  end

  def test_each_in_bounds_yields_zone_info
    layout = Bubblezone.mark("info_test", "Data")
    scan_and_wait(layout)

    Bubblezone.each_in_bounds(0, 0) do |id, zone|
      assert_equal "info_test", id
      assert_kind_of Bubblezone::ZoneInfo, zone
      assert zone.in_bounds?(0, 0)
    end
  end

  def test_any_in_bounds_returns_true_for_hit
    layout = Bubblezone.mark("any_test", "Target")
    scan_and_wait(layout)

    assert Bubblezone.any_in_bounds?(2, 0)
  end

  def test_any_in_bounds_returns_false_for_miss
    layout = Bubblezone.mark("any_miss", "Target")
    scan_and_wait(layout)

    refute Bubblezone.any_in_bounds?(100, 100)
  end

  def test_find_in_bounds_returns_first_match
    layout = [
      Bubblezone.mark("first", "First"),
      Bubblezone.mark("second", "Second"),
    ].join("\n")

    scan_and_wait(layout)

    result = Bubblezone.find_in_bounds(2, 0)
    refute_nil result

    id, zone = result
    assert_equal "first", id
    assert_kind_of Bubblezone::ZoneInfo, zone
  end

  def test_find_in_bounds_returns_nil_for_miss
    layout = Bubblezone.mark("find_miss", "Text")
    scan_and_wait(layout)

    result = Bubblezone.find_in_bounds(100, 100)
    assert_nil result
  end

  def test_zone_ids_sorted_alphabetically
    Bubblezone.mark("zebra", "Z")
    Bubblezone.mark("apple", "A")
    Bubblezone.mark("mango", "M")

    layout = [
      Bubblezone.mark("zebra", "Z"),
      Bubblezone.mark("apple", "A"),
      Bubblezone.mark("mango", "M"),
    ].join

    scan_and_wait(layout)

    found = []
    Bubblezone.each_in_bounds(0, 0) { |id, _| found << id }

    assert_equal found.sort, found
  end
end
