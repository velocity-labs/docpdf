require "rmagick"
require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class Rmagick < Base
        MIME_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze

        class << self
          def convert(data, filename)
            img = nil
            Tempfile.create(["docpdf", File.extname(filename || ".tmp")]) do |tempfile|
              tempfile.binmode
              tempfile.write(data)
              tempfile.rewind

              img = Magick::Image.read(tempfile.path).first
              img.to_blob { |attrs| attrs.format = "PDF" }
            end
          rescue Magick::ImageMagickError => e
            raise ConversionError, "RMagick failed to convert #{filename || 'image'} to PDF: #{e.message}"
          ensure
            img&.destroy!
          end
        end
      end
    end
  end
end
