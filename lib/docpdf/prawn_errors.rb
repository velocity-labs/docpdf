require "prawn"

module DocPDF
  # Prawn defines every error class directly under StandardError with no shared
  # ancestor, so there is no namespace to rescue. Collecting them lets adapters
  # wrap the whole family in DocPDF::ConversionError rather than leaking Prawn's
  # exceptions to callers who only rescue DocPDF::Error.
  #
  # Only require this from files that already require "prawn"; prawn is optional.
  PRAWN_ERRORS = ::Prawn::Errors.constants
                                .map { |name| ::Prawn::Errors.const_get(name) }
                                .select { |const| const.is_a?(Class) && const <= StandardError }
                                .freeze
end
