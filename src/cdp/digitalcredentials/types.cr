require "../cdp"
require "json"
require "base64"
require "time"

require "../page/page"

module Cdp::DigitalCredentials
  alias VirtualWalletAction = String
  VirtualWalletActionRespond = "respond"
  VirtualWalletActionDecline = "decline"
  VirtualWalletActionWait    = "wait"
  VirtualWalletActionClear   = "clear"
end
