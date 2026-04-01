require "test_helper"
require "docpdf/adapters/converters/passthrough"

class ConverterPassthroughTest < Minitest::Test
  def test_returns_data_unchanged
    data = fixture_data("test.pdf")
    assert_equal data, DocPDF::Adapters::Converters::Passthrough.convert(data, "test.pdf")
  end

  def test_handles_pdf_mime_type
    assert_includes DocPDF::Adapters::Converters::Passthrough::MIME_TYPES, "application/pdf"
  end
end
