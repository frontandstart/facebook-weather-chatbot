class Message
  include Mongoid::Document
  belongs_to :user, inverse_of: :messages
  field :body # we just store params[:entry][:messaging] json
  


end
