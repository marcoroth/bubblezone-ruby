# frozen_string_literal: true

require_relative "test_helper"

class BubblezoneTest < Minitest::Test
  def setup
    Bubblezone.new_global
    Bubblezone.clear_all
  end

  def test_that_it_has_a_version_number
    refute_nil ::Bubblezone::VERSION
  end

  def test_version_string
    version = Bubblezone.version
    assert_match(/bubblezone v\d+\.\d+\.\d+/, version)
    assert_match(/upstream v/, version)
  end

  def test_enabled_by_default
    assert Bubblezone.enabled?
  end

  def test_enabled_toggle
    Bubblezone.enabled = false
    refute Bubblezone.enabled?

    Bubblezone.enabled = true
    assert Bubblezone.enabled?
  end

  def test_new_prefix
    prefix1 = Bubblezone.new_prefix
    prefix2 = Bubblezone.new_prefix

    assert_kind_of String, prefix1
    assert_kind_of String, prefix2
    refute_equal prefix1, prefix2
    assert_match(/^zone_\d+__$/, prefix1)
  end

  def test_mark_wraps_text
    marked = Bubblezone.mark("test_id", "Hello")

    assert_includes marked, "Hello"
    refute_equal "Hello", marked
  end

  def test_mark_tracks_zone_id
    Bubblezone.mark("tracked_id", "Text")
    assert_includes Bubblezone.zone_ids, "tracked_id"
  end

  def test_scan_removes_markers
    marked = Bubblezone.mark("scan_id", "Content")
    scanned = Bubblezone.scan(marked)
    assert_equal "Content", scanned
  end

  def test_get_returns_zone_info_after_scan
    layout = Bubblezone.mark("zone1", "Button")
    scan_and_wait(layout)

    zone = Bubblezone.get("zone1")
    refute_nil zone
    assert_kind_of Bubblezone::ZoneInfo, zone
  end

  def test_get_returns_nil_for_unknown_zone
    zone = Bubblezone.get("nonexistent_zone")
    assert_nil zone
  end

  def test_zone_info_bounds
    layout = "Header\n#{Bubblezone.mark("btn", "Click Me")}\nFooter"
    scan_and_wait(layout)

    zone = Bubblezone.get("btn")
    refute_nil zone

    assert_respond_to zone, :start_x
    assert_respond_to zone, :start_y
    assert_respond_to zone, :end_x
    assert_respond_to zone, :end_y

    assert_equal 1, zone.start_y
    assert_equal 1, zone.end_y
    assert_equal 0, zone.start_x
    assert_equal 7, zone.end_x
  end

  def test_zone_info_in_bounds
    layout = Bubblezone.mark("test", "Text")
    scan_and_wait(layout)

    zone = Bubblezone.get("test")
    refute_nil zone

    assert zone.in_bounds?(0, 0)
    assert zone.in_bounds?(2, 0)

    refute zone.in_bounds?(10, 0)
    refute zone.in_bounds?(0, 1)
  end

  def test_zone_info_zero
    layout = Bubblezone.mark("z", "X")
    scan_and_wait(layout)

    zone = Bubblezone.get("z")
    refute_nil zone
    refute zone.zero?
  end

  def test_zone_info_pos
    layout = Bubblezone.mark("pos_test", "ABCD")
    scan_and_wait(layout)

    zone = Bubblezone.get("pos_test")
    refute_nil zone

    rel_x, rel_y = zone.pos(2, 0)
    assert_equal 2, rel_x
    assert_equal 0, rel_y

    rel_x, rel_y = zone.pos(0, 0)
    assert_equal 0, rel_x
    assert_equal 0, rel_y
  end

  def test_clear_removes_zone
    Bubblezone.mark("to_clear", "Text")
    assert_includes Bubblezone.zone_ids, "to_clear"

    Bubblezone.clear("to_clear")
    refute_includes Bubblezone.zone_ids, "to_clear"
  end

  def test_clear_all
    Bubblezone.mark("a", "A")
    Bubblezone.mark("b", "B")
    Bubblezone.mark("c", "C")
    assert_equal 3, Bubblezone.zone_ids.length

    Bubblezone.clear_all
    assert_empty Bubblezone.zone_ids
  end
end
