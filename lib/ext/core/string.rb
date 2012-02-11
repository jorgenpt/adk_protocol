class String
  def snakecase
    gsub(/([a-z])([A-Z])/, '\1_\2').downcase
  end

  def with_lineno
    file, lineno = caller.first.split(':')
    "#line #{lineno} \"#{file}\"\n#{self}"
  end
end
