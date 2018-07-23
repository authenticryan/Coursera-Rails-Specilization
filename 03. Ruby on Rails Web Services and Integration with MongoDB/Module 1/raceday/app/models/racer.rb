class Racer 

    attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

    include ActiveModel::Model

    def persisted?
        !(@id.nil?)
    end
    
    def updated_at
        nil
    end

    def created_at
        nil
    end

    def initialize(params = {})
        # _id indicates the query is coming from mongo cli and :id indicates from the webpage
        @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
        @number = params[:number] || nil
        @first_name = params[:first_name] || nil
        @last_name = params[:last_name] || nil
        @gender = params[:gender] || nil
        @group = params[:group] || nil
        @secs = params[:secs].to_i || nil
    end

    def self.mongo_client
        Mongoid::Clients.default
    end

    def self.collection
        self.mongo_client[:racers]
    end

    def self.all (prototype = {}, sort = {number: 1}, skip = 0, limit = nil)
        prototype = prototype.symbolize_keys.slice(:number, :first_name, :last_name, :gender, :group, :secs) unless prototype.nil?
        sort = sort.symbolize_keys.slice(:number, :first_name, :last_name, :gender, :group, :secs) unless sort.nil?

        limit ||= 0
        self.collection.find(prototype).sort(sort).skip(skip).limit(limit)
    end

    def self.find id
        # all _id are stored as BSON Object id in the mongo database. Thus, we convert the sting to Bson Object ID
        id = BSON::ObjectId.from_string(id) if id.is_a? String

        entry = self.collection.find(_id: id).first
        return entry.nil? ? nil : Racer.new(entry)
    end

  #implememts the will_paginate paginate method that accepts
  # page - number >= 1 expressing offset in pages
  # per_page - row limit within a single page
  # also take in some custom parameters like
  # sort - order criteria for document
  # (terms) - used as a prototype for selection
  # This method uses the all() method as its implementation
  # and returns instantiated Zip classes within a will_paginate
  # page
  def self.paginate(params)
    Rails.logger.debug("paginate(#{params})")
    page=(params[:page] ||= 1).to_i
    limit=(params[:per_page] ||= 30).to_i
    offset=(page-1)*limit
    sort=params[:sort] ||= {}

    #get the associated page of Zips -- eagerly convert doc to Zip
    racer=[]
    all(params, sort, offset, limit).each do |doc|
      racer << Racer.new(doc)
    end

    #get a count of all documents in the collection
    total=all(params, sort, 0, 1).count
    
    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racer)
    end    
  end


    def save 
        result = self.class.collection.insert_one(number: @number, first_name: @first_name, last_name: @last_name, gender: @gender, group: @group, secs: @secs)

        @id = result.inserted_id
    end

    def update(params)
        @number = params[:number].to_i
        @first_name = params[:first_name]
        @last_name = params[:last_name]
        @secs = params[:secs].to_i
        @gender = params[:gender]
        @group = params[:group]

        params = params.symbolize_keys.slice(:number, :first_name, :last_name, :secs, :gender, :group)

        id = BSON::ObjectId.from_string(@id) if @id.is_a? String

        self.class.collection.find("_id": id).update_one(params)
    end

    def destroy 
        self.class.collection.find("number": @number).delete_one
    end
end
