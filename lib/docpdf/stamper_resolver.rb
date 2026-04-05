module DocPDF
  class StamperResolver
    @adapters = []

    class << self
      def register(name, loader:)
        @adapters << { name: name.to_sym, loader: loader }
      end

      def resolve
        configured = DocPDF.configuration.stamper
        if configured
          resolve_configured(configured)
        else
          auto_detect
        end
      end

      private

      def auto_detect
        @adapters.each do |entry|
          return entry[:loader].call
        rescue LoadError
          next
        end
        names = @adapters.map { |e| "'#{e[:name]}'" }.join(" or ")
        raise AdapterNotFoundError, "No stamper available. Add #{names} to your Gemfile."
      end

      def resolve_configured(name)
        entry = @adapters.find { |e| e[:name] == name }
        valid_names = @adapters.map { |e| e[:name].inspect }.join(", ")
        raise AdapterNotFoundError, "Unknown stamper: #{name.inspect}. Valid stampers are: #{valid_names}." unless entry
        begin
          entry[:loader].call
        rescue LoadError => e
          raise AdapterNotFoundError, "Stamper #{name.inspect} requires gems that are not installed: #{e.message}"
        end
      end
    end

    register :hexapdf,
      loader: -> { require "hexapdf"; require "docpdf/adapters/stampers/hexapdf"; Adapters::Stampers::Hexapdf }

    register :combine_pdf,
      loader: -> { require "combine_pdf"; require "prawn"; require "docpdf/adapters/stampers/combine_pdf"; Adapters::Stampers::CombinePdf }
  end
end
