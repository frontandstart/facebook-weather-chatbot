class User
  include Mongoid::Document
  field :facebook_id, type: Integer
  has_many :messages

end
