require "mini_magick"
require_relative "base"
require_relative "image_normalizer"

module DocPDF
  module Adapters
    module Converters
      class MiniMagick < Base
        MIME_TYPES = %w[image/jpeg image/png image/heic image/heif image/webp].freeze

        class << self
          def convert(data, filename)
            Tempfile.create(["docpdf", File.extname(filename || ".tmp")]) do |input|
              input.binmode
              input.write(data)
              input.flush
              Tempfile.create(["docpdf", ".pdf"]) do |output|
                ::MiniMagick.convert do |convert|
                  convert << "#{input.path}[0]" # first frame only
                  ImageNormalizer.arguments.each { |argument| convert << argument }
                  convert << "pdf:#{output.path}"
                end
                File.binread(output.path)
              end
            end
          rescue ::MiniMagick::Error => e
            raise ConversionError, "MiniMagick failed to convert #{filename || 'image'} to PDF: #{e.message}"
          end
        end
      end
    end
  end
end
