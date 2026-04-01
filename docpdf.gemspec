require_relative "lib/docpdf/version"

Gem::Specification.new do |spec|
  spec.name          = "docpdf"
  spec.version       = DocPDF::VERSION
  spec.authors       = ["Velocity Labs, LLC"]
  spec.email         = ["admin@velocitylabs.io"]

  spec.summary       = "Convert documents (Word, Excel, PowerPoint, images) to PDF with optional watermarking"
  spec.description   = "Multi-format document-to-PDF converter with pluggable adapters and zero hard dependencies. Supports Word, Excel, PowerPoint, OpenDocument, CSV, HTML, RTF, plain text, images, and PDF passthrough. Optional watermarking with position grid, offsets, and per-page targeting."
  spec.homepage      = "https://github.com/velocity-labs/docpdf"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["{lib}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  end
  spec.require_paths = ["lib"]
end
