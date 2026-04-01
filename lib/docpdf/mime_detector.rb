module DocPDF
  class MimeDetector
    EXTENSION_MAP = {
      ".pdf"  => "application/pdf",
      ".doc"  => "application/msword",
      ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      ".xls"  => "application/vnd.ms-excel",
      ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      ".ppt"  => "application/vnd.ms-powerpoint",
      ".pptx" => "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      ".odt"  => "application/vnd.oasis.opendocument.text",
      ".ods"  => "application/vnd.oasis.opendocument.spreadsheet",
      ".odp"  => "application/vnd.oasis.opendocument.presentation",
      ".csv"  => "text/csv",
      ".html" => "text/html",
      ".htm"  => "text/html",
      ".txt"  => "text/plain",
      ".rtf"  => "text/rtf",
      ".jpg"  => "image/jpeg",
      ".jpeg" => "image/jpeg",
      ".png"  => "image/png",
      ".heic" => "image/heic",
      ".heif" => "image/heif",
      ".webp" => "image/webp",
    }.freeze

    class << self
      def detect(filename)
        return nil if filename.nil?

        ext = File.extname(filename).downcase
        EXTENSION_MAP[ext]
      end
    end
  end
end
