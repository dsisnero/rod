require "http/server"
require "socket"
require "html"
require "./browser"
require "./page"
require "./element"
require "./mouse"
require "./lib/assets"
require "../cdp/target/target"

module Rod
  alias TraceType = String

  TraceTypeWaitRequestsIdle = "wait requests idle"
  TraceTypeWaitRequests     = "wait requests"
  TraceTypeQuery            = "query"
  TraceTypeWait             = "wait"
  TraceTypeInput            = "input"

  private def self.trace_type_label(t : TraceType) : String
    "[#{t}]"
  end

  class Browser < ::Cdp::Client
    def logger : ::Log
      @logger
    end

    def trace(enable : Bool) : Browser
      @trace = enable
      self
    end

    def trace? : Bool
      @trace
    end

    def monitor(url : String) : Browser
      @monitor = url
      self
    end

    def logger(l : ::Log) : Browser
      @logger = l
      self
    end

    def slow_motion(delay : Time::Span) : Browser
      @slow_motion = delay
      self
    end

    def try_slow_motion : Nil
      return if @slow_motion.zero?
      sleep(@slow_motion)
    end

    # Starts a simple monitor server for current browser targets.
    def serve_monitor(host : String) : String
      host = "127.0.0.1:0" if host.empty?

      server = HTTP::Server.new do |context|
        begin
          path = context.request.path
          if path == "/"
            Rod.write_html(context.response, ::Rod::Lib::Assets::Monitor)
          elsif path == "/api/pages"
            res = ::Cdp::Target::GetTargets.new.call(self)
            list = res.target_infos.select { |info| info.type == "page" }
            Rod.write_json(context.response, list)
          elsif path.starts_with?("/page/")
            Rod.write_html(context.response, ::Rod::Lib::Assets::MonitorPage)
          elsif path.starts_with?("/api/page/")
            id = path.split('/').last
            res = ::Cdp::Target::GetTargets.new.call(self)
            if info = res.target_infos.find { |target_info| target_info.target_id.to_s == id }
              Rod.write_json(context.response, info)
            else
              context.response.status_code = 400
              Rod.write_json(context.response, {"code" => -32602, "message" => "target not found"})
            end
          elsif path.starts_with?("/screenshot/")
            context.response.status_code = 501
            Rod.write_json(context.response, {"code" => -32601, "message" => "screenshot monitor endpoint not implemented"})
          else
            context.response.status_code = 404
            Rod.write_json(context.response, {"code" => 404, "message" => "not found"})
          end
        rescue ex
          context.response.status_code = 400
          Rod.write_json(context.response, {"code" => -32602, "message" => ex.message || "bad request"})
        end
      end

      listener = TCPServer.new(host)
      spawn do
        begin
          server.listen(listener)
        rescue IO::Error
        end
      end

      spawn do
        @ctx.done.receive
        server.close
        listener.close
      end

      "http://#{listener.local_address}"
    end
  end

  class Page
    def expose_helpers(*list : JS::Function) : Nil
      rand_name = "_" + ::Rod::Lib::Utils.rand_string(8)
      fn = JS::Function.new(
        name: rand_name,
        definition: "() => { window.rod = functions }",
        dependencies: list.to_a
      )
      evaluate(eval_helper(fn))
    end

    def overlay(left : Float64, top : Float64, width : Float64, height : Float64, msg : String) : Proc(Nil)
      id = ::Rod::Lib::Utils.rand_string(8)
      root_page.evaluate(root_page.eval_helper(JS::OVERLAY, id, left, top, width, height, msg).by_promise)
      -> { root_page.evaluate(root_page.eval_helper(JS::REMOVE_OVERLAY, id)) }
    end

    def try_trace(typ : TraceType, *msg) : Proc(Nil)
      return -> { } unless @browser.trace?

      rendered = [Rod.trace_type_label(typ)] + msg.map(&.to_s) + [self.to_s]
      @browser.logger.info { rendered.join(" ") }
      overlay(0.0, 0.0, 500.0, 0.0, rendered.join(" "))
    end

    def try_trace_query(opts : EvalOptions) : Proc(Nil)
      return -> { } unless @browser.trace?

      @browser.logger.info { "#{Rod.trace_type_label(TraceTypeQuery)} #{opts} #{self}" }
      overlay(0.0, 0.0, 500.0, 0.0, "<code>#{HTML.escape(opts.to_s)}</code>")
    end

    def try_trace_req(includes : Array(String), excludes : Array(String)) : Proc(Hash(String, String), Nil)
      return ->(_list : Hash(String, String)) { } unless @browser.trace?

      meta = {"includes" => includes, "excludes" => excludes}
      @browser.logger.info { "#{Rod.trace_type_label(TraceTypeWaitRequestsIdle)} #{meta.to_json} #{self}" }
      cleanup = overlay(0.0, 0.0, 500.0, 0.0, meta.to_json)

      ->(list : Hash(String, String)) do
        @browser.logger.info { "#{Rod.trace_type_label(TraceTypeWaitRequests)} #{self} #{list.to_json}" }
        cleanup.call if list.empty?
      end
    end

    private def root_page : Page
      if el = @element
        el.page
      else
        self
      end
    end
  end

  class Element
    def overlay(msg : String) : Proc(Nil)
      id = ::Rod::Lib::Utils.rand_string(8)
      evaluate(@page.eval_helper(JS::ELEMENT_OVERLAY, id, msg).by_promise)
      -> { evaluate(@page.eval_helper(JS::REMOVE_OVERLAY, id)) }
    end

    def try_trace(typ : TraceType, *msg) : Proc(Nil)
      return -> { } unless @page.browser.trace?

      rendered = [Rod.trace_type_label(typ)] + msg.map(&.to_s) + [self.to_s]
      @page.browser.logger.info { rendered.join(" ") }
      overlay(rendered.join(" "))
    end
  end

  class Mouse
    def init_mouse_tracer : Nil
      @page.evaluate(@page.eval_helper(JS::INIT_MOUSE_TRACER, @id, ::Rod::Lib::Assets::MousePointer).by_promise)
    rescue
    end

    def update_mouse_tracer : Bool
      res = @page.evaluate(@page.eval_helper(JS::UPDATE_MOUSE_TRACER, @id, @pos.x, @pos.y))
      res.value.as_bool? || false
    rescue
      true
    end
  end

  private def self.write_html(response : HTTP::Server::Response, html : String) : Nil
    response.status_code = 200
    response.content_type = "text/html; charset=utf-8"
    response.print(html)
  end

  private def self.write_json(response : HTTP::Server::Response, obj) : Nil
    response.status_code = 200 if response.status_code == 0
    response.content_type = "application/json"
    response.print(obj.to_json)
  end
end
