class Photo

  require 'exifr/jpeg'

  attr_accessor :id, :location
  attr_writer :contents

  def self.mongo_client
    Mongoid::Clients.default
  end

  def initialize (params = nil)
    params = params.symbolize_keys.slice(:_id, :metadata) unless params.nil?

    @id = params[:_id].to_s         unless params.nil? || params[:_id].nil?
    
    if params && params[:metadata]
      metadata_hash = params[:metadata] 
      point_class = Point.new( metadata_hash[:location] )   unless metadata_hash[:location].is_a? Point
      @location = point_class

      @place = metadata_hash[:place]
    end
  end

  def self.all(offset = 0, limit = 0)
    self.mongo_client.database.fs.find.skip(offset).limit(limit).map { |doc| Photo.new(doc) }
  end

  def self.find(input_id)
    doc = self.mongo_client.database.fs.find(:_id=>BSON::ObjectId.from_string(input_id)).first

    doc.nil? ? nil : self.new(doc)
  end

  def self.find_photos_for_place (place_id)
    place_id = BSON::ObjectId.from_string(place_id) if place_id.is_a? String

    mongo_client.database.fs.find('metadata.place': place_id)
  end

  def contents
    f = self.class.mongo_client.database.fs.find_one( :_id => BSON::ObjectId.from_string(@id))

    if f 
      buffer = ""
      f.chunks.reduce([]) do |x, chunk|
        buffer << chunk.data.data
      end
    end

    buffer
  end

  def persisted?
    !@id.nil?
  end

  def save

    if @place.is_a? Place
      @place = BSON::ObjectId.from_string(@place.id)
    end

    if !self.persisted?
      gps_data = EXIFR::JPEG.new(@contents).gps
      point_object = Point.new(:lng => gps_data.longitude, :lat => gps_data.latitude)
      
      # to reset the pointer to the starting of the file as EXIFR and Gridfs are reading the same files
      @contents.rewind

      description = {}
      description[:metadata] = {
        location: point_object.to_hash,
        place: @place
      }

      @location = point_object

      description[:content_type]= "image/jpeg"

      grid_file = Mongo::Grid::File.new(@contents.read, description)
      @id = self.class.mongo_client.database.fs.insert_one(grid_file).to_s
    
    else
      photo_doc = self.class.mongo_client.database.fs.find(:'_id' => BSON::ObjectId.from_string(@id)).first

      photo_doc[:metadata][:location] = @location.to_hash
      photo_doc[:metadata][:place] = @place

      self.class.mongo_client.database.fs.find(:'_id' => BSON::ObjectId.from_string(@id)).update_one(photo_doc)
    end


  end

  def place 
    Place.find(@place.to_s)   unless @place.nil?
  end

  def place=(p)
    if p.is_a? String
      @place = BSON::ObjectId.from_string(p)
    else 
      @place = p
    end
  end

  def destroy 
    self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId.from_string(@id)).delete_one
  end

  def find_nearest_place_id (max_distance)
    Place.near(@location, max_distance).limit(1).first[:_id]
  end
end