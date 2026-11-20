module DocPDF
  class Configuration
    attr_accessor :soffice_path,
                  :soffice_timeout,
                  :image_options,
                  :converter,
                  :stamper,
                  :page_size,
                  :text_options,
                  :watermark_options

    TEXT_DEFAULTS = {
      font: "Courier",
      font_file: nil,
      font_size: 10,
      margins: [50, 50, 50, 50],
      color: "333333",
    }.freeze

    # Photos are turned upright from their EXIF orientation, stripped of metadata
    # (camera, GPS location), flattened onto white, and shrunk to at most
    # max_edge pixels. The page's long edge is page_long_edge inches, so a phone
    # photo becomes a page about the size of a printed sheet rather than one
    # point per pixel (a 12 MP photo would otherwise be a 56-inch page).
    # Set page_long_edge to nil for the old one-point-per-pixel sizing.
    IMAGE_DEFAULTS = {
      auto_orient: true,
      strip: true,
      background: "white",
      max_edge: 2400,
      page_long_edge: 11,
      quality: 85,
    }.freeze

    WATERMARK_DEFAULTS = {
      font: "Helvetica",
      font_file: nil,
      font_size: 72,
      color: "AAAAAA",
      rotation: 45,
    }.freeze

    def initialize
      @soffice_path      = "soffice"
      @soffice_timeout   = 120 # seconds; nil waits forever
      @image_options     = IMAGE_DEFAULTS.dup
      @converter          = nil
      @stamper            = nil
      @page_size          = "LETTER"
      @text_options       = TEXT_DEFAULTS.dup
      @watermark_options  = WATERMARK_DEFAULTS.dup
    end
  end
end
