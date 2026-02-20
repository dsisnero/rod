module Pdlgen
  module Gen
    # Emitter is the shared interface for code emitters.
    abstract class Emitter
      abstract def emit : Hash(String, String)
    end
  end
end
