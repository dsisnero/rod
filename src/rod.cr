# Rod browser automation library

# Define dummy HTTP::Client::Context for CDP compatibility
require "http"

module HTTP
  class Client
    # Dummy context type for CDP compatibility
    class Context
    end
  end
end

# Core types and browser
require "./rod/browser"
require "./rod/types"
require "./rod/page"
require "./rod/element"
require "./rod/keyboard"
require "./rod/mouse"
require "./rod/touch"

# JavaScript helpers
require "./rod/lib/js"

# Input system (stubbed for now)
require "./rod/lib/input/input"

# Utilities
require "./rod/lib/utils"
require "./rod/lib/defaults"
require "./rod/lib/devices"
require "./rod/lib/launcher"
require "./rod/lib/proto"
require "./rod/lib/cdp"

# Top-level aliases for convenience
alias Utils = Rod::Lib::Utils
alias Defaults = Rod::Lib::Defaults

module Rod
  VERSION = "0.1.0"

  # Internal aliases
  alias Utils = Lib::Utils
  alias Defaults = Lib::Defaults
end
