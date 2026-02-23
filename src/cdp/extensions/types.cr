require "../cdp"
require "json"
require "time"

module Cdp::Extensions
  alias StorageArea = String
  StorageAreaSession = "session"
  StorageAreaLocal   = "local"
  StorageAreaSync    = "sync"
  StorageAreaManaged = "managed"
end
