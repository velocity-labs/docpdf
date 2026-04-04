require "tempfile"
require_relative "base"

module DocPDF
  module Adapters
    module Converters
      class Soffice < Base
        MIME_TYPES = %w[
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
        ].freeze

        class << self
          def convert(data, source_filename)
            Dir.mktmpdir do |output_dir|
              Tempfile.create(["docpdf", File.extname(source_filename || ".tmp")]) do |tempfile|
                tempfile.binmode
                tempfile.write(data)
                tempfile.rewind

                soffice = DocPDF.configuration.soffice_path
                profile_dir = File.join(output_dir, "profile")
                stderr_path = File.join(output_dir, "stderr.log")
                success = system(soffice, "--headless",
                                 "-env:UserInstallation=file://#{profile_dir}",
                                 "--convert-to", "pdf",
                                 "--outdir", output_dir, tempfile.path,
                                 out: File::NULL, err: stderr_path)

                pdf_path = Dir.glob(File.join(output_dir, "*.pdf")).first

                if pdf_path
                  File.binread(pdf_path)
                else
                  stderr_output = File.read(stderr_path).strip
                  detail = stderr_output.empty? ? "" : " (#{stderr_output})"

                  if success.nil?
                    raise SofficeNotFoundError, "LibreOffice (soffice) not found on PATH. Install LibreOffice or set DocPDF.configuration.soffice_path."
                  elsif success
                    raise ConversionError, "LibreOffice completed but produced no PDF for #{source_filename || 'document'}#{detail}"
                  else
                    raise ConversionError, "LibreOffice failed to convert #{source_filename || 'document'} to PDF#{detail}"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
