require "mini_magick"
require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class MiniMagick < Base
        MIME_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze

        class << self
          def convert(data, filename)
            img = nil
            Tempfile.create(["docpdf", File.extname(filename || ".tmp")]) do |tempfile|
              tempfile.binmode
              tempfile.write(data)
              tempfile.rewind

              img = ::MiniMagick::Image.open(tempfile.path)
              img.format("pdf")
              img.to_blob
            end
          rescue ::MiniMagick::Error => e
            raise ConversionError, "MiniMagick failed to convert #{filename || 'image'} to PDF: #{e.message}"
          ensure
            img&.destroy!
          end
        end
      end
    end
  end
end
