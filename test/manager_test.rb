# frozen_string_literal: true

require_relative "test_helper"

class ManagerTest < Minitest::Test
  def test_manager_new
    manager = Bubblezone::Manager.new
    assert_kind_of Bubblezone::Manager, manager
  end

  def test_manager_enabled_by_default
    manager = Bubblezone::Manager.new
    assert manager.enabled?
  end

  def test_manager_mark_and_scan
    manager = Bubblezone::Manager.new
    marked = manager.mark("mgr_zone", "Content")
    scanned = manager.scan(marked)

    assert_equal "Content", scanned
  end

  def test_manager_get_zone
    manager = Bubblezone::Manager.new
    layout = manager.mark("mgr_get", "Data")
    manager.scan_and_wait(layout)

    zone = manager.get("mgr_get")
    refute_nil zone
    assert_kind_of Bubblezone::ZoneInfo, zone
  end

  def test_manager_tracks_zone_ids
    manager = Bubblezone::Manager.new
    manager.mark("id1", "A")
    manager.mark("id2", "B")

    ids = manager.zone_ids
    assert_includes ids, "id1"
    assert_includes ids, "id2"
  end

  def test_manager_each_in_bounds
    manager = Bubblezone::Manager.new
    layout = manager.mark("mgr_bounds", "Clickable")
    manager.scan_and_wait(layout)

    found = []
    manager.each_in_bounds(0, 0) { |id, _zone| found << id }

    assert_equal ["mgr_bounds"], found
  end

  def test_manager_find_in_bounds
    manager = Bubblezone::Manager.new
    layout = manager.mark("mgr_find", "Target")
    manager.scan_and_wait(layout)

    result = manager.find_in_bounds(2, 0)
    refute_nil result
    assert_equal "mgr_find", result[0]
  end

  def test_manager_any_in_bounds
    manager = Bubblezone::Manager.new
    layout = manager.mark("mgr_any", "Zone")
    manager.scan_and_wait(layout)

    assert manager.any_in_bounds?(0, 0)
    refute manager.any_in_bounds?(100, 100)
  end

  def test_manager_clear
    manager = Bubblezone::Manager.new
    manager.mark("to_clear", "X")
    assert_includes manager.zone_ids, "to_clear"

    manager.clear("to_clear")
    refute_includes manager.zone_ids, "to_clear"
  end

  def test_manager_clear_all
    manager = Bubblezone::Manager.new
    manager.mark("a", "A")
    manager.mark("b", "B")

    manager.clear_all
    assert_empty manager.zone_ids
  end

  def test_manager_new_prefix
    manager = Bubblezone::Manager.new
    prefix1 = manager.new_prefix
    prefix2 = manager.new_prefix

    refute_equal prefix1, prefix2
  end

  def test_managers_are_independent
    manager1 = Bubblezone::Manager.new
    manager2 = Bubblezone::Manager.new

    manager1.mark("m1_zone", "M1")
    manager2.mark("m2_zone", "M2")

    assert_includes manager1.zone_ids, "m1_zone"
    refute_includes manager1.zone_ids, "m2_zone"

    assert_includes manager2.zone_ids, "m2_zone"
    refute_includes manager2.zone_ids, "m1_zone"
  end
end
