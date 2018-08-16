class Message
  include Mongoid::Document
  embedded_in :user

  field :body # we just store params[:entry][:messaging] json
  


end
