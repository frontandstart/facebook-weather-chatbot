class User
  include Mongoid::Document
  field :facebook_id, type: Integer
  embeds_many :messages, cascade_callbacks: true


end
