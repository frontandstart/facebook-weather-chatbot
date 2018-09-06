class AnswerJob < ApplicationJob
  queue_as :default

  def perform(message)
    response_type = "#{message.category}_response"
    message.send(response_type) if message.respond_to?(response_type)
  end

end