# frozen_string_literal: true

module Bubblezone
  class Manager
    def zone_ids_set
      @zone_ids_set ||= Set.new
    end

    def zone_ids_mutex
      @zone_ids_mutex ||= Mutex.new
    end

    alias _native_mark mark

    def mark(zone_id, text)
      zone_ids_mutex.synchronize { zone_ids_set.add(zone_id) }
      _native_mark(zone_id, text)
    end

    alias _native_clear clear

    def clear(zone_id)
      zone_ids_mutex.synchronize { zone_ids_set.delete(zone_id) }
      _native_clear(zone_id)
    end

    def clear_all
      zone_ids_mutex.synchronize do
        zone_ids_set.each { |id| _native_clear(id) }
        zone_ids_set.clear
      end
    end

    def zone_ids
      zone_ids_mutex.synchronize { zone_ids_set.to_a }
    end

    def each_in_bounds(x, y)
      return enum_for(:each_in_bounds, x, y) unless block_given?

      ids = zone_ids_mutex.synchronize { zone_ids_set.to_a.sort }
      ids.each do |id|
        zone = get(id)
        yield(id, zone) if zone&.in_bounds?(x, y)
      end
    end

    def any_in_bounds?(x, y)
      each_in_bounds(x, y).any?
    end

    def find_in_bounds(x, y)
      each_in_bounds(x, y).first
    end
  end
end
