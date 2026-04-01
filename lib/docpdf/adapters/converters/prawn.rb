require "prawn"
require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class Prawn < Base
        MIME_TYPES = %w[text/plain].freeze

        class << self
          def convert(data, _source_filename)
            config = DocPDF.configuration
            opts = config.text_options
            content = data.dup.force_encoding("UTF-8")
            pdf = ::Prawn::Document.new(page_size: config.page_size, margin: opts[:margins])
            pdf.font(opts[:font], size: opts[:font_size])
            pdf.text content, color: opts[:color]
            pdf.render
          rescue ::Prawn::Errors::UnknownFont, ::Prawn::Errors::CannotFit => e
            raise ConversionError, "Prawn failed to render text to PDF: #{e.message}"
          end
        end
      end
    end
  end
end
