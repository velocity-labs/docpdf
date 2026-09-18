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

    def test_convert_line_separator_becomes_newline
      content = pdf_text(DocPDF::Adapters::Converters::Prawn.convert("Line one Line two", nil))
      assert_includes content, "Line one"
      assert_includes content, "Line two"
    end

    def test_convert_multi_line
      content = pdf_text(DocPDF::Adapters::Converters::Prawn.convert("Line one\nLine two\nLine three", nil))
      assert_includes content, "Line one"
      assert_includes content, "Line three"
    end

    def test_convert_paragraph_separator_becomes_newline
      content = pdf_text(DocPDF::Adapters::Converters::Prawn.convert("Para one Para two", nil))
      assert_includes content, "Para one"
      assert_includes content, "Para two"
    end

    def test_convert_produces_valid_pdf
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert("Hello from Prawn", nil))
    end

    # Prawn's built-in AFM fonts are Windows-1252 only. Text outside it still
    # cannot render, but it must surface as a DocPDF error, not Prawn's.
    def test_convert_raises_conversion_error_for_unsupported_characters
      error = assert_raises(DocPDF::ConversionError) do
        DocPDF::Adapters::Converters::Prawn.convert("Иванов", nil)
      end
      assert_match(/Prawn failed to render text/, error.message)
    end

    def test_convert_renders_non_latin_text_with_a_font_file
      DocPDF.configure { |c| c.text_options = c.text_options.merge(font: "DejaVuSans", font_file: ttf_font_path) }
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert(cyrillic_text, nil))
    end

    def test_convert_accepts_a_font_file_style_hash
      DocPDF.configure { |c| c.text_options = c.text_options.merge(font: "DejaVuSans", font_file: { normal: ttf_font_path }) }
      assert valid_pdf?(DocPDF::Adapters::Converters::Prawn.convert(cyrillic_text, nil))
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
