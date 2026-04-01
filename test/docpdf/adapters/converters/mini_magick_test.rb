require "test_helper"

if MINI_MAGICK_AVAILABLE
  require "docpdf/adapters/converters/mini_magick"

  class ConverterMiniMagickTest < Minitest::Test
    def test_converts_heic
      assert valid_pdf?(DocPDF::Adapters::Converters::MiniMagick.convert(fixture_data("test.heic"), "test.heic"))
    end

    def test_converts_jpeg
      assert valid_pdf?(DocPDF::Adapters::Converters::MiniMagick.convert(fixture_data("test.jpg"), "test.jpg"))
    end

    def test_converts_png
      assert valid_pdf?(DocPDF::Adapters::Converters::MiniMagick.convert(fixture_data("test.png"), "test.png"))
    end

    def test_converts_webp
      assert valid_pdf?(DocPDF::Adapters::Converters::MiniMagick.convert(fixture_data("test.webp"), "test.webp"))
    end

    def test_nil_filename_uses_tmp_extension
      assert valid_pdf?(DocPDF::Adapters::Converters::MiniMagick.convert(fixture_data("test.jpg"), nil))
    end

    def test_raises_on_invalid_data
      error = assert_raises(DocPDF::ConversionError) do
        DocPDF::Adapters::Converters::MiniMagick.convert("not a valid image", "bad.jpg")
      end
      assert_match(/MiniMagick failed to convert bad\.jpg/, error.message)
    end
  end
end
