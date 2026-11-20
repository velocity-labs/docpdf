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
                success = run(soffice, "--headless",
                              "-env:UserInstallation=file://#{profile_dir}",
                              "--convert-to", "pdf",
                              "--outdir", output_dir, tempfile.path,
                              stderr_path: stderr_path, source_filename: source_filename)

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

          private

          # Like Kernel#system (nil when soffice can't be started), but kills
          # LibreOffice and everything it started after config.soffice_timeout
          # seconds, so a document that makes it hang can't hold the caller forever.
          def run(*command, stderr_path:, source_filename:)
            pid = Process.spawn(*command, out: File::NULL, err: stderr_path, pgroup: true)
            timeout = DocPDF.configuration.soffice_timeout
            deadline = timeout && Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
            loop do
              _, status = Process.wait2(pid, Process::WNOHANG)
              return status.success? if status

              if deadline && Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
                kill_group(pid)
                raise ConversionError, "LibreOffice timed out after #{timeout}s converting #{source_filename || 'document'}"
              end
              sleep 0.05
            end
          rescue Errno::ENOENT, Errno::EACCES
            nil
          end

          def kill_group(pid)
            Process.kill("KILL", -pid)
          rescue Errno::ESRCH
            nil
          ensure
            begin
              Process.wait(pid)
            rescue Errno::ECHILD
              nil
            end
          end
        end
      end
    end
  end
end
