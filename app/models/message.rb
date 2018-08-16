class Message
  include Mongoid::Document
  belongs_to :user
  field :body # we just store params[:entry][:messaging] json

end
