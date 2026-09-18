require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  add_filter "/test/"

  # Each appraisal tests a different adapter configuration, so no single
  # run covers 100%. All paths are covered across the full appraisal matrix.
end

require "minitest/autorun"
require "docpdf"
require "pdf-reader"

FIXTURES_PATH = File.expand_path("fixtures", __dir__)

def fixture_data(filename)
  File.binread(fixture_path(filename))
end

def fixture_path(filename)
  File.join(FIXTURES_PATH, filename)
end

def multi_page_pdf
  fixture_data("test_multipage.pdf")
end

def cyrillic_text
  "Иванов"
end

def ttf_font_path
  fixture_path("DejaVuSans.ttf")
end

def no_pages_pdf
  fixture_data("test_no_pages.pdf")
end

def pdf_page_count(data)
  reader = PDF::Reader.new(StringIO.new(data))
  reader.page_count
end

def pdf_text(data)
  reader = PDF::Reader.new(StringIO.new(data))
  reader.pages.map(&:text).join("\n")
end

def sample_pdf
  fixture_data("test.pdf")
end

def valid_pdf?(data)
  data&.start_with?("%PDF")
end

# Adapter availability detection
def self.gem_available?(name)
  require name
  true
rescue LoadError
  false
end

PRAWN_AVAILABLE = gem_available?("prawn")
HEXAPDF_AVAILABLE = gem_available?("hexapdf")
COMBINE_PDF_AVAILABLE = gem_available?("combine_pdf")
RMAGICK_AVAILABLE = gem_available?("rmagick")
MINI_MAGICK_AVAILABLE = gem_available?("mini_magick")

TEXT_CONVERTER_AVAILABLE = PRAWN_AVAILABLE || HEXAPDF_AVAILABLE
STAMPER_AVAILABLE = (HEXAPDF_AVAILABLE) || (COMBINE_PDF_AVAILABLE && PRAWN_AVAILABLE)
IMAGE_CONVERTER_AVAILABLE = RMAGICK_AVAILABLE || MINI_MAGICK_AVAILABLE

# Simulates an Active Storage attachment
class FakeActiveStorageAttachment
  def initialize(content, filename, content_type)
    @content = content
    @blob = FakeBlob.new(filename, content_type)
  end

  def blob
    @blob
  end

  def download
    @content
  end

  FakeBlob = Struct.new(:filename, :content_type)
end

# Simulates a Dragonfly attachment or similar data-wrapper object
class FakeAttachment
  attr_reader :name, :mime_type

  def initialize(content, name, mime_type)
    @content = content
    @name = name
    @mime_type = mime_type
  end

  def data
    @content
  end
end

# Simulates an ActionDispatch::Http::UploadedFile or similar IO-like object
class FakeUpload
  attr_reader :original_filename

  def initialize(content, original_filename)
    @content = content
    @original_filename = original_filename
  end

  def read
    @content
  end
end

# Reset configuration between tests
module DocPDFTestSetup
  def setup
    super
    DocPDF.reset_configuration!
  end
end

Minitest::Test.prepend(DocPDFTestSetup)
