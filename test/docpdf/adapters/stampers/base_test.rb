require "test_helper"
require "docpdf/adapters/stampers/base"

class StamperBaseTest < Minitest::Test
  def test_raises_not_implemented
    assert_raises(NotImplementedError) { DocPDF::Adapters::Stampers::Base.stamp("data", [{}]) }
  end
end
