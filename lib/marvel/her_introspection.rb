module Her
  module Model
    module Introspection
      # Monkey patch this method to use attributes[k] instead of send
      def inspect
        resource_path = begin
          request_path
        rescue Her::Errors::PathError => e
          "<unknown path, missing `#{e.missing_parameter}`>"
        end

        "#<#{self.class}(#{resource_path}) #{attributes.keys.map { |k| "#{k}=#{attribute_for_inspect(attributes[k])}" }.join(" ")}>"
      end
    end
  end
end

