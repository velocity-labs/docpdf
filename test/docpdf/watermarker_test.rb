require "test_helper"

if STAMPER_AVAILABLE
  class WatermarkerTest < Minitest::Test
    def test_accepts_binary_string_not_as_file_path
      assert valid_pdf?(DocPDF::Watermarker.call(fixture_data("test.pdf"), { image: img }).data)
    end

    def test_accepts_file_path
      result = DocPDF::Watermarker.call(fixture_path("test.pdf"), { image: img })
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_accepts_io_object
      result = DocPDF::Watermarker.call(StringIO.new(sample_pdf), { image: img }, filename: "report.pdf")
      assert valid_pdf?(result.data)
      assert_equal "report.pdf", result.filename
    end

    def test_accepts_pathname
      result = DocPDF::Watermarker.call(Pathname.new(fixture_path("test.pdf")), { image: img })
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_accepts_raw_pdf_bytes
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img }).data)
    end

    def test_accepts_result_object
      convert_result = DocPDF.convert(fixture_path("test.pdf"))
      result = DocPDF::Watermarker.call(convert_result, { image: img })
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_both_offsets
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :bottom_right, offset_x: -10, offset_y: 10 }).data)
    end

    def test_custom_opacity
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, opacity: 0.5 }).data)
    end

    def test_custom_width
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, width: 100 }).data)
    end

    def test_custom_width_and_height
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, width: 200, height: 100 }).data)
    end

    def test_io_extracts_original_filename
      result = DocPDF::Watermarker.call(FakeUpload.new(sample_pdf, "uploaded.pdf"), { image: img })
      assert_equal "uploaded.pdf", result.filename
    end

    def test_mixed_pages_across_stamps
      result = DocPDF::Watermarker.call(multi_page_pdf,
        { image: img, opacity: 0.05, pages: :all },
        { image: img, opacity: 0.3, position: :top_right, width: 50, pages: :first })
      assert valid_pdf?(result.data)
      assert_equal 3, pdf_page_count(result.data)
    end

    def test_multi_page_preserves_count
      assert_equal 3, pdf_page_count(DocPDF::Watermarker.call(multi_page_pdf, { image: img }).data)
    end

    def test_multi_page_stamps_all
      result = DocPDF::Watermarker.call(multi_page_pdf, { image: img })
      assert_operator result.data.bytesize, :>, multi_page_pdf.bytesize
    end

    def test_negative_offset_x
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :top_right, offset_x: -20 }).data)
    end

    def test_negative_offset_y
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :top, offset_y: -20 }).data)
    end

    def test_pages_array
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      subset_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: [1, 3] })
      assert valid_pdf?(subset_result.data)
      assert_operator subset_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_even
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      even_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :even })
      assert valid_pdf?(even_result.data)
      assert_operator even_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_first_only_stamps_first_page
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      first_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :first })
      assert valid_pdf?(first_result.data)
      assert_equal 3, pdf_page_count(first_result.data)
      assert_operator first_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_last_only_stamps_last_page
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      last_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :last })
      assert valid_pdf?(last_result.data)
      assert_operator last_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_odd
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      odd_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :odd })
      assert valid_pdf?(odd_result.data)
      assert_operator odd_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_range
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      range_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: 2..3 })
      assert valid_pdf?(range_result.data)
      assert_operator range_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_pages_specific_number
      all_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: :all })
      page2_result = DocPDF::Watermarker.call(multi_page_pdf, { image: img, pages: 2 })
      assert valid_pdf?(page2_result.data)
      assert_operator page2_result.data.bytesize, :<, all_result.data.bytesize
    end

    def test_passthrough_preserves_filename
      assert_equal "report.pdf", DocPDF::Watermarker.call(sample_pdf, filename: "report.pdf").filename
    end

    def test_positive_offset_x
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :center, offset_x: 50 }).data)
    end

    def test_positive_offset_y
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :bottom, offset_y: 30 }).data)
    end

    %i[center top bottom left right top_left top_right bottom_left bottom_right].each do |pos|
      define_method("test_position_#{pos}") do
        assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: pos }).data)
      end
    end

    def test_raises_for_pdf_with_no_pages
      assert_raises(DocPDF::ConversionError) { DocPDF::Watermarker.call(no_pages_pdf, { image: img }) }
    end

    def test_raises_for_pdf_with_no_pages_when_targeting_specific_pages
      assert_raises(DocPDF::ConversionError) { DocPDF::Watermarker.call(no_pages_pdf, { image: img, pages: :first }) }
    end

    def test_raises_for_unsupported_type
      assert_raises(ArgumentError) { DocPDF::Watermarker.call(12345, { image: img }) }
    end

    def test_raises_without_input
      assert_raises(ArgumentError) { DocPDF::Watermarker.call }
    end

    def test_result_filename_override
      convert_result = DocPDF::Result.new(data: sample_pdf, filename: "original.pdf")
      result = DocPDF::Watermarker.call(convert_result, { image: img }, filename: "custom.pdf")
      assert_equal "custom.pdf", result.filename
    end

    def test_returns_result_object
      assert_instance_of DocPDF::Result, DocPDF::Watermarker.call(sample_pdf, { image: img })
    end

    def test_returns_result_with_filename
      result = DocPDF::Watermarker.call(sample_pdf, { image: img }, filename: "report.pdf")
      assert_equal "report.pdf", result.filename
    end

    def test_returns_unchanged_when_no_stamps
      assert_equal sample_pdf, DocPDF::Watermarker.call(sample_pdf).data
    end

    def test_single_stamp_produces_larger_output
      result = DocPDF::Watermarker.call(sample_pdf, { image: img, opacity: 0.1 })
      assert_operator result.data.bytesize, :>, sample_pdf.bytesize
    end

    def test_single_stamp_produces_valid_pdf
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, opacity: 0.1 }).data)
    end

    def test_three_stamps
      result = DocPDF::Watermarker.call(sample_pdf,
        { image: img, position: :top_left, width: 50, offset_x: 10, offset_y: -10 },
        { image: img, position: :center, opacity: 0.05, width: 300 },
        { image: img, position: :bottom, opacity: 0.3, width: 150 })
      assert valid_pdf?(result.data)
    end

    def test_two_stamps
      result = DocPDF::Watermarker.call(sample_pdf,
        { image: img, opacity: 0.06, position: :center, width: 200 },
        { image: img, opacity: 0.3, position: :bottom, width: 150, offset_y: 30 })
      assert valid_pdf?(result.data)
    end

    if HEXAPDF_AVAILABLE
      def test_hexapdf_all_positions
        DocPDF.configure { |c| c.stamper = :hexapdf }
        assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, position: :bottom_right, offset_x: -10, offset_y: 10 }).data)
      end

      def test_hexapdf_multiple_stamps
        DocPDF.configure { |c| c.stamper = :hexapdf }
        result = DocPDF::Watermarker.call(sample_pdf,
          { image: img, position: :center, opacity: 0.1 },
          { image: img, position: :bottom, opacity: 0.3, width: 150 })
        assert valid_pdf?(result.data)
      end

      def test_hexapdf_single_stamp
        DocPDF.configure { |c| c.stamper = :hexapdf }
        assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img, opacity: 0.1 }).data)
      end

      def test_hexapdf_symbol_page_size
        DocPDF.configure { |c| c.page_size = :Letter; c.stamper = :hexapdf }
        assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { image: img }).data)
      end
    end

    # Text watermarks

    def test_text_stamp_produces_valid_pdf
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { text: "DRAFT", opacity: 0.1 }).data)
    end

    def test_text_stamp_with_rotation
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { text: "DRAFT", opacity: 0.1, rotation: 45 }).data)
    end

    def test_text_stamp_uses_watermark_options_defaults
      DocPDF.configure { |c| c.watermark_options = { font: "Courier", font_size: 48, color: "FF0000", rotation: 30 } }
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf, { text: "CUSTOM" }).data)
    end

    def test_text_stamp_overrides_defaults
      assert valid_pdf?(DocPDF::Watermarker.call(sample_pdf,
        { text: "OVERRIDE", font: "Courier", font_size: 36, color: "0000FF", rotation: 0 }).data)
    end

    def test_mixed_text_and_image_stamps
      result = DocPDF::Watermarker.call(sample_pdf,
        { text: "DRAFT", opacity: 0.1, position: :center, rotation: 45 },
        { image: img, opacity: 0.3, position: :top_right, width: 80 })
      assert valid_pdf?(result.data)
    end

    def test_text_stamp_with_page_targeting
      result = DocPDF::Watermarker.call(multi_page_pdf,
        { text: "FIRST PAGE", opacity: 0.1, pages: :first, rotation: 0 },
        { text: "ALL PAGES", opacity: 0.05, pages: :all, rotation: 45 })
      assert valid_pdf?(result.data)
      assert_equal 3, pdf_page_count(result.data)
    end

    # Input via keyword args

    def test_accepts_data_keyword
      result = DocPDF::Watermarker.call(nil, { image: img }, data: sample_pdf, filename: "test.pdf")
      assert valid_pdf?(result.data)
    end

    def test_accepts_io_keyword
      io = StringIO.new(sample_pdf)
      result = DocPDF::Watermarker.call(nil, { image: img }, io: io, filename: "test.pdf")
      assert valid_pdf?(result.data)
    end

    private

    def img
      fixture_path("test.png")
    end
  end
end
