require "test_helper"

class ConfigurationTest < Minitest::Test
  def test_default_page_size
    assert_equal "LETTER", DocPDF::Configuration.new.page_size
  end

  def test_default_soffice_path
    assert_equal "soffice", DocPDF::Configuration.new.soffice_path
  end

  def test_default_text_options
    opts = DocPDF::Configuration.new.text_options
    assert_equal "Courier", opts[:font]
    assert_equal 10, opts[:font_size]
    assert_equal [50, 50, 50, 50], opts[:margins]
    assert_equal "333333", opts[:color]
  end

  def test_default_watermark_options
    opts = DocPDF::Configuration.new.watermark_options
    assert_equal "Helvetica", opts[:font]
    assert_equal 72, opts[:font_size]
    assert_equal "AAAAAA", opts[:color]
    assert_equal 45, opts[:rotation]
  end

  def test_nil_stamper_default
    assert_nil DocPDF::Configuration.new.stamper
  end

  def test_setting_all_attributes
    config = DocPDF::Configuration.new
    config.soffice_path = "/usr/bin/soffice"
    config.stamper = :hexapdf
    config.page_size = "A4"
    config.text_options = { font: "Helvetica", font_size: 12, margins: [72, 72, 72, 72], color: "000000" }
    config.watermark_options = { font: "Times", font_size: 96, color: "FF0000", rotation: 30 }

    assert_equal "/usr/bin/soffice", config.soffice_path
    assert_equal :hexapdf, config.stamper
    assert_equal "A4", config.page_size
    assert_equal "Helvetica", config.text_options[:font]
    assert_equal 96, config.watermark_options[:font_size]
  end
end
