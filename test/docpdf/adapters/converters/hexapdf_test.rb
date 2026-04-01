require "test_helper"

if HEXAPDF_AVAILABLE
  require "docpdf/adapters/converters/hexapdf"

  class ConverterHexapdfTest < Minitest::Test
    def test_convert_empty_string
      assert valid_pdf?(DocPDF::Adapters::Converters::Hexapdf.convert("", nil))
    end

    def test_convert_includes_content
      assert_includes pdf_text(DocPDF::Adapters::Converters::Hexapdf.convert("Unique hexapdf content 67890", nil)),
        "Unique hexapdf content 67890"
    end

    def test_convert_long_text_overflows_to_multiple_pages
      long_text = (1..200).map { |i| "Line number #{i} with some content" }.join("\n")
      result = DocPDF::Adapters::Converters::Hexapdf.convert(long_text, nil)
      assert valid_pdf?(result)
      assert_operator pdf_page_count(result), :>, 1
    end

    def test_convert_multi_line
      content = pdf_text(DocPDF::Adapters::Converters::Hexapdf.convert("Line one\nLine two\nLine three", nil))
      assert_includes content, "Line one"
      assert_includes content, "Line three"
    end

    def test_convert_produces_valid_pdf
      assert valid_pdf?(DocPDF::Adapters::Converters::Hexapdf.convert("Hello from HexaPDF", nil))
    end

    def test_convert_symbol_page_size
      DocPDF.configure { |c| c.page_size = :Letter }
      assert valid_pdf?(DocPDF::Adapters::Converters::Hexapdf.convert("Symbol page size test", nil))
    end

    def test_convert_unknown_page_size_string
      DocPDF.configure { |c| c.page_size = "Executive" }
      assert valid_pdf?(DocPDF::Adapters::Converters::Hexapdf.convert("test", nil))
    end

    def test_handles_text_plain
      assert_includes DocPDF::Adapters::Converters::Hexapdf::MIME_TYPES, "text/plain"
    end
  end
end
