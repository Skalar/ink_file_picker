module InkFilePicker
  module Assignable

    def []=(name, value)
      public_send "#{name}=", value
    end

    def [](name)
      public_send name
    end


    private

    def assign(attributes)
      attributes.each_pair do |name, value|
        self[name] = value
      end
    end
  end
end
