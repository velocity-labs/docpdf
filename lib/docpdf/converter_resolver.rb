module DocPDF
  class ConverterResolver
    @adapters = []

    class << self
      def register(name, require_name: nil, mime_types:, loader:)
        @adapters << { name: name.to_sym, require_name: require_name, mime_types: mime_types, loader: loader }
      end

      def resolve(mime_type)
        missing_gems = []

        @adapters.each do |entry|
          next unless entry[:mime_types].include?(mime_type)
          require entry[:require_name] if entry[:require_name]
          return entry[:loader].call
        rescue LoadError
          missing_gems << entry[:require_name]
          next
        end

        if missing_gems.any?
          gem_list = missing_gems.map { |g| "'#{g}'" }.join(" or ")
          raise AdapterNotFoundError, "No converter found for #{mime_type}. Install #{gem_list} and add it to your Gemfile."
        end

        resolve_fallback
      end

      private

      def resolve_fallback
        entry = @adapters.find { |e| e[:name] == :fallback }
        raise AdapterNotFoundError, "No converter found and no fallback registered." unless entry
        entry[:loader].call
      end
    end

    # Registration order determines priority for shared mime types
    register :passthrough,
      mime_types: %w[application/pdf],
      loader: -> { require "docpdf/adapters/converters/passthrough"; Adapters::Converters::Passthrough }

    register :soffice,
      mime_types: %w[
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
        application/vnd.ms-excel
        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        application/vnd.ms-powerpoint
        application/vnd.openxmlformats-officedocument.presentationml.presentation
        application/vnd.oasis.opendocument.text
        application/vnd.oasis.opendocument.spreadsheet
        application/vnd.oasis.opendocument.presentation
        text/csv
        text/html
        text/rtf
        application/rtf
      ],
      loader: -> { require "docpdf/adapters/converters/soffice"; Adapters::Converters::Soffice }

    register :prawn,
      require_name: "prawn",
      mime_types: %w[text/plain],
      loader: -> { require "docpdf/adapters/converters/prawn"; Adapters::Converters::Prawn }

    register :hexapdf,
      require_name: "hexapdf",
      mime_types: %w[text/plain],
      loader: -> { require "docpdf/adapters/converters/hexapdf"; Adapters::Converters::Hexapdf }

    register :rmagick,
      require_name: "rmagick",
      mime_types: %w[image/jpeg image/png image/heic image/heif image/webp],
      loader: -> { require "docpdf/adapters/converters/rmagick"; Adapters::Converters::Rmagick }

    register :mini_magick,
      require_name: "mini_magick",
      mime_types: %w[image/jpeg image/png image/heic image/heif image/webp],
      loader: -> { require "docpdf/adapters/converters/mini_magick"; Adapters::Converters::MiniMagick }

    register :fallback,
      mime_types: [],
      loader: -> { require "docpdf/adapters/converters/fallback"; Adapters::Converters::Fallback }
  end
end
