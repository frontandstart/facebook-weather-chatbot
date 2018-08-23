class AnswerJob < ApplicationJob
  queue_as :default

  def perform(type_response)
    message.send(type_response) if message.respond_to?(type_response)
  end

end
