require "./gen/emitter"
require "./gen/crystal"

module Pdlgen
  module Gen
    # Generator is the common interface for code generators.
    alias Generator = Proc(Array(Pdl::Domain), String, Emitter)

    # Generators returns all the various Chrome DevTools Protocol generators.
    def self.generators : Hash(String, Generator)
      {
        "crystal" => ->(domains : Array(Pdl::Domain), base_pkg : String) { CrystalGenerator.create(domains, base_pkg).as(Pdlgen::Gen::Emitter) },
      }
    end
  end
end
