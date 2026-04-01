require "test_helper"
require "docpdf/adapters/converters/base"

class ConverterBaseTest < Minitest::Test
  def test_raises_not_implemented
    assert_raises(NotImplementedError) { DocPDF::Adapters::Converters::Base.convert("data", "file.txt") }
  end
end
