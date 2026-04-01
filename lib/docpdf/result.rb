module DocPDF
  class Result
    attr_reader :data, :filename

    def initialize(data:, filename: nil)
      @data = data
      @filename = filename
    end

    def watermark(*stamps, **options)
      DocPDF.watermark(self, *stamps, **options)
    end
  end
end
