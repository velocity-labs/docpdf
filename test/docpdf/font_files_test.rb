require "test_helper"

class FontFilesTest < Minitest::Test
  def test_normalize_returns_nil_for_nil
    assert_nil DocPDF::FontFiles.normalize(nil)
  end

  def test_normalize_returns_nil_for_a_hash_with_no_known_styles
    assert_nil DocPDF::FontFiles.normalize(condensed: "/fonts/x.ttf")
  end

  def test_normalize_wraps_a_path_as_the_normal_style
    assert_equal({ normal: "/fonts/x.ttf" }, DocPDF::FontFiles.normalize("/fonts/x.ttf"))
  end

  def test_normalize_accepts_a_pathname
    assert_equal({ normal: "/fonts/x.ttf" }, DocPDF::FontFiles.normalize(Pathname.new("/fonts/x.ttf")))
  end

  def test_normalize_keeps_known_styles_and_drops_the_rest
    styles = DocPDF::FontFiles.normalize(normal: "/n.ttf", bold: "/b.ttf", nonsense: "/x.ttf")
    assert_equal({ normal: "/n.ttf", bold: "/b.ttf" }, styles)
  end

  def test_normalize_accepts_string_keys
    assert_equal({ normal: "/n.ttf" }, DocPDF::FontFiles.normalize("normal" => "/n.ttf"))
  end

  def test_for_hexapdf_renames_normal_to_none
    assert_equal({ none: "/n.ttf", bold: "/b.ttf" }, DocPDF::FontFiles.for_hexapdf(normal: "/n.ttf", bold: "/b.ttf"))
  end

  def test_for_hexapdf_returns_nil_for_nil
    assert_nil DocPDF::FontFiles.for_hexapdf(nil)
  end

  def test_for_prawn_keeps_prawn_style_names
    assert_equal({ normal: "/n.ttf" }, DocPDF::FontFiles.for_prawn("/n.ttf"))
  end
end
