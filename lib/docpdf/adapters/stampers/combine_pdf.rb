require "combine_pdf"
require "prawn"
require_relative "base"
require_relative "../../prawn_errors"

module DocPDF
  module Adapters
    module Stampers
      class CombinePdf < Base
        class << self
          def stamp(data, stamps, page_indices: nil)
            source = ::CombinePDF.parse(data)
            source_page = source.pages.first
            raise ConversionError, "Cannot stamp a PDF with no pages" unless source_page
            page_w = source_page[:MediaBox][2].to_f
            page_h = source_page[:MediaBox][3].to_f

            stamp_page_data = generate_stamp_page(stamps, page_w, page_h)
            stamp_page = ::CombinePDF.parse(stamp_page_data).pages.first

            source.pages.each_with_index do |page, idx|
              page << stamp_page if page_indices.nil? || page_indices.include?(idx)
            end
            source.to_pdf
          rescue ::CombinePDF::ParsingError, *PRAWN_ERRORS, Errno::ENOENT => e
            raise ConversionError, "CombinePDF failed to stamp PDF: #{e.message}"
          end

          private

          def fit_font_size(font_size, text, pdf, page_w, page_h)
            max_dim = [page_w, page_h].max * 0.9
            text_w = pdf.width_of(text, size: font_size)
            return font_size if text_w <= max_dim

            (font_size * max_dim / text_w).floor
          end

          def generate_stamp_page(stamps, page_w, page_h)
            ::Prawn::Document.new(page_size: [page_w, page_h], margin: 0) { |pdf|
              stamps.each do |stamp|
                if stamp[:text]
                  render_text_stamp(pdf, stamp)
                else
                  render_image_stamp(pdf, stamp)
                end
              end
            }.render
          end

          def image_dimensions(stamp, pdf)
            img_w = stamp[:width]
            img_h = stamp[:height]

            unless img_h
              _, info = pdf.build_image_object(File.open(stamp[:image], "rb"))
              native_w = info.width.to_f
              native_h = info.height.to_f
              img_h = (img_w.to_f / native_w * native_h).round
            end

            [img_w, img_h]
          end

          def render_image_stamp(pdf, stamp)
            page_w = pdf.bounds.width
            page_h = pdf.bounds.height
            img_w, img_h = image_dimensions(stamp, pdf)

            x, y = Watermarker.calculate_position(
              stamp[:position], page_w, page_h, img_w, img_h,
              stamp[:offset_x], stamp[:offset_y]
            )

            # calculate_position returns bottom-left coordinates, but
            # Prawn's image at: expects the top-left corner
            y += img_h

            image_opts = { at: [x, y], width: img_w }
            image_opts[:height] = img_h if stamp[:height]

            pdf.transparent(stamp[:opacity]) do
              pdf.image stamp[:image], **image_opts
            end
          end

          def render_text_stamp(pdf, stamp)
            page_w = pdf.bounds.width
            page_h = pdf.bounds.height

            pdf.font(stamp[:font])
            font_size = fit_font_size(stamp[:font_size], stamp[:text], pdf, page_w, page_h)
            text_w = pdf.width_of(stamp[:text], size: font_size)
            text_h = font_size.to_f

            rotation = stamp[:rotation] || 0
            rot_w, rot_h = rotated_bounds(text_w, text_h, rotation)

            x, y = Watermarker.calculate_position(
              stamp[:position], page_w, page_h, rot_w, rot_h,
              stamp[:offset_x], stamp[:offset_y]
            )

            cx = x + rot_w / 2.0
            cy = y + rot_h / 2.0

            pdf.transparent(stamp[:opacity]) do
              pdf.rotate(rotation, origin: [cx, cy]) do
                pdf.fill_color(stamp[:color])
                pdf.draw_text(stamp[:text], at: [cx - text_w / 2.0, cy - text_h / 2.0], size: font_size)
              end
            end
          end
        end
      end
    end
  end
end
