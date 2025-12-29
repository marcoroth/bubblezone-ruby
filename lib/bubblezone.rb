# frozen_string_literal: true

require_relative "bubblezone/version"
require_relative "bubblezone/bubblezone"
require_relative "bubblezone/manager"
require_relative "bubblezone/zone_info"

module Bubblezone
  class Error < StandardError; end

  @global_zone_ids = Set.new
  @global_zone_ids_mutex = Mutex.new

  class << self
    alias _native_mark mark

    def mark(zone_id, text)
      @global_zone_ids_mutex.synchronize { @global_zone_ids.add(zone_id) }
      _native_mark(zone_id, text)
    end

    alias _native_clear clear

    def clear(zone_id)
      @global_zone_ids_mutex.synchronize { @global_zone_ids.delete(zone_id) }
      _native_clear(zone_id)
    end

    def clear_all
      @global_zone_ids_mutex.synchronize do
        @global_zone_ids.each { |id| _native_clear(id) }
        @global_zone_ids.clear
      end
    end

    def zone_ids
      @global_zone_ids_mutex.synchronize { @global_zone_ids.to_a }
    end

    def each_in_bounds(x, y)
      return enum_for(:each_in_bounds, x, y) unless block_given?

      ids = @global_zone_ids_mutex.synchronize { @global_zone_ids.to_a.sort }

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
