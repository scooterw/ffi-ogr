module OGR
  class Envelope
    attr_accessor :min_x, :max_x, :min_y, :max_y

    def initialize(env)
      raise RuntimeError.new("Invalid envelope specified") unless env.size == 4

      @min_x, @max_x = env[0], env[1]
      @min_y, @max_y = env[2], env[3]
    end

    def to_a(se_nw=false)
      unless se_nw
        [@min_x, @max_x, @min_y, @max_y]
      else
        [@min_x, @min_y, @max_x, @max_y]
      end
    end

    def to_hash
      {min_x: @min_x, max_x: @max_x, min_y: @min_y, max_y: @max_y}
    end

    def to_json
      MultiJson.dump(to_hash)
    end

    def to_polygon
      coords = [[[@min_x, @min_y], [@min_x, @max_y], [@max_x, @max_y], [@max_x, @min_y], [@min_x, @min_y]]]
      OGR::Polygon.create coords
    end
  end
end
