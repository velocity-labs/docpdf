require "test_helper"

if RMAGICK_AVAILABLE
  require "docpdf/adapters/converters/rmagick"

  class ConverterRmagickTest < Minitest::Test
    CONVERTER = DocPDF::Adapters::Converters::Rmagick

    def page_size(pdf)
      page = PDF::Reader.new(StringIO.new(pdf)).pages.first
      box = page.attributes[:MediaBox]
      [(box[2] - box[0]).round, (box[3] - box[1]).round]
    end

    # 400x300 pixels with EXIF "rotate 90 clockwise" and a GPS latitude.
    def sideways_photo_with_location = fixture_data("test_sideways_gps.jpg")

    def test_turns_a_sideways_photo_upright_on_a_sheet_sized_page
      pdf = CONVERTER.convert(sideways_photo_with_location, "photo.jpg")
      assert_equal [594, 792], page_size(pdf) # portrait, 11-inch long edge
    end

    def test_strips_metadata
      pdf = CONVERTER.convert(sideways_photo_with_location, "photo.jpg")
      refute_includes pdf, "Exif"
      refute_includes pdf, "GPS"
    end

    def test_page_long_edge_nil_keeps_one_point_per_pixel
      DocPDF.configure { |c| c.image_options = c.image_options.merge(page_long_edge: nil, auto_orient: false) }
      assert_equal [400, 300], page_size(CONVERTER.convert(sideways_photo_with_location, "photo.jpg"))
    ensure
      DocPDF.reset_configuration!
    end

    def test_shrinks_large_photos
      big = Tempfile.create(["big", ".png"]) do |file|
        system("magick", "-size", "4000x3000", "xc:white", file.path, exception: true)
        File.binread(file.path)
      end
      DocPDF.configure { |c| c.image_options = c.image_options.merge(page_long_edge: nil) }
      assert_equal [2400, 1800], page_size(CONVERTER.convert(big, "big.png"))
    ensure
      DocPDF.reset_configuration!
    end
    def test_converts_heic
      assert valid_pdf?(DocPDF::Adapters::Converters::Rmagick.convert(fixture_data("test.heic"), "test.heic"))
    end

    def test_converts_jpeg
      assert valid_pdf?(DocPDF::Adapters::Converters::Rmagick.convert(fixture_data("test.jpg"), "test.jpg"))
    end

    def test_converts_png
      assert valid_pdf?(DocPDF::Adapters::Converters::Rmagick.convert(fixture_data("test.png"), "test.png"))
    end

    def test_converts_webp
      assert valid_pdf?(DocPDF::Adapters::Converters::Rmagick.convert(fixture_data("test.webp"), "test.webp"))
    end

    def test_nil_filename_uses_tmp_extension
      assert valid_pdf?(DocPDF::Adapters::Converters::Rmagick.convert(fixture_data("test.jpg"), nil))
    end

    def test_raises_on_invalid_data
      error = assert_raises(DocPDF::ConversionError) do
        DocPDF::Adapters::Converters::Rmagick.convert("not a valid image", "bad.jpg")
      end
      assert_match(/RMagick failed to convert bad\.jpg/, error.message)
    end
  end
end
