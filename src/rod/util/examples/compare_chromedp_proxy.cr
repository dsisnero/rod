module Rod::Util::Examples::CompareChromedpProxy
  # Transport reproduces the example proxy behavior that short-circuits
  # requests carrying X-Failed and delegates all other requests.
  class Transport
    def initialize(&@round_tripper : HTTP::Request -> HTTP::Client::Response)
    end

    def round_trip(request : HTTP::Request) : HTTP::Client::Response
      if failed = request.headers["X-Failed"]?
        raise failed
      end

      @round_tripper.call(request)
    end
  end
end
