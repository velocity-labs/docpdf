require "test_helper"

class ResultTest < Minitest::Test
  def test_defaults_filename_to_nil
    result = DocPDF::Result.new(data: "data")
    assert_nil result.filename
  end

  def test_stores_data_and_filename
    result = DocPDF::Result.new(data: "data", filename: "test.pdf")
    assert_equal "data", result.data
    assert_equal "test.pdf", result.filename
  end

  if STAMPER_AVAILABLE
    def test_watermark_delegates_to_docpdf_watermark
      result = DocPDF::Result.new(data: sample_pdf, filename: "report.pdf")
      stamped = result.watermark({ image: fixture_path("test.png"), opacity: 0.1 })
      assert_instance_of DocPDF::Result, stamped
      assert valid_pdf?(stamped.data)
      assert_equal "report.pdf", stamped.filename
    end
  end
end
