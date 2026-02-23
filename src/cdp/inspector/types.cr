require "../cdp"
require "json"
require "time"

require "../dom/dom"

module Cdp::Inspector
  alias DetachReason = String
  DetachReasonTargetClosed         = "target_closed"
  DetachReasonCanceledByUser       = "canceled_by_user"
  DetachReasonReplacedWithDevtools = "replaced_with_devtools"
  DetachReasonRenderProcessGone    = "Render process gone."
end
