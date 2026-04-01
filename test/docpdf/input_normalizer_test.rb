require "test_helper"

class InputNormalizerTest < Minitest::Test
  def test_active_storage_attachment
    attachment = FakeActiveStorageAttachment.new(fixture_data("test.pdf"), "report.pdf", "application/pdf")
    normalizer = DocPDF::InputNormalizer.new(attachment)
    assert normalizer.data.start_with?("%PDF")
    assert_equal "report.pdf", normalizer.filename
    assert_equal "application/pdf", normalizer.mime_type
  end

  def test_active_storage_filename_override
    attachment = FakeActiveStorageAttachment.new("content", "original.pdf", "application/pdf")
    normalizer = DocPDF::InputNormalizer.new(attachment, filename: "custom.pdf")
    assert_equal "custom.pdf", normalizer.filename
  end

  def test_active_storage_mime_type_override
    attachment = FakeActiveStorageAttachment.new("content", "file.pdf", "application/pdf")
    normalizer = DocPDF::InputNormalizer.new(attachment, mime_type: "application/octet-stream")
    assert_equal "application/octet-stream", normalizer.mime_type
  end

  def test_binary_data_nil_mime_without_filename
    normalizer = DocPDF::InputNormalizer.new(data: "hello")
    assert_nil normalizer.mime_type
  end

  def test_binary_data_sets_mime_from_filename
    normalizer = DocPDF::InputNormalizer.new(data: "hello", filename: "notes.txt")
    assert_equal "text/plain", normalizer.mime_type
  end

  def test_binary_data_used_as_is
    data = fixture_data("test.pdf")
    normalizer = DocPDF::InputNormalizer.new(data: data, filename: "test.pdf")
    assert_equal data, normalizer.data
  end

  def test_binary_string_treated_as_data_not_path
    pdf_bytes = fixture_data("test.pdf")
    normalizer = DocPDF::InputNormalizer.new(pdf_bytes)
    assert_equal pdf_bytes, normalizer.data
    assert_nil normalizer.filename
  end

  def test_binary_string_with_null_bytes_treated_as_data
    binary = "some\x00binary\x00data"
    normalizer = DocPDF::InputNormalizer.new(binary)
    assert_equal binary, normalizer.data
  end

  def test_data_wrapper_extracts_data_name_and_mime_type
    attachment = FakeAttachment.new(fixture_data("test.pdf"), "document.pdf", "application/pdf")
    normalizer = DocPDF::InputNormalizer.new(attachment)
    assert normalizer.data.start_with?("%PDF")
    assert_equal "document.pdf", normalizer.filename
    assert_equal "application/pdf", normalizer.mime_type
  end

  def test_data_wrapper_filename_override
    attachment = FakeAttachment.new("content", "original.doc", "application/msword")
    normalizer = DocPDF::InputNormalizer.new(attachment, filename: "custom.doc")
    assert_equal "custom.doc", normalizer.filename
  end

  def test_data_wrapper_mime_type_override
    attachment = FakeAttachment.new("content", "file.doc", "application/msword")
    normalizer = DocPDF::InputNormalizer.new(attachment, mime_type: "application/pdf")
    assert_equal "application/pdf", normalizer.mime_type
  end

  def test_file_path_accepts_pathname
    normalizer = DocPDF::InputNormalizer.new(Pathname.new(fixture_path("test.pdf")))
    assert normalizer.data.start_with?("%PDF")
  end

  def test_file_path_allows_overriding_filename
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"), filename: "custom.pdf")
    assert_equal "custom.pdf", normalizer.filename
  end

  def test_file_path_allows_overriding_mime_type
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"), mime_type: "application/octet-stream")
    assert_equal "application/octet-stream", normalizer.mime_type
  end

  def test_file_path_detects_mime_type
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"))
    assert_equal "application/pdf", normalizer.mime_type
  end

  def test_file_path_extracts_filename
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"))
    assert_equal "test.pdf", normalizer.filename
  end

  def test_file_path_reads_binary_data
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"))
    assert normalizer.data.start_with?("%PDF")
  end

  def test_file_path_string_still_reads_file
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.pdf"))
    assert normalizer.data.start_with?("%PDF")
    assert_equal "test.pdf", normalizer.filename
  end

  def test_filename_override_does_not_change_mime_detection
    attachment = FakeAttachment.new(fixture_data("test.heic"), "test.heic", "image/heic")
    normalizer = DocPDF::InputNormalizer.new(attachment, filename: "Jane-Smith-report.pdf")
    assert_equal "Jane-Smith-report.pdf", normalizer.filename
    assert_equal "image/heic", normalizer.mime_type
  end

  def test_filename_override_does_not_change_mime_for_file_path
    normalizer = DocPDF::InputNormalizer.new(fixture_path("test.heic"), filename: "document.pdf")
    assert_equal "document.pdf", normalizer.filename
    assert_equal "image/heic", normalizer.mime_type
  end

  def test_filename_override_does_not_change_mime_for_io
    upload = FakeUpload.new(fixture_data("test.heic"), "scan.heic")
    normalizer = DocPDF::InputNormalizer.new(upload, filename: "document.pdf")
    assert_equal "document.pdf", normalizer.filename
    assert_equal "image/heic", normalizer.mime_type
  end

  def test_io_kwarg_extracts_original_filename
    upload = FakeUpload.new("file contents", "photo.png")
    normalizer = DocPDF::InputNormalizer.new(io: upload)
    assert_equal "photo.png", normalizer.filename
  end

  def test_io_like_object_as_positional_arg
    io = StringIO.new(fixture_data("test.pdf"))
    normalizer = DocPDF::InputNormalizer.new(io, filename: "test.pdf")
    assert normalizer.data.start_with?("%PDF")
    assert_equal "test.pdf", normalizer.filename
  end

  def test_io_like_object_extracts_original_filename
    upload = FakeUpload.new("file contents", "document.docx")
    normalizer = DocPDF::InputNormalizer.new(upload)
    assert_equal "file contents", normalizer.data
    assert_equal "document.docx", normalizer.filename
    assert_equal "application/vnd.openxmlformats-officedocument.wordprocessingml.document", normalizer.mime_type
  end

  def test_io_like_object_filename_override_only_affects_output_name
    upload = FakeUpload.new("file contents", "document.docx")
    normalizer = DocPDF::InputNormalizer.new(upload, filename: "custom.txt")
    assert_equal "custom.txt", normalizer.filename
    assert_equal "application/vnd.openxmlformats-officedocument.wordprocessingml.document", normalizer.mime_type
  end

  def test_io_reads_data
    io = StringIO.new(fixture_data("test.pdf"))
    normalizer = DocPDF::InputNormalizer.new(io: io, filename: "test.pdf")
    assert normalizer.data.start_with?("%PDF")
  end

  def test_io_uses_provided_filename
    io = StringIO.new("hello")
    normalizer = DocPDF::InputNormalizer.new(io: io, filename: "notes.txt")
    assert_equal "notes.txt", normalizer.filename
    assert_equal "text/plain", normalizer.mime_type
  end

  def test_nonexistent_path_treated_as_data
    normalizer = DocPDF::InputNormalizer.new("/nonexistent/file.pdf")
    assert_equal "/nonexistent/file.pdf", normalizer.data
  end

  def test_pathname_with_filename_override
    normalizer = DocPDF::InputNormalizer.new(Pathname.new(fixture_path("test.pdf")), filename: "custom.pdf")
    assert_equal "custom.pdf", normalizer.filename
    assert_equal "application/pdf", normalizer.mime_type
  end

  def test_raises_without_input
    assert_raises(ArgumentError) { DocPDF::InputNormalizer.new }
  end
end
