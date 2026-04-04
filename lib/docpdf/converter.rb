module DocPDF
  class Converter
    class << self
      def call(source = nil, **options)
        new(source, **options).call
      end
    end

    def initialize(source = nil, **options)
      @input = InputNormalizer.new(source, **options.slice(:io, :data, :filename, :mime_type))
    end

    def call
      data = ConverterResolver.resolve(@input.mime_type).convert(@input.data, @input.source_filename || @input.filename)
      filename = build_filename(@input.filename)
      Result.new(data: data, filename: filename)
    end

    private

    def build_filename(original)
      return "converted.pdf" unless original

      base = File.basename(original, File.extname(original))
      "#{base}.pdf"
    end
  end
end
