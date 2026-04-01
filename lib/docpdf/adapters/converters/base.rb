module DocPDF
  module Adapters
    module Converters
      class Base
        MIME_TYPES = [].freeze

        class << self
          def convert(data, source_filename)
            raise NotImplementedError, "#{name} must implement .convert(data, source_filename)"
          end
        end
      end
    end
  end
end
