module DocPDF
  # Prawn's built-in AFM fonts only cover Windows-1252, so any text outside it
  # fails to render. Pointing an adapter at a TrueType file lifts that limit.
  # Each backend wants the styles keyed differently, so normalize once here.
  module FontFiles
    STYLES = %i[normal bold italic bold_italic].freeze

    # HexaPDF calls the unstyled variant :none where Prawn calls it :normal.
    HEXAPDF_STYLES = { normal: :none, bold: :bold, italic: :italic, bold_italic: :bold_italic }.freeze

    class << self
      # Accepts a path for the regular weight, or a hash of styles:
      #   "DejaVuSans.ttf"
      #   { normal: "...", bold: "...", italic: "...", bold_italic: "..." }
      def normalize(font_file)
        return if font_file.nil?
        return { normal: font_file.to_s } if font_file.is_a?(String) || font_file.is_a?(Pathname)

        styles = font_file.to_h.transform_keys(&:to_sym).slice(*STYLES)
        styles.empty? ? nil : styles.transform_values(&:to_s)
      end

      def for_hexapdf(font_file)
        styles = normalize(font_file)
        return unless styles

        styles.each_with_object({}) { |(style, path), map| map[HEXAPDF_STYLES.fetch(style)] = path }
      end

      def for_prawn(font_file)
        normalize(font_file)
      end
    end
  end
end
