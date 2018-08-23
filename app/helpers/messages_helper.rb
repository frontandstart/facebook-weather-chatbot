module MessagesHelper

  def find_type(text)
    text = text.to_s.strip.downcase.sub!(' ', '_')
    Message::TYPES.each do |type|
      return type if type == text
    end
    return nil
  end

end
