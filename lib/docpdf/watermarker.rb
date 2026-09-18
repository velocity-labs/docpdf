module DocPDF
  class Watermarker
    POSITIONS = %i[center top bottom left right top_left top_right bottom_left bottom_right].freeze

    STAMP_DEFAULTS = {
      opacity: 0.1,
      position: :center,
      width: 250,
      offset_x: 0,
      offset_y: 0,
      pages: :all,
    }.freeze

    class << self
      def calculate_position(position, page_w, page_h, img_w, img_h, offset_x, offset_y)
        x, y = case position
                when :center       then [(page_w - img_w) / 2, (page_h - img_h) / 2]
                when :top          then [(page_w - img_w) / 2, page_h - img_h]
                when :bottom       then [(page_w - img_w) / 2, 0]
                when :left         then [0, (page_h - img_h) / 2]
                when :right        then [page_w - img_w, (page_h - img_h) / 2]
                when :top_left     then [0, page_h - img_h]
                when :top_right    then [page_w - img_w, page_h - img_h]
                when :bottom_left  then [0, 0]
                when :bottom_right then [page_w - img_w, 0]
                else                    [(page_w - img_w) / 2, (page_h - img_h) / 2]
                end
        [x + offset_x, y + offset_y]
      end

      def call(source = nil, *stamps, filename: nil, **input_options)
        pdf_bytes, resolved_filename = resolve_input(source, filename, input_options)

        if stamps.empty?
          return Result.new(data: pdf_bytes, filename: resolved_filename)
        end

        normalized = stamps.map { |s| normalize_stamp(s) }
        stamped = new(pdf_bytes, normalized).call
        Result.new(data: stamped, filename: resolved_filename)
      end

      private

      def normalize_stamp(stamp)
        merged = STAMP_DEFAULTS.merge(stamp)
        if merged[:text]
          wm = DocPDF.configuration.watermark_options
          { font: wm[:font], font_file: wm[:font_file], font_size: wm[:font_size], color: wm[:color], rotation: wm[:rotation] }.merge(merged)
        else
          merged
        end
      end

      def resolve_input(source, filename, input_options)
        case source
        when Result
          [source.data, filename || source.filename]
        when Pathname
          [File.binread(source.to_s), filename || File.basename(source.to_s)]
        when String
          if !source.match?(/[\x00-\x08]/) && File.exist?(source)
            [File.binread(source), filename || File.basename(source)]
          else
            [source, filename]
          end
        when nil
          if input_options[:io]
            io = input_options[:io]
            resolved_filename = filename || (io.respond_to?(:original_filename) && io.original_filename) || nil
            [io.read, resolved_filename]
          elsif input_options[:data]
            [input_options[:data], filename]
          else
            raise ArgumentError, "Provide a file path, IO object, Result, or data:"
          end
        else
          if source.respond_to?(:read)
            resolved_filename = filename || (source.respond_to?(:original_filename) && source.original_filename) || nil
            [source.read, resolved_filename]
          else
            raise ArgumentError, "Cannot read PDF from #{source.class}. Provide a file path, IO object, Result, or data:"
          end
        end
      end
    end

    def initialize(pdf_bytes, stamps)
      @pdf_bytes = pdf_bytes
      @stamps = stamps
    end

    def call
      stamper = StamperResolver.resolve

      if all_stamps_target_all_pages?
        stamper.stamp(@pdf_bytes, @stamps)
      else
        stamp_per_page(stamper)
      end
    end

    private

    def all_stamps_target_all_pages?
      @stamps.all? { |s| s[:pages] == :all }
    end

    def build_page_stamp_map(page_count)
      per_page = Array.new(page_count) { [] }

      @stamps.each do |stamp|
        target_pages(stamp[:pages], page_count).each do |idx|
          per_page[idx] << stamp
        end
      end

      groups = {}
      per_page.each_with_index do |stamps, idx|
        next if stamps.empty?
        groups[stamps] ||= []
        groups[stamps] << idx
      end

      groups.map { |stamps, indices| [indices, stamps] }
    end

    def pdf_page_count
      if defined?(CombinePDF)
        CombinePDF.parse(@pdf_bytes).pages.length
      elsif defined?(HexaPDF)
        doc = HexaPDF::Document.new(io: StringIO.new(@pdf_bytes))
        doc.pages.count
      else
        @pdf_bytes.scan(/\/Type\s*\/Page[^s]/).length
      end
    end

    def stamp_per_page(stamper)
      page_count = pdf_page_count
      raise ConversionError, "Cannot stamp a PDF with no pages" if page_count.zero?

      result = @pdf_bytes

      build_page_stamp_map(page_count).each do |page_indices, stamps_for_pages|
        result = stamper.stamp(result, stamps_for_pages, page_indices: page_indices)
      end

      result
    end

    def target_pages(pages_option, page_count)
      case pages_option
      when :all    then (0...page_count).to_a
      when :first  then [0]
      when :last   then [page_count - 1]
      when :odd    then (0...page_count).select { |i| i.even? }
      when :even   then (0...page_count).select { |i| i.odd? }
      when Integer then [pages_option - 1]
      when Array   then pages_option.map { |p| p - 1 }
      when Range   then pages_option.map { |p| p - 1 }
      else              (0...page_count).to_a
      end
    end
  end
end
