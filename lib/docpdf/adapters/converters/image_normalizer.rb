module DocPDF
  module Adapters
    module Converters
      # ImageMagick arguments for config.image_options, shared by the image adapters.
      module ImageNormalizer
        module_function

        def arguments(options = DocPDF.configuration.image_options)
          args = []
          args << "-auto-orient" if options[:auto_orient]
          args << "-strip" if options[:strip]
          args += ["-background", options[:background], "-alpha", "remove", "-alpha", "off"] if options[:background]
          args += ["-resize", "#{options[:max_edge]}x#{options[:max_edge]}>"] if options[:max_edge]
          if options[:page_long_edge]
            args += ["-units", "PixelsPerInch", "-set", "density", "%[fx:max(w,h)/#{options[:page_long_edge]}]"]
          end
          args += ["-compress", "jpeg", "-quality", options[:quality].to_s] if options[:quality]
          args
        end
      end
    end
  end
end
