require "prawn"
require_relative "base"
require_relative "../../prawn_errors"

module DocPDF
  module Adapters
    module Converters
      class Prawn < Base
        MIME_TYPES = %w[text/plain].freeze

        # U+2028 LINE SEPARATOR and U+2029 PARAGRAPH SEPARATOR mean "break the
        # line", but Windows-1252 has no room for them, so Prawn's built-in fonts
        # reject them. Text pasted out of word processors and web pages carries
        # them routinely, so translate to a newline instead of failing on it.
        LINE_SEPARATORS = /[  ]/

        class << self
          def convert(data, _source_filename)
            config = DocPDF.configuration
            opts = config.text_options
            content = normalize(data)
            pdf = ::Prawn::Document.new(page_size: config.page_size, margin: opts[:margins])
            pdf.font(opts[:font], size: opts[:font_size])
            pdf.text content, color: opts[:color]
            pdf.render
          rescue *PRAWN_ERRORS, ::Encoding::UndefinedConversionError => e
            raise ConversionError, "Prawn failed to render text to PDF: #{e.message}"
          end

          private

          def normalize(data)
            data.dup.force_encoding("UTF-8").gsub(LINE_SEPARATORS, "\n")
          end
        end
      end
    end
  end
end
