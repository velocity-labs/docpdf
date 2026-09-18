require "hexapdf"
require_relative "base"

module DocPDF
  module Adapters
    module Stampers
      class Hexapdf < Base
        class << self
          def stamp(data, stamps, page_indices: nil)
            doc = HexaPDF::Document.new(io: StringIO.new(data))
            source_page = doc.pages[0]
            raise ConversionError, "Cannot stamp a PDF with no pages" unless source_page
            page_w = source_page.box.width
            page_h = source_page.box.height

            stamp_page_data = generate_stamp_page(stamps, page_w, page_h)
            stamp_doc = HexaPDF::Document.new(io: StringIO.new(stamp_page_data))
            stamp_form = doc.import(stamp_doc.pages[0].to_form_xobject)

            doc.pages.each_with_index do |page, idx|
              page.canvas(type: :overlay).xobject(stamp_form, at: [0, 0]) if page_indices.nil? || page_indices.include?(idx)
            end

            write_to_string(doc)
          rescue HexaPDF::Error => e
            raise ConversionError, "HexaPDF failed to stamp PDF: #{e.message}"
          end

          private

          def fit_font_size(font_size, glyph_units, page_w, page_h)
            max_dim = [page_w, page_h].max * 0.9
            text_w = glyph_units * font_size / 1000.0
            return font_size if text_w <= max_dim

            (max_dim * 1000.0 / glyph_units).floor
          end

          def generate_stamp_page(stamps, page_w, page_h)
            doc = HexaPDF::Document.new
            page = doc.pages.add([0, 0, page_w, page_h])
            canvas = page.canvas

            stamps.each do |stamp|
              if stamp[:text]
                render_text_stamp(canvas, page, stamp, doc)
              else
                render_image_stamp(canvas, page, stamp, doc)
              end
            end

            write_to_string(doc)
          end

          def image_dimensions(stamp, doc)
            img_w = stamp[:width]
            img_h = stamp[:height]

            unless img_h
              image = doc.images.add(File.open(stamp[:image], "rb"))
              native_w = image.width.to_f
              native_h = image.height.to_f
              img_h = (img_w.to_f / native_w * native_h).round
            end

            [img_w, img_h]
          end

          def render_image_stamp(canvas, page, stamp, doc)
            page_w = page.box.width
            page_h = page.box.height
            img_w, img_h = image_dimensions(stamp, doc)

            x, y = Watermarker.calculate_position(
              stamp[:position], page_w, page_h, img_w, img_h,
              stamp[:offset_x], stamp[:offset_y]
            )

            image_opts = { at: [x, y], width: img_w }
            image_opts[:height] = img_h if stamp[:height]

            canvas.opacity(fill_alpha: stamp[:opacity]) do
              canvas.image(File.open(stamp[:image], "rb"), **image_opts)
            end
          end

          def render_text_stamp(canvas, page, stamp, doc)
            page_w = page.box.width
            page_h = page.box.height

            font = doc.fonts.add(stamp[:font])
            glyph_units = font.decode_utf8(stamp[:text]).sum { |g| g.width }
            font_size = fit_font_size(stamp[:font_size], glyph_units, page_w, page_h)
            text_w = glyph_units * font_size / 1000.0
            text_h = font_size.to_f

            rotation = stamp[:rotation] || 0
            rot_w, rot_h = rotated_bounds(text_w, text_h, rotation)

            x, y = Watermarker.calculate_position(
              stamp[:position], page_w, page_h, rot_w, rot_h,
              stamp[:offset_x], stamp[:offset_y]
            )

            cx = x + rot_w / 2.0
            cy = y + rot_h / 2.0

            canvas.opacity(fill_alpha: stamp[:opacity]) do
              canvas.save_graphics_state do
                canvas.translate(cx, cy)
                canvas.rotate(rotation) if rotation != 0
                canvas.font(stamp[:font], size: font_size)
                canvas.fill_color(stamp[:color])
                canvas.text(stamp[:text], at: [-text_w / 2.0, -text_h / 2.0])
              end
            end
          end

          def write_to_string(doc)
            io = StringIO.new
            doc.write(io)
            io.string
          end
        end
      end
    end
  end
end
