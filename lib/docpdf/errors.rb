module DocPDF
  class Error < StandardError; end
  class ConversionError < Error; end
  class SofficeNotFoundError < Error; end
  class AdapterNotFoundError < Error; end
end
