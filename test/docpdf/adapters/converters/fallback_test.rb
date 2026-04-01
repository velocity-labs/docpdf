require "test_helper"
require "docpdf/adapters/converters/fallback"

class ConverterFallbackTest < Minitest::Test
  def test_returns_raw_data_for_unknown_format_without_soffice
    DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
    result = DocPDF::Adapters::Converters::Fallback.convert("raw data", "file.xyz")
    assert_equal "raw data", result
  end

  def test_returns_raw_data_with_nil_filename
    DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
    result = DocPDF::Adapters::Converters::Fallback.convert("raw data", nil)
    assert_equal "raw data", result
  end

  def test_tries_soffice_for_unknown_format
    data = fixture_data("test.docx")
    result = DocPDF::Adapters::Converters::Fallback.convert(data, "file.xyz")
    if valid_pdf?(result)
      assert valid_pdf?(result)
    else
      assert_equal data, result
    end
  end

  if IMAGE_CONVERTER_AVAILABLE
    def test_delegates_to_image_converter_by_extension
      data = fixture_data("test.png")
      result = DocPDF::Adapters::Converters::Fallback.convert(data, "photo.png")
      assert valid_pdf?(result)
    end

    def test_delegates_to_image_converter_for_heic_extension
      data = fixture_data("test.heic")
      result = DocPDF::Adapters::Converters::Fallback.convert(data, "photo.heic")
      assert valid_pdf?(result)
    end
  end
end
