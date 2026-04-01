module DocPDF
  class InputNormalizer
    attr_reader :data, :filename, :source_filename, :mime_type

    def initialize(source = nil, io: nil, data: nil, filename: nil, mime_type: nil)
      @data, source_filename, detected_mime = extract(source, io, data)

      # MIME detection uses the source's original filename, not the user's
      # display-name override, unless the source has no filename at all
      # (e.g., raw data: with a filename: hint).
      @source_filename = source_filename
      @filename = filename || source_filename
      @mime_type = mime_type || detected_mime || MimeDetector.detect(source_filename || filename)
    end

    private

    def extract(source, io, data)
      case source
      when Pathname                           then extract_from_pathname(source)
      when String                             then extract_from_string(source)
      when ->(s) { s.respond_to?(:read) }     then extract_from_io(source)
      when ->(s) { s.respond_to?(:download) } then extract_from_active_storage(source)
      when ->(s) { s.respond_to?(:data) }     then extract_from_data_wrapper(source)
      when nil                                then extract_from_kwargs(io, data)
      else
        raise ArgumentError, "Provide a file path, IO object, io:, or data:"
      end
    end

    def extract_filename(source, method)
      source.respond_to?(method) ? source.send(method) : nil
    end

    def extract_from_active_storage(source)
      blob = source.respond_to?(:blob) ? source.blob : nil
      [source.download, blob&.filename&.to_s, blob&.content_type]
    end

    def extract_from_data_wrapper(source)
      source_filename = (source.respond_to?(:name) && source.name) || nil
      detected_mime = source.respond_to?(:mime_type) ? source.mime_type : nil
      [source.data, source_filename, detected_mime]
    end

    def extract_from_io(source)
      [source.read, extract_filename(source, :original_filename), nil]
    end

    def extract_from_kwargs(io, data)
      if io
        [io.read, extract_filename(io, :original_filename), nil]
      elsif data
        [data, nil, nil]
      else
        raise ArgumentError, "Provide a file path, IO object, io:, or data:"
      end
    end

    def extract_from_pathname(source)
      [File.binread(source.to_s), File.basename(source.to_s), nil]
    end

    def extract_from_string(source)
      if file_path?(source)
        [File.binread(source), File.basename(source), nil]
      else
        [source, nil, nil]
      end
    end

    def file_path?(string)
      !string.match?(/[\x00-\x08]/) && File.exist?(string)
    end
  end
end
