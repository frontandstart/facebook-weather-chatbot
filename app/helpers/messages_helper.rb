module MessagesHelper
  def parse_body_for(text)
    return nil if text.blank?
    text = text.to_s.strip.downcase.parameterize.underscore
    Message::CATEGORIES.each do |category|
      return category if category == text
    end
    nil
  end
end