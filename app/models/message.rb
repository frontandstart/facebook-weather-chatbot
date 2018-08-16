class Message
  include Mongoid::Document
  has_one :user
  field :body # we just store params[:entry][:messaging] json

end
