class User
  include Mongoid::Document
  field :facebook_id
  embeds_many :messages

end
