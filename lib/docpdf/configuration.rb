module DocPDF
  class Configuration
    attr_accessor :soffice_path,
                  :converter,
                  :stamper,
                  :page_size,
                  :text_options,
                  :watermark_options

    TEXT_DEFAULTS = {
      font: "Courier",
      font_size: 10,
      margins: [50, 50, 50, 50],
      color: "333333",
    }.freeze

    WATERMARK_DEFAULTS = {
      font: "Helvetica",
      font_size: 72,
      color: "AAAAAA",
      rotation: 45,
    }.freeze

    def initialize
      @soffice_path      = "soffice"
      @converter          = nil
      @stamper            = nil
      @page_size          = "LETTER"
      @text_options       = TEXT_DEFAULTS.dup
      @watermark_options  = WATERMARK_DEFAULTS.dup
    end
  end
end
