module InkFilePicker
  module Utils
    module Blank
      STRING_MATCHER = /\A[[:space:]]*\z/

      def self.blank?(object)
        case object
        when String
          STRING_MATCHER === object
        when Hash, Array
          object.empty?
        when TrueClass, Numeric
          false
        when FalseClass, NilClass
          true
        else
          object.respond_to?(:empty?) ? !!object.empty? : !self
        end
      end
    end
  end
end
