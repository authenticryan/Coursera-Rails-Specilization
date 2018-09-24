class Place 

  include ActiveModel::Model

  attr_accessor :id, :formatted_address, :location, :address_components

  # sample input hash
  #  @hash = {:_id=>BSON::ObjectId('56521833e301d0284000003d'), 
  #   formatted_address:"Wilsden, West Yorkshire, UK",
  #   geometry:
  #    {
  #      location:{lat:53.8256035, lng:-1.8625303},
  #      geolocation:{type:"Point", coordinates:[-1.8625303, 53.8256035]}
  #    },
  #    address_components: 
  #    [
  #      {long_name:"Wilsden", short_name:"Wilsden",
  #       types:["administrative_area_level_4", "political"]},
  #      {long_name:"Bradford District", short_name:"Bradford District",
  #       types:["administrative_area_level_3", "political"]}
  #    ]

  def initialize (params)
    params = params.symbolize_keys.slice(:_id, :address_components, :formatted_address, :geometry)

    @id = params[:_id].to_s                               if params[:_id]
    @formatted_address = params[:formatted_address]       if params[:formatted_address]
    @location = Point.new( params[:geometry][:geolocation] )                     if params[:geometry]

    @address_components = []
    params[:address_components].each {|address| @address_components.push(AddressComponent.new(address) )} unless params[:address_components].nil?
  end

  # create connnecitons with database
  def self.mongo_client
    Mongoid::Clients.default
  end

  # load the specific collection required for the model
  def self.collection
    mongo_client[:places]   # calls places collections
  end

  def self.load_all(input_json_file)
    if input_json_file
      json_file_content = JSON.parse(input_json_file.read)
      
      json_file_content.each do |document|
        collection.insert_one(document)
      end
    end
  end

  def self.find_by_short_name(name)
    collection.find('address_components.short_name' => name)
  end

  # to itterate over all documents found, make them a Place instance and return a array of collection
  def self.to_places(matched_places)
    temp_array =[]
    matched_places.each do |document|
      temp_array.push(Place.new(document))
    end
    temp_array
  end

  def self.find(id)
    document = collection.find(:_id => BSON::ObjectId.from_string(id)).first
    Place.new(document) if document
  end

  # returns all documents as Place objects with given offset and limit
  def self.all(offset = 0, limit = Place.collection.count)
    documents = collection.aggregate([ {:$skip => offset}, {:$limit => limit} ])
    temp_array = []
    documents.each do |document|
      temp_array.push(Place.new(document))
    end

    temp_array
  end

  def self.get_address_components (sort={:_id => 1}, offset = 0, limit = 10000)
    self.collection.find.aggregate([ {:$sort => sort} , {:$unwind => "$address_components"},  {:$skip => offset} , {:$limit => limit} , {:$project => {address_components: 1, formatted_address: 1, 'geometry.geolocation': 1}} ])
  end

  def self.get_country_names
    self.collection.find.aggregate([ {:$project => {'address_components.long_name': true, 'address_components.types': true, :_id => false}}, 
          {:$unwind => "$address_components"}, {:$unwind => "$address_components.types"}, 
          {:$match => { "address_components.types": "country" }}, {:$group => {_id: "$address_components.long_name"}} ])
          .to_a.map {|h| h[:_id]}
  end

  
  def self.find_ids_by_country_code (country_code)
    self.collection.find.aggregate([ {:$project => { "address_components.short_name": true }}, 
        {:$unwind => "$address_components"}, {:$match => {:"address_components.short_name" => country_code}}, 
        {:$project => {:_id => true}}]).to_a.map {|d| d[:_id].to_s}

  end

  def self.create_indexes
    self.collection.indexes.create_one({ 'geometry.geolocation': Mongo::Index::GEO2DSPHERE })
  end

  def self.remove_indexes
    self.collection.indexes.drop_one('geometry.geolocation_2dsphere')
  end

  def self.near (point_hash, max_distance_in_meters = nil)
    return self.collection.find('geometry.geolocation': {:$near => {:$geometry => point_hash.to_hash, 
        :$maxDistance=> max_distance_in_meters}}) unless max_distance_in_meters.nil?

    self.collection.find('geometry.geolocation': {:$near => {:$geometry => point_hash.to_hash}})
  end

  def photos(offset = 0, limit = 0)
    Photo.mongo_client.database.fs.find('metadata.place': BSON::ObjectId.from_string(@id)).map {|photo| Photo.new(photo) }
  end

  def near (max_distance = nil)
    documents_nearby = self.class.near( self.location.to_hash, max_distance)
    self.class.to_places(documents_nearby)
  end

  def destroy
    self.class.collection.find(:_id => BSON::ObjectId.from_string(@id)).delete_one
    @id = nil
  end

  def persisted 
    !@id.nil?
  end

end