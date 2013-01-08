module Guppy
  class Lap
    attr_accessor :distance
    attr_accessor :max_speed
    attr_accessor :time
    attr_accessor :calories
    attr_accessor :average_heart_rate
    attr_accessor :max_heart_rate
    attr_accessor :max_cadence
    attr_accessor :avg_speed
    attr_reader   :track_points
    
    def initialize
      @distance           = 0.0
      @max_speed          = 0.0
      @time               = 0.0
      @calories           = 0
      @average_heart_rate = 0
      @max_heart_rate     = 0
      @track_points       = []
    end

  end
end
