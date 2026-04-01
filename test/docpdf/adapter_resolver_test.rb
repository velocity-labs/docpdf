require "test_helper"

class ConverterResolverTest < Minitest::Test
  def test_resolves_fallback_for_nil_mime_type
    adapter = DocPDF::ConverterResolver.resolve(nil)
    assert_equal "DocPDF::Adapters::Converters::Fallback", adapter.name
  end

  def test_resolves_fallback_for_unknown_mime_type
    adapter = DocPDF::ConverterResolver.resolve("application/octet-stream")
    assert_equal "DocPDF::Adapters::Converters::Fallback", adapter.name
  end

  def test_resolves_passthrough_for_pdf
    adapter = DocPDF::ConverterResolver.resolve("application/pdf")
    assert_equal "DocPDF::Adapters::Converters::Passthrough", adapter.name
  end

  def test_resolves_soffice_for_docx
    adapter = DocPDF::ConverterResolver.resolve("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
    assert_equal "DocPDF::Adapters::Converters::Soffice", adapter.name
  end

  def test_resolves_soffice_for_rtf
    adapter = DocPDF::ConverterResolver.resolve("text/rtf")
    assert_equal "DocPDF::Adapters::Converters::Soffice", adapter.name
  end

  if PRAWN_AVAILABLE
    def test_resolves_prawn_for_text
      adapter = DocPDF::ConverterResolver.resolve("text/plain")
      assert_equal "DocPDF::Adapters::Converters::Prawn", adapter.name
    end
  end

  if HEXAPDF_AVAILABLE && !PRAWN_AVAILABLE
    def test_resolves_hexapdf_for_text_when_prawn_unavailable
      adapter = DocPDF::ConverterResolver.resolve("text/plain")
      assert_equal "DocPDF::Adapters::Converters::Hexapdf", adapter.name
    end
  end

  if RMAGICK_AVAILABLE
    def test_resolves_rmagick_for_images
      adapter = DocPDF::ConverterResolver.resolve("image/jpeg")
      assert_equal "DocPDF::Adapters::Converters::Rmagick", adapter.name
    end
  end

  if MINI_MAGICK_AVAILABLE && !RMAGICK_AVAILABLE
    def test_resolves_mini_magick_for_images_when_rmagick_unavailable
      adapter = DocPDF::ConverterResolver.resolve("image/jpeg")
      assert_equal "DocPDF::Adapters::Converters::MiniMagick", adapter.name
    end
  end

  unless TEXT_CONVERTER_AVAILABLE
    def test_resolves_fallback_for_text_when_no_text_converters
      adapter = DocPDF::ConverterResolver.resolve("text/plain")
      assert_equal "DocPDF::Adapters::Converters::Fallback", adapter.name
    end
  end

  unless IMAGE_CONVERTER_AVAILABLE
    def test_resolves_fallback_for_images_when_no_image_converters
      adapter = DocPDF::ConverterResolver.resolve("image/jpeg")
      assert_equal "DocPDF::Adapters::Converters::Fallback", adapter.name
    end
  end
end

class StamperResolverTest < Minitest::Test
  if HEXAPDF_AVAILABLE
    def test_auto_detects_hexapdf_stamper
      adapter = DocPDF::StamperResolver.resolve
      assert_equal "DocPDF::Adapters::Stampers::Hexapdf", adapter.name
    end

    def test_resolves_configured_hexapdf_stamper
      DocPDF.configure { |c| c.stamper = :hexapdf }
      adapter = DocPDF::StamperResolver.resolve
      assert_equal "DocPDF::Adapters::Stampers::Hexapdf", adapter.name
    end
  end

  if COMBINE_PDF_AVAILABLE && PRAWN_AVAILABLE
    def test_resolves_configured_combine_pdf_stamper
      DocPDF.configure { |c| c.stamper = :combine_pdf }
      adapter = DocPDF::StamperResolver.resolve
      assert_equal "DocPDF::Adapters::Stampers::CombinePdf", adapter.name
    end
  end

  def test_raises_for_unknown_stamper
    DocPDF.configure { |c| c.stamper = :nonexistent }
    assert_raises(DocPDF::AdapterNotFoundError) { DocPDF::StamperResolver.resolve }
  end

  unless STAMPER_AVAILABLE
    def test_raises_when_no_stampers_available
      assert_raises(DocPDF::AdapterNotFoundError) { DocPDF::StamperResolver.resolve }
    end
  end

  unless STAMPER_AVAILABLE
    def test_stamper_not_found_propagates_through_watermark
      pdf = fixture_data("test.pdf")
      assert_raises(DocPDF::AdapterNotFoundError) do
        DocPDF.watermark(pdf, { image: fixture_path("test.png"), opacity: 0.1 })
      end
    end
  end
end
