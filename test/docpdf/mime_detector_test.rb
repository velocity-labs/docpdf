require "test_helper"

class MimeDetectorTest < Minitest::Test
  EXPECTED = {
    "document.pdf"   => "application/pdf",
    "document.doc"   => "application/msword",
    "document.docx"  => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "spreadsheet.xls"  => "application/vnd.ms-excel",
    "spreadsheet.xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "slides.ppt"   => "application/vnd.ms-powerpoint",
    "slides.pptx"  => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "document.odt" => "application/vnd.oasis.opendocument.text",
    "spreadsheet.ods" => "application/vnd.oasis.opendocument.spreadsheet",
    "slides.odp"   => "application/vnd.oasis.opendocument.presentation",
    "data.csv"     => "text/csv",
    "page.html"    => "text/html",
    "page.htm"     => "text/html",
    "notes.txt"    => "text/plain",
    "document.rtf" => "text/rtf",
    "photo.jpg"    => "image/jpeg",
    "photo.jpeg"   => "image/jpeg",
    "photo.png"    => "image/png",
    "photo.heic"   => "image/heic",
    "photo.heif"   => "image/heif",
    "photo.webp"   => "image/webp",
  }.freeze

  EXPECTED.each do |filename, mime|
    define_method("test_detects_#{filename.tr('.', '_')}") do
      assert_equal mime, DocPDF::MimeDetector.detect(filename)
    end
  end

  def test_case_insensitive
    assert_equal "application/pdf", DocPDF::MimeDetector.detect("DOCUMENT.PDF")
    assert_equal "image/jpeg", DocPDF::MimeDetector.detect("Photo.JPEG")
  end

  def test_nil_for_dotfile
    assert_nil DocPDF::MimeDetector.detect(".pdf")
  end

  def test_nil_for_empty_string
    assert_nil DocPDF::MimeDetector.detect("")
  end

  def test_nil_for_nil_filename
    assert_nil DocPDF::MimeDetector.detect(nil)
  end

  def test_nil_for_no_extension
    assert_nil DocPDF::MimeDetector.detect("document")
  end

  def test_nil_for_unknown_extension
    assert_nil DocPDF::MimeDetector.detect("file.xyz")
  end
end
