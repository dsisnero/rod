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
require "./rod/error"
require "./rod/page"
require "./rod/element"
require "./rod/keyboard"
require "./rod/mouse"
require "./rod/touch"
require "./rod/dev_helpers"
require "./rod/must"

# JavaScript helpers
require "./rod/util/js"

# Input system (stubbed for now)
require "./rod/util/input/input"

# Utilities
require "./rod/util/utils"
require "./rod/util/defaults"
require "./rod/util/check_issue"
require "./rod/util/devices"
require "./rod/util/launcher"
require "./rod/util/proto"
require "./rod/util/cdp"
require "./rod/util/utils_shell"
require "./rod/util/examples/custom_websocket"
require "./rod/util/examples/compare_chromedp_proxy"

# Top-level aliases for convenience
alias Utils = Rod::Util::Utils
alias Defaults = Rod::Util::Defaults

module Rod
  VERSION = "0.6.1"

  # Internal aliases
  alias Utils = Util::Utils
  alias Defaults = Util::Defaults
  alias CDPClient = ::Cdp::Client
end
