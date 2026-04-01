require "docpdf/version"
require "docpdf/configuration"
require "docpdf/errors"
require "docpdf/result"
require "docpdf/input_normalizer"
require "docpdf/mime_detector"
require "docpdf/converter_resolver"
require "docpdf/stamper_resolver"
require "docpdf/converter"
require "docpdf/watermarker"

# Multi-format document-to-PDF converter with pluggable adapters and optional
# watermarking. Supports Word, Excel, PowerPoint, OpenDocument, CSV, HTML, RTF,
# plain text, images, and PDF passthrough.
#
#   result = DocPDF.convert("report.docx")
#   result = DocPDF.convert(uploaded_file, filename: "report.pdf")
#   result = DocPDF.convert("report.docx").watermark({ image: "logo.png", opacity: 0.1 })
module DocPDF
  class << self
    # Returns the global Configuration instance.
    #
    #   DocPDF.configuration.soffice_path # => "soffice"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the global Configuration instance for modification.
    #
    # Options:
    #   soffice_path      - Path to the LibreOffice binary (default: "soffice")
    #   stamper           - Stamper adapter: :hexapdf, :combine_pdf, or nil for auto-detect (default: nil)
    #   page_size         - Page size for text rendering: "LETTER", "A4", etc. (default: "LETTER")
    #   text_options      - Hash of plain text conversion settings:
    #                         font: "Courier", font_size: 10, margins: [50, 50, 50, 50], color: "333333"
    #   watermark_options - Hash of text watermark defaults:
    #                         font: "Helvetica", font_size: 72, color: "AAAAAA", rotation: 45
    #
    #   DocPDF.configure do |c|
    #     c.soffice_path = "/usr/bin/soffice"
    #     c.stamper = :hexapdf
    #     c.page_size = "A4"
    #     c.text_options = { font: "Helvetica", font_size: 12, margins: [72, 72, 72, 72], color: "000000" }
    #     c.watermark_options = { font: "Times", font_size: 96, color: "FF0000", rotation: 30 }
    #   end
    def configure
      yield(configuration)
    end

    # Converts a document to PDF. Accepts a file path, Pathname, IO object,
    # Active Storage attachment, Dragonfly attachment, or raw binary data.
    # Returns a Result with the PDF bytes and filename.
    #
    # Options:
    #   io        - An IO object to read from (alternative to positional source)
    #   data      - Raw binary string to convert (alternative to positional source)
    #   filename  - Output filename override (default: derived from source)
    #   mime_type - MIME type override (default: detected from filename extension)
    #
    #   result = DocPDF.convert("report.docx")
    #   result = DocPDF.convert(upload)
    #   result = DocPDF.convert(data: raw_bytes, mime_type: "image/png", filename: "photo.png")
    #
    #   result.data     # => PDF binary string
    #   result.filename # => "report.pdf"
    def convert(source = nil, **options)
      Converter.call(source, **options)
    end

    # Resets configuration to defaults. Primarily used in tests.
    def reset_configuration!
      @configuration = Configuration.new
    end

    # Applies watermark stamps to a PDF. Accepts the same source types as
    # .convert, plus a Result object. Returns a Result.
    #
    # Each stamp is a Hash with either an :image or :text key:
    #
    # Image stamp keys:
    #   image    - Path to the watermark image file
    #   opacity  - Transparency level, 0.0 to 1.0 (default: 0.1)
    #   position - Placement on the page (default: :center)
    #              One of: :center, :top, :bottom, :left, :right, :top_left, :top_right, :bottom_left, :bottom_right
    #   width    - Image width in points (default: 250)
    #   height   - Image height in points (default: proportional to width)
    #   offset_x - Horizontal offset in points (default: 0)
    #   offset_y - Vertical offset in points (default: 0)
    #   pages    - Which pages to stamp (default: :all)
    #              One of: :all, :first, :last, :odd, :even, Integer, Array, or Range
    #
    # Text stamp keys:
    #   text      - The text to render (e.g., "DRAFT", "CONFIDENTIAL")
    #   opacity   - Transparency level, 0.0 to 1.0 (default: 0.1)
    #   position  - Placement on the page (default: :center)
    #   font      - Font name (default from watermark_options: "Helvetica")
    #   font_size - Font size in points (default from watermark_options: 72)
    #   color     - Hex color string (default from watermark_options: "AAAAAA")
    #   rotation  - Rotation in degrees, counter-clockwise (default from watermark_options: 45)
    #   offset_x  - Horizontal offset in points (default: 0)
    #   offset_y  - Vertical offset in points (default: 0)
    #   pages     - Which pages to stamp (default: :all)
    #
    # Text is auto-scaled to fit the page when the font size would cause overflow.
    #
    #   result = DocPDF.watermark("doc.pdf",
    #     { image: "logo.png", opacity: 0.1, position: :top_right, width: 80 },
    #     { text: "DRAFT", opacity: 0.1, position: :center, rotation: 45 })
    #
    # Chainable from a convert result:
    #   DocPDF.convert("report.docx").watermark({ text: "DRAFT", opacity: 0.1 })
    def watermark(source = nil, *stamps, **options)
      Watermarker.call(source, *stamps, **options)
    end
  end
end
