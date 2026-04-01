require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class Passthrough < Base
        MIME_TYPES = %w[application/pdf].freeze

        class << self
          def convert(data, _source_filename)
            data
          end
        end
      end
    end
  end
end
