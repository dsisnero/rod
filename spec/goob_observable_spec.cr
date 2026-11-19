require "./spec_helper"

# `Goob` ports github.com/go-rod/goober, which rod pulls in as a module
# dependency rather than a vendored package, so there is no `vendor/rod` file to
# pin against. Its `pipe.Write` is:
#
#	select {
#	case p.wait <- struct{}{}:
#	case <-p.done:
#	}
#
# Receiving from a *closed* channel is an immediately-ready branch in Go and
# just returns. Crystal raises `Channel::ClosedError` instead, so the port has to
# use `receive?` wherever the channel can be closed — the same fix Phase 23
# applied to `Utils::IdleCounter#wait`.
describe Goob::Observable do
  it "keeps publishing when a subscriber's done channel closes mid-publish" do
    done = Channel(Nil).new
    hub = Goob::Observable(String).new(done)
    hub.subscribe(done)

    # Fill the pipe's one-slot signal buffer, so the next write's select has
    # the done branch as the only ready one.
    hub.publish("filler")
    done.close

    # go-rod's pipe discards the event here instead of panicking; a raise would
    # escape into `Browser#init_events`, whose rescue stops event delivery.
    hub.publish("after-close")
  end
end
