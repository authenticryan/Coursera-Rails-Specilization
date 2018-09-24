# class creates a GeoJSON Point object to be used with GeoSpatial queires of mongoDB

class Point

    attr_accessor :longitude, :latitude

    # sample input data comes in as 
    # {:type=>"Point", :coordinates=>[ -1.8625303, 53.8256035]} #GeoJSON Point format
    # {:lat=>53.8256035, :lng=>-1.8625303}

    def initialize(params)
        params = params.symbolize_keys.slice(:type, :coordinates, :lat, :lng)

        @longitude = params[:coordinates].nil? ? params[:lng] : params[:coordinates][0]
        @latitude  = params[:coordinates].nil? ? params[:lat] : params[:coordinates][1]
    end

    def to_hash
        coordinates = []
        coordinates.push(@longitude)
        coordinates.push(@latitude)

        {:type => "Point", :coordinates => coordinates}
    end
end