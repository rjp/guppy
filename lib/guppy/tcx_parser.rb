module Guppy
  class TcxParser
    def self.open(file)
      parser = self.new(file)
      parser.parse
      parser
    end

    # Return an int if our node exists, has text, and that text isn't just whitespace
    def node_int(value)
        if value.nil? or value.inner_text.nil? or value.inner_text.strip.empty? then
            return nil
        end
        return value.inner_text.to_i
    end

    # Return a float if our node exists, has text, and that text isn't just whitespace
    def node_float(value)
        if value.nil? or value.inner_text.nil? or value.inner_text.empty? then
            return nil
        end
        return value.inner_text.to_f
    end

    def initialize(file)
      @file = file
    end

    def parse
      f = File.open(@file)
      @doc = Nokogiri.XML(f.read)
      f.close
    end

    def activity(activity_id)
      activity_node = @doc.xpath('//xmlns:Activity', namespaces).find {|a| a.xpath('xmlns:Id', namespaces).inner_text == activity_id}
      if activity_node
        build_activity(activity_node)
      else
        nil
      end
    end
    
    def activities(id=nil)
      @doc.xpath('//xmlns:Activity', namespaces).map do |activity_node|
        build_activity(activity_node)
      end
    end

    private
    def build_activity(activity_node)
      activity = Activity.new
      activity.sport = activity_node['Sport']
      activity.date = Time.parse(activity_node.xpath('xmlns:Id', namespaces).inner_text)

      activity_node.xpath('xmlns:Lap', namespaces).each do |lap_node|
        activity.laps << build_lap(lap_node)
      end
      
      activity
    end

    def build_lap(lap_node)
      lap = Guppy::Lap.new
      lap.distance = lap_node.xpath('xmlns:DistanceMeters', namespaces).inner_text.to_f
      lap.max_speed = lap_node.xpath('xmlns:MaximumSpeed', namespaces).inner_text.to_f
      lap.time = lap_node.xpath('xmlns:TotalTimeSeconds', namespaces).inner_text.to_f
      lap.calories = lap_node.xpath('xmlns:Calories', namespaces).inner_text.to_f
      lap.average_heart_rate = lap_node.xpath('xmlns:AverageHeartRateBpm/xmlns:Value', namespaces).inner_text.to_i
      lap.max_heart_rate = lap_node.xpath('xmlns:MaximumHeartRateBpm/xmlns:Value', namespaces).inner_text.to_i

      lap.max_cadence = lap_node.xpath('xmlns:Extensions/ae:LX/ae:MaxBikeCadence', namespaces).inner_text.to_i
      lap.avg_speed = lap_node.xpath('xmlns:Extensions/ae:LX/ae:AvgSpeed', namespaces).inner_text.to_f

      lap_node.xpath('xmlns:Track/xmlns:Trackpoint', namespaces).each do |track_point_node|
        lap.track_points << build_track_point(track_point_node)
      end
      
      lap
    end

    def build_track_point(track_point_node)
      track_point = Guppy::TrackPoint.new
      track_point.latitude = track_point_node.xpath('xmlns:Position/xmlns:LatitudeDegrees', namespaces).inner_text.to_f
      track_point.longitude = track_point_node.xpath('xmlns:Position/xmlns:LongitudeDegrees', namespaces).inner_text.to_f
      track_point.altitude = track_point_node.xpath('xmlns:AltitudeMeters', namespaces).inner_text.to_f
      track_point.distance = track_point_node.xpath('xmlns:DistanceMeters', namespaces).inner_text.to_f
      track_point.heart_rate = track_point_node.xpath('xmlns:HeartRateBpm/xmlns:Value', namespaces).inner_text.to_i
      track_point.time = Time.parse(track_point_node.xpath('xmlns:Time', namespaces).inner_text)

      bikecad = node_int(track_point_node.xpath('xmlns:Cadence', namespaces))
      runcad = node_int(track_point_node.xpath('xmlns:Extensions/ae:TPX/ae:RunCadence', namespaces))
      track_point.cadence = bikecad || runcad

      track_point.watts = node_int(track_point_node.xpath('xmlns:Extensions/ae:TPX/ae:Watts', namespaces))
      track_point.speed = node_float(track_point_node.xpath('xmlns:Extensions/ae:TPX/ae:Speed', namespaces))
      
      track_point
    end
    
    def namespaces
      @namespaces ||= @doc.root.namespaces

      # External sensors and extra information are -sometimes- under another namespace
      @namespaces['ae'] = "http://www.garmin.com/xmlschemas/ActivityExtension/v2"

      return @namespaces
    end
  end
end
