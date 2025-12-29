# frozen_string_literal: true

module Bubblezone
  class ZoneInfo
    def width
      end_x - start_x + 1
    end

    def height
      end_y - start_y + 1
    end

    def size
      [width, height]
    end

    def to_s
      "ZoneInfo(start: (#{start_x}, #{start_y}), end: (#{end_x}, #{end_y}))"
    end

    def inspect
      "#<#{self.class} start_x=#{start_x} start_y=#{start_y} end_x=#{end_x} end_y=#{end_y}>"
    end
  end
end
