# Changelog

## [Unreleased]

### Fixed
- Watermarking a structurally valid PDF with an empty page tree raised `NoMethodError` instead of a `DocPDF::ConversionError`. Both stampers and the per-page watermark path now raise `ConversionError` with a clear message.

## [0.1.4] - 2026-04-08

### Fixed
- Fallback converter raised `NameError: uninitialized constant Soffice` when loaded without the full library (e.g. via lazy `ConverterResolver`)

## [0.1.3] - 2026-04-04

### Improved
- Error messages now include the mime type that failed and which gems to install
- Unknown stamper errors list valid options from the registry
- All gem names in error messages are pulled from the registry, not hardcoded

## [0.1.2] - 2026-04-04

### Fixed
- Concurrent LibreOffice conversions no longer conflict. Each conversion uses an isolated user profile directory via `-env:UserInstallation`, preventing lock file collisions under load.

## [0.1.1] - 2026-04-03

### Fixed
- Fallback converter not detecting image extensions when using `data:` input with a `filename:` hint

## [0.1.0] - 2026-04-03

Initial release.

### Added
- Multi-format document-to-PDF conversion via LibreOffice:
  - Word (.doc, .docx)
  - Excel (.xls, .xlsx)
  - PowerPoint (.ppt, .pptx)
  - OpenDocument (.odt, .ods, .odp)
  - CSV, HTML, RTF
- Plain text to PDF via Prawn or HexaPDF
- Image to PDF via RMagick or MiniMagick (JPEG, PNG, HEIC, WebP)
- PDF passthrough
- PDF watermarking with image and text stamps
  - Image stamps with configurable width, height (proportional if omitted), and opacity
  - Text stamps with configurable font, font_size, color, and rotation
  - Text auto-scales to fit page when font size would cause overflow
  - Rotated text uses correct bounding box for edge/corner positioning
  - Position grid: `:center`, `:top`, `:bottom`, `:left`, `:right`, `:top_left`, `:top_right`, `:bottom_left`, `:bottom_right`
  - Stamp page matches source PDF page size
  - Per-stamp offsets (`offset_x`, `offset_y`) for precise placement
  - Per-stamp page targeting: `:all`, `:first`, `:last`, `:odd`, `:even`, specific page numbers, arrays, and ranges
  - Multiple stamps per call (image and text can be mixed)
- Chainable API: `DocPDF.convert("file.docx").watermark({ text: "DRAFT", opacity: 0.1 })`
- Pluggable adapter architecture with zero hard dependencies
  - **Converter adapters**: Soffice, Prawn, HexaPDF, RMagick, MiniMagick, Passthrough, Fallback
  - **Stamper adapters**: HexaPDF, CombinePDF (with Prawn)
  - Auto-detected at runtime based on MIME type and gem availability
  - Extensible via `ConverterResolver.register` and `StamperResolver.register`
- Flexible input: file path, Pathname, IO object, raw binary data
- Works with Dragonfly, Active Storage, CarrierWave, Shrine, and Rails UploadedFile
- `DocPDF::Result` returned from both `convert` and `watermark` with `.data` and `.filename`
- Extension-based MIME type detection
- Grouped configuration: `text_options` for plain text conversion, `watermark_options` for text watermark defaults
- Consistent error wrapping across all adapters via `DocPDF::ConversionError`
- Soffice stderr captured in `ConversionError` messages for diagnostics
- Ruby 3.3, 3.4, and 4.0 support
- Tested with Appraisal across 6 adapter configurations
