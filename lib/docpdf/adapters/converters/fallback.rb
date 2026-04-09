require_relative "base"
require_relative "soffice"

module DocPDF
  module Adapters
    module Converters
      # Fallback converter for unrecognized mime types. Tries three strategies
      # in order:
      #
      # 1. If the source filename has a known image extension, detect its mime
      #    type and delegate to the appropriate image converter.
      # 2. Attempt conversion via LibreOffice (soffice), which can handle many
      #    formats not explicitly registered.
      # 3. If soffice is unavailable or fails, return the raw data unchanged.
      class Fallback < Base
        IMAGE_EXTENSIONS = %w[.heic .heif .webp .jpg .jpeg .png].freeze

        class << self
          def convert(data, source_filename)
            convert_by_extension(data, source_filename) ||
              convert_with_soffice(data, source_filename) ||
              data
          end

          private

          def convert_by_extension(data, source_filename)
            ext = source_filename ? File.extname(source_filename).downcase : nil
            return unless ext && IMAGE_EXTENSIONS.include?(ext)

            mime_type = MimeDetector.detect(source_filename)
            return unless mime_type

            ConverterResolver.resolve(mime_type).convert(data, source_filename)
          end

          def convert_with_soffice(data, source_filename)
            Soffice.convert(data, source_filename)
          rescue SofficeNotFoundError, ConversionError
            nil
          end
        end
      end
    end
  end
end
