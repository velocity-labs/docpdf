require "test_helper"
require "docpdf/adapters/converters/soffice"

class ConverterSofficeTest < Minitest::Test
  def test_converts_docx
    result = DocPDF::Adapters::Converters::Soffice.convert(fixture_data("test.docx"), "test.docx")
    assert valid_pdf?(result)
  end

  def test_handles_office_mime_types
    assert_includes DocPDF::Adapters::Converters::Soffice::MIME_TYPES, "application/msword"
    assert_includes DocPDF::Adapters::Converters::Soffice::MIME_TYPES, "text/csv"
    assert_includes DocPDF::Adapters::Converters::Soffice::MIME_TYPES, "text/rtf"
  end

  def test_raises_conversion_error_when_soffice_fails
    script = Tempfile.new(["fake_soffice", ".sh"])
    script.write("#!/bin/sh\nexit 1\n")
    script.close
    File.chmod(0o755, script.path)

    DocPDF.configure { |c| c.soffice_path = script.path }
    assert_raises(DocPDF::ConversionError) do
      DocPDF::Adapters::Converters::Soffice.convert("fake", "bad.doc")
    end
  ensure
    script&.unlink
  end

  def test_concurrent_conversions_do_not_conflict
    data = fixture_data("test.docx")
    results = Array.new(3)
    threads = 3.times.map do |i|
      Thread.new { results[i] = DocPDF::Adapters::Converters::Soffice.convert(data, "test.docx") }
    end
    threads.each(&:join)
    results.each_with_index do |result, i|
      assert valid_pdf?(result), "Concurrent conversion #{i} failed"
    end
  end

  def test_raises_soffice_not_found_when_not_installed
    DocPDF.configure { |c| c.soffice_path = "/nonexistent/soffice" }
    assert_raises(DocPDF::SofficeNotFoundError) do
      DocPDF::Adapters::Converters::Soffice.convert("fake", "bad.doc")
    end
  end
end
