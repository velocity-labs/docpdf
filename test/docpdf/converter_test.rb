require "test_helper"

class ConverterTest < Minitest::Test
  def test_accepts_file_path
    assert valid_pdf?(DocPDF.convert(fixture_path("test.pdf")).data)
  end

  def test_accepts_io_object
    io = StringIO.new(fixture_data("test.pdf"))
    assert valid_pdf?(DocPDF.convert(io: io, mime_type: "application/pdf", filename: "test.pdf").data)
  end

  def test_accepts_raw_binary_data
    assert valid_pdf?(DocPDF.convert(data: fixture_data("test.pdf"), mime_type: "application/pdf").data)
  end

  def test_application_rtf_mime_type
    data = fixture_data("test.rtf")
    result = DocPDF.convert(data: data, mime_type: "application/rtf", filename: "doc.rtf")
    assert valid_pdf?(result.data)
  end

  def test_csv_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.csv")).data)
  end

  def test_doc_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.doc")).data)
  end

  def test_docx_produces_valid_pdf
    result = DocPDF.convert(fixture_path("test.docx"))
    assert valid_pdf?(result.data)
    assert_equal "test.pdf", result.filename
  end

  def test_html_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.html")).data)
  end

  def test_odp_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.odp")).data)
  end

  def test_ods_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.ods")).data)
  end

  def test_odt_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.odt")).data)
  end

  def test_pdf_passthrough
    data = fixture_data("test.pdf")
    result = DocPDF.convert(data: data, mime_type: "application/pdf", filename: "test.pdf")
    assert_equal data, result.data
    assert_equal "test.pdf", result.filename
  end

  def test_ppt_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.ppt")).data)
  end

  def test_pptx_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.pptx")).data)
  end

  def test_rtf_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.rtf")).data)
  end

  def test_unknown_falls_back_to_raw_bytes_with_nil_filename
    DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
    result = DocPDF.convert(data: "raw data", mime_type: "application/octet-stream")
    assert_equal "raw data", result.data
  end

  def test_unknown_falls_back_to_raw_bytes_without_soffice
    DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
    result = DocPDF.convert(data: "raw data", mime_type: "application/octet-stream", filename: "file.xyz")
    assert_equal "raw data", result.data
  end

  def test_unknown_falls_back_to_soffice_or_raw_bytes
    result = DocPDF.convert(data: "raw data", mime_type: "application/octet-stream", filename: "file.xyz")
    if valid_pdf?(result.data)
      assert valid_pdf?(result.data)
    else
      assert_equal "raw data", result.data
    end
  end

  def test_unknown_nil_filename_with_soffice
    data = fixture_data("test.docx")
    result = DocPDF.convert(data: data, mime_type: "application/octet-stream")
    assert_instance_of String, result.data
  end

  def test_xls_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.xls")).data)
  end

  def test_xlsx_produces_valid_pdf
    assert valid_pdf?(DocPDF.convert(fixture_path("test.xlsx")).data)
  end

  if TEXT_CONVERTER_AVAILABLE
    def test_changes_extension_to_pdf
      result = DocPDF.convert(data: "text", mime_type: "text/plain", filename: "notes.txt")
      assert_equal "notes.pdf", result.filename
    end

    def test_defaults_to_converted_pdf
      result = DocPDF.convert(data: "text", mime_type: "text/plain")
      assert_equal "converted.pdf", result.filename
    end

    def test_filename_multiple_dots
      result = DocPDF.convert(data: "text", mime_type: "text/plain", filename: "my.report.v2.txt")
      assert_equal "my.report.v2.pdf", result.filename
    end

    def test_filename_no_extension
      result = DocPDF.convert(data: "text", mime_type: "text/plain", filename: "myfile")
      assert_equal "myfile.pdf", result.filename
    end

    def test_text_contains_content
      result = DocPDF.convert(data: "Specific test content here", mime_type: "text/plain", filename: "notes.txt")
      assert_includes pdf_text(result.data), "Specific test content here"
    end

    def test_text_from_file_path
      result = DocPDF.convert(fixture_path("test.txt"))
      assert valid_pdf?(result.data)
      assert_equal "test.pdf", result.filename
    end

    def test_text_produces_valid_pdf
      result = DocPDF.convert(data: "Hello, world!", mime_type: "text/plain", filename: "notes.txt")
      assert valid_pdf?(result.data)
      assert_equal "notes.pdf", result.filename
    end
  end

  if IMAGE_CONVERTER_AVAILABLE
    def test_heic_produces_valid_pdf
      assert valid_pdf?(DocPDF.convert(fixture_path("test.heic")).data)
    end

    def test_heic_with_octet_stream_mime_uses_source_extension
      attachment = FakeAttachment.new(fixture_data("test.heic"), "test.heic", "application/octet-stream")
      result = DocPDF.convert(attachment, filename: "Jane-Smith-report.pdf")
      assert valid_pdf?(result.data)
      assert_equal "Jane-Smith-report.pdf", result.filename
    end

    def test_heic_with_pdf_filename_still_converts_image
      attachment = FakeAttachment.new(fixture_data("test.heic"), "test.heic", "image/heic")
      result = DocPDF.convert(attachment, filename: "Jane-Smith-report.pdf")
      assert valid_pdf?(result.data)
      assert_equal "Jane-Smith-report.pdf", result.filename
    end

    def test_jpeg_produces_valid_pdf
      assert valid_pdf?(DocPDF.convert(fixture_path("test.jpeg")).data)
    end

    def test_jpg_produces_valid_pdf
      assert valid_pdf?(DocPDF.convert(fixture_path("test.jpg")).data)
    end

    def test_png_produces_valid_pdf
      assert valid_pdf?(DocPDF.convert(fixture_path("test.png")).data)
    end

    def test_unknown_mime_with_image_extension
      data = fixture_data("test.png")
      result = DocPDF.convert(data: data, mime_type: "application/x-unknown", filename: "photo.png")
      assert valid_pdf?(result.data)
    end

    def test_unknown_mime_with_image_extension_without_soffice
      DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
      data = fixture_data("test.png")
      result = DocPDF.convert(data: data, mime_type: "application/x-unknown", filename: "photo.png")
      assert valid_pdf?(result.data)
    end

    def test_webp_produces_valid_pdf
      assert valid_pdf?(DocPDF.convert(fixture_path("test.webp")).data)
    end
  end
end
