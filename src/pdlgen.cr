#!/usr/bin/env crystal
# Crystal port of cdproto-gen, generates Crystal types for Chrome DevTools Protocol

require "./pdlgen/**"

module Pdlgen
  VERSION = "0.7.0"
end

Pdlgen::CLI.run
