require "test_helper"

if PRAWN_AVAILABLE
  require "docpdf/adapters/converters/prawn"

  class ConverterPrawnTest < Minitest::Test
    def test_convert_empty_string
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert("", nil))
    end

    def test_convert_includes_content
      assert_includes pdf_text(DocPDF::Adapters::Converters::Prawn.convert("Unique prawn content 12345", nil)),
        "Unique prawn content 12345"
    end

    def test_convert_multi_line
      content = pdf_text(DocPDF::Adapters::Converters::Prawn.convert("Line one\nLine two\nLine three", nil))
      assert_includes content, "Line one"
      assert_includes content, "Line three"
    end

    def test_convert_produces_valid_pdf
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert("Hello from Prawn", nil))
    end

    def test_convert_respects_configuration
      DocPDF.configure { |c| c.page_size = "A4"; c.text_options = c.text_options.merge(font_size: 14) }
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert("Configured text", nil))
    end

    def test_handles_text_plain
      assert_includes DocPDF::Adapters::Converters::Prawn::MIME_TYPES, "text/plain"
    end
  end
end
