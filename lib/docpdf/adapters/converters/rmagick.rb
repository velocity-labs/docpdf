require "rmagick"
require_relative "base"
require_relative "image_normalizer"

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
              tempfile.flush

              img = normalize(Magick::Image.read(tempfile.path).first, DocPDF.configuration.image_options)
              img.to_blob do |attrs|
                attrs.format = "PDF"
                if (quality = DocPDF.configuration.image_options[:quality])
                  attrs.compression = Magick::JPEGCompression
                  attrs.quality = quality
                end
              end
            end
          rescue Magick::ImageMagickError => e
            raise ConversionError, "RMagick failed to convert #{filename || 'image'} to PDF: #{e.message}"
          ensure
            img&.destroy!
          end

          private

          # Same steps as ImageNormalizer.arguments, through the RMagick API.
          def normalize(img, options)
            img = replace(img, img.auto_orient) if options[:auto_orient]
            img.strip! if options[:strip]
            if options[:background]
              flat = img.alpha? ? img.flatten_images_on(options[:background]) : nil
              img = replace(img, flat) if flat
            end
            if (edge = options[:max_edge]) && [img.columns, img.rows].max > edge
              img = replace(img, img.resize_to_fit(edge, edge))
            end
            if (inches = options[:page_long_edge])
              dpi = [img.columns, img.rows].max / inches.to_f
              img.units = Magick::PixelsPerInchResolution
              img.density = "#{dpi}x#{dpi}"
            end
            img
          end

          def replace(old, new)
            old.destroy! unless old.equal?(new)
            new
          end
        end
      end
    end
  end
end
