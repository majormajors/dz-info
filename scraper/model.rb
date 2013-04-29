require 'mongoid'

module DzInfo
  module Model
    class Dropzone
      include Mongoid::Document

      field :name, type: String
      field :coordinates, type: Array
      field :rating, type: Float
      field :location_name, type: String
      field :address, type: String
      field :contact, type: String
      field :rates, type: String
      field :url, type: String
      field :aircraft, type: String
      field :training, type: String
      field :on_site_services, type: String
      field :hook_turns_allowed, type: Boolean
      field :aad_required, type: Boolean
      field :uspa_membership_required, type: Boolean
      field :source, type: String
    end
  end
end
