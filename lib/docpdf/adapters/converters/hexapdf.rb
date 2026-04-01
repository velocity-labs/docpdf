require "hexapdf"
require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class Hexapdf < Base
        MIME_TYPES = %w[text/plain].freeze

        HEXAPDF_PAGE_SIZES = {
          "LETTER" => :Letter, "LEGAL" => :Legal, "TABLOID" => :Tabloid,
          "A0" => :A0, "A1" => :A1, "A2" => :A2, "A3" => :A3, "A4" => :A4,
          "A5" => :A5, "A6" => :A6, "B0" => :B0, "B1" => :B1, "B2" => :B2,
          "B3" => :B3, "B4" => :B4, "B5" => :B5, "B6" => :B6,
        }.freeze

        class << self
          def convert(data, _source_filename)
            config = DocPDF.configuration
            opts = config.text_options
            content = data.dup.force_encoding("UTF-8")
            page_size = normalize_page_size(config.page_size)

            doc = HexaPDF::Document.new
            page = doc.pages.add(page_size)
            canvas = page.canvas

            canvas.font(opts[:font], size: opts[:font_size])
            canvas.fill_color(opts[:color])

            margins = opts[:margins]
            y = page.box.height - margins[0]
            line_height = opts[:font_size] * 1.4

            content.each_line do |line|
              if y < margins[2]
                page = doc.pages.add(page_size)
                canvas = page.canvas
                canvas.font(opts[:font], size: opts[:font_size])
                canvas.fill_color(opts[:color])
                y = page.box.height - margins[0]
              end
              canvas.text(line.chomp, at: [margins[3], y])
              y -= line_height
            end

            write_to_string(doc)
          rescue HexaPDF::Error => e
            raise ConversionError, "HexaPDF failed to render text to PDF: #{e.message}"
          end

          private

          def normalize_page_size(size)
            return size if size.is_a?(Symbol)

            HEXAPDF_PAGE_SIZES[size.to_s.upcase] || size.to_sym
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
