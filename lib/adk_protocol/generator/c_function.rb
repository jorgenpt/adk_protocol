module AdkProtocol::Generator
  class CFunction < Array
    attr_accessor :return_type, :name, :args
    def initialize(return_type, name, *args)
      super()

      self.return_type = return_type
      self.name = name
      self.args = args
    end

    def prototype
      "#{return_type} #{name}(#{args.join(', ')});"
    end

    def to_s
      "#{return_type} #{name}(#{args.join(', ')}) {\n  " + self.join("\n  ") + "\n}"
    end
  end
end
