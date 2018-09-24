class AddressComponent

    attr_reader :long_name, :short_name, :types

    # input comes in the format
    # {:long_name=>"Bradford District", :short_name=>"Bradford District", 
    # :types=>["administrative_area_level_3", "political"]},
    def initialize (params)
        params = params.symbolize_keys.slice(:long_name, :short_name, :types)

        @long_name = params[:long_name]     if params[:long_name]
        @short_name = params[:short_name]   if params[:short_name]
        @types = params[:types]             if params[:types]
    end
end