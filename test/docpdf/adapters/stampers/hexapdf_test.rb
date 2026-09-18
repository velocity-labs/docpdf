require "test_helper"

if HEXAPDF_AVAILABLE
  require "docpdf/adapters/stampers/hexapdf"

  class StamperHexapdfTest < Minitest::Test
    def test_stamp_all_positions
      positions = [:center, :top, :bottom, :left, :right, :top_left, :top_right, :bottom_left, :bottom_right]
      positions.each do |pos|
        result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [stamp(position: pos)])
        assert valid_pdf?(result), "Failed for position: #{pos}"
      end
    end

    def test_stamp_multiple
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [
        stamp(position: :center, opacity: 0.1),
        stamp(position: :bottom, opacity: 0.3, width: 150)
      ])
      assert valid_pdf?(result)
    end

    def test_stamp_page_indices
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(multi_page_pdf, [stamp], page_indices: [0])
      assert valid_pdf?(result)
      assert_equal 3, pdf_page_count(result)
    end

    def test_stamp_preserves_page_count
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(multi_page_pdf, [stamp])
      assert_equal 3, pdf_page_count(result)
    end

    def test_stamp_produces_valid_pdf
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [stamp(opacity: 0.1)])
      assert valid_pdf?(result)
    end

    def test_stamp_raises_on_pdf_with_no_pages
      error = assert_raises(DocPDF::ConversionError) do
        DocPDF::Adapters::Stampers::Hexapdf.stamp(no_pages_pdf, [stamp])
      end
      assert_match(/no pages/, error.message)
    end

    def test_stamp_raises_when_image_file_is_missing
      assert_raises(DocPDF::ConversionError) do
        DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [stamp(image: "/nonexistent/watermark.png")])
      end
    end

    def test_stamp_symbol_page_size
      DocPDF.configure { |c| c.page_size = :Letter }
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [stamp])
      assert valid_pdf?(result)
    end

    def test_stamp_with_offsets
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [stamp(position: :top_right, offset_x: -20, offset_y: -20)])
      assert valid_pdf?(result)
    end

    def test_text_stamp_produces_valid_pdf
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [text_stamp])
      assert valid_pdf?(result)
    end

    def test_text_stamp_all_positions
      positions = [:center, :top, :bottom, :left, :right, :top_left, :top_right, :bottom_left, :bottom_right]
      positions.each do |pos|
        result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [text_stamp(position: pos)])
        assert valid_pdf?(result), "Failed for position: #{pos}"
      end
    end

    def test_text_stamp_renders_non_latin_text_with_a_font_file
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf,
        [text_stamp(text: cyrillic_text, font: "DejaVuSans", font_file: ttf_font_path)])
      assert valid_pdf?(result)
    end

    def test_text_stamp_with_rotation
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [text_stamp(rotation: 45)])
      assert valid_pdf?(result)
    end

    def test_text_stamp_auto_scales
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf,
        [text_stamp(text: "THIS IS A VERY LONG TEXT THAT SHOULD AUTO SCALE DOWN", font_size: 200)])
      assert valid_pdf?(result)
    end

    def test_text_stamp_with_page_indices
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(multi_page_pdf, [text_stamp], page_indices: [0, 2])
      assert valid_pdf?(result)
      assert_equal 3, pdf_page_count(result)
    end

    def test_mixed_image_and_text_stamps
      result = DocPDF::Adapters::Stampers::Hexapdf.stamp(sample_pdf, [
        stamp(position: :top_right, width: 80),
        text_stamp(position: :center, rotation: 45)
      ])
      assert valid_pdf?(result)
    end

    private

    def stamp(**overrides)
      DocPDF::Watermarker::STAMP_DEFAULTS.merge(image: fixture_path("test.png")).merge(overrides)
    end

    def text_stamp(**overrides)
      wm = DocPDF.configuration.watermark_options
      DocPDF::Watermarker::STAMP_DEFAULTS
        .merge(text: "DRAFT", font: wm[:font], font_size: wm[:font_size], color: wm[:color], rotation: wm[:rotation])
        .merge(overrides)
    end
  end
end
