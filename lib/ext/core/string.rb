class String
  def snakecase
    gsub(/([a-z])([A-Z])/, '\1_\2').downcase
  end
end
