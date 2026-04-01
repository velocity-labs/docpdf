require "test_helper"

class DocPDFTest < Minitest::Test
  def test_configuration_returns_configuration_instance
    assert_instance_of DocPDF::Configuration, DocPDF.configuration
  end

  def test_configuration_returns_same_instance
    assert_same DocPDF.configuration, DocPDF.configuration
  end

  def test_configure_yields_configuration
    DocPDF.configure do |config|
      config.soffice_path = "/usr/bin/soffice"
      config.page_size = "A4"
    end

    assert_equal "/usr/bin/soffice", DocPDF.configuration.soffice_path
    assert_equal "A4", DocPDF.configuration.page_size
  end

  def test_has_version_number
    refute_nil DocPDF::VERSION
  end

  def test_reset_configuration
    DocPDF.configure { |c| c.page_size = "A4" }
    DocPDF.reset_configuration!
    assert_equal "LETTER", DocPDF.configuration.page_size
  end

  if STAMPER_AVAILABLE
    def test_chain_preserves_filename
      result = DocPDF.convert(fixture_path("test.docx"))
        .watermark({ image: fixture_path("test.png"), opacity: 0.1 })
      assert_equal "test.pdf", result.filename
    end

    def test_chain_with_multiple_stamps
      result = DocPDF.convert(fixture_path("test.txt")).watermark(
        { image: fixture_path("test.png"), opacity: 0.1, position: :center },
        { image: fixture_path("test.png"), opacity: 0.3, position: :bottom, width: 150 })
      assert valid_pdf?(result.data)
    end

    def test_convert_then_watermark_chain
      result = DocPDF.convert(fixture_path("test.txt"))
        .watermark({ image: fixture_path("test.png"), opacity: 0.1 })
      assert_instance_of DocPDF::Result, result
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_watermark_with_convert_result
      convert_result = DocPDF.convert(fixture_path("test.pdf"))
      result = DocPDF.watermark(convert_result, { image: fixture_path("test.png"), opacity: 0.1 })
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_watermark_with_file_path
      result = DocPDF.watermark(fixture_path("test.pdf"), { image: fixture_path("test.png"), opacity: 0.1 })
      assert_instance_of DocPDF::Result, result
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end
  end
end
