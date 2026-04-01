module DocPDF
  module Adapters
    module Stampers
      class Base
        class << self
          def stamp(data, stamps, page_indices: nil)
            raise NotImplementedError, "#{name} must implement .stamp(data, stamps, page_indices:)"
          end

          private

          def rotated_bounds(w, h, degrees)
            radians = degrees * Math::PI / 180.0
            cos = Math.cos(radians).abs
            sin = Math.sin(radians).abs
            [(w * cos + h * sin).ceil, (w * sin + h * cos).ceil]
          end
        end
      end
    end
  end
end
