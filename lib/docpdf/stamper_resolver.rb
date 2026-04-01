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
          entry = @adapters.find { |e| e[:name] == configured }
          raise AdapterNotFoundError, "Unknown stamper: #{configured}" unless entry
          begin
            entry[:loader].call
          rescue LoadError => e
            raise AdapterNotFoundError, "Stamper '#{configured}' requires gems that are not available: #{e.message}"
          end
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
        raise AdapterNotFoundError, "No stamper available. Add 'hexapdf' or 'combine_pdf' (with 'prawn') to your Gemfile."
      end
    end

    register :hexapdf,
      loader: -> { require "hexapdf"; require "docpdf/adapters/stampers/hexapdf"; Adapters::Stampers::Hexapdf }

    register :combine_pdf,
      loader: -> { require "combine_pdf"; require "prawn"; require "docpdf/adapters/stampers/combine_pdf"; Adapters::Stampers::CombinePdf }
  end
end
