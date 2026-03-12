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

  def self.trace_type_label(t : TraceType) : String
    "[#{t}]"
  end

  class Browser < ::Cdp::Client
    def logger : ::Log
      @logger
    end

    def trace_logger : Rod::Lib::Utils::Log?
      @trace_logger
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
      @trace_logger = nil
      @logger = l
      self
    end

    # Go parity: allow utils.Log adapters (e.g. logger_quiet/log callbacks).
    def logger(l : Rod::Lib::Utils::Log) : Browser
      @trace_logger = l
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
            res = ::Cdp::Target::GetTargets.new(nil).call(self)
            list = res.target_infos.select { |info| info.type == "page" }
            Rod.write_json(context.response, list)
          elsif path.starts_with?("/page/")
            Rod.write_html(context.response, ::Rod::Lib::Assets::MonitorPage)
          elsif path.starts_with?("/api/page/")
            id = path.split('/').last
            res = ::Cdp::Target::GetTargets.new(nil).call(self)
            if info = res.target_infos.find { |target_info| target_info.target_id.to_s == id }
              Rod.write_json(context.response, info)
            else
              context.response.status_code = 400
              Rod.write_json(context.response, {"code" => -32602, "message" => "target not found"})
            end
          elsif path == "/screenshot" || path.starts_with?("/screenshot/")
            id = path.split('/').last
            target_id =
              if id.empty?
                res = ::Cdp::Target::GetTargets.new(nil).call(self)
                info = res.target_infos.find { |target_info| target_info.type == "page" }
                raise "target not found" unless info
                info.target_id.to_s
              else
                id
              end

            page = page_from_target(TargetID.new(target_id))
            context.response.status_code = 200
            context.response.content_type = "image/png"
            context.response.write(page.screenshot)
          else
            context.response.status_code = 404
            Rod.write_json(context.response, {"code" => 404, "message" => "not found"})
          end
        rescue ex
          context.response.status_code = 400
          Rod.write_json(context.response, {"code" => -32602, "message" => ex.message || "bad request"})
        end
      end

      sep = host.rindex(':')
      raise ArgumentError.new("invalid host format: #{host}") unless sep
      bind_host = host[0, sep]
      bind_port = host[(sep + 1)..].to_i
      address = server.bind_tcp(bind_host, bind_port)
      spawn do
        begin
          server.listen
        rescue IO::Error
        end
      end

      spawn do
        begin
          @ctx.done.receive
        rescue Channel::ClosedError
        ensure
          server.close
        end
      end

      "http://#{address}"
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
      begin
        root_page.evaluate(root_page.eval_helper(JS::OVERLAY, id, left, top, width, height, msg).by_promise)
      rescue
      end
      # Best-effort tracing: avoid teardown eval to prevent instability on some runtimes.
      -> { }
    end

    def try_trace(typ : TraceType, *msg) : Proc(Nil)
      return -> { } unless @browser.trace?

      rendered = [Rod.trace_type_label(typ)] + msg.to_a.map(&.to_s) + [self.to_s]
      trace_logger = @browser.trace_logger
      if trace_logger
        logger = trace_logger.as(Rod::Lib::Utils::Log)
        logger.println(rendered)
      else
        @browser.logger.info { rendered.join(" ") }
      end
      overlay(0.0, 0.0, 500.0, 0.0, rendered.join(" "))
    end

    def try_trace_query(opts : EvalOptions) : Proc(Nil)
      return -> { } unless @browser.trace?

      rendered = [Rod.trace_type_label(TraceTypeQuery), opts.to_s, self.to_s]
      trace_logger = @browser.trace_logger
      if trace_logger
        logger = trace_logger.as(Rod::Lib::Utils::Log)
        logger.println(rendered)
      else
        @browser.logger.info { rendered.join(" ") }
      end
      overlay(0.0, 0.0, 500.0, 0.0, "<code>#{HTML.escape(opts.to_s)}</code>")
    end

    def try_trace_req(includes : Array(String), excludes : Array(String)) : Proc(Hash(String, String), Nil)
      return ->(_list : Hash(String, String)) { } unless @browser.trace?

      meta = {"includes" => includes, "excludes" => excludes}
      rendered = [Rod.trace_type_label(TraceTypeWaitRequestsIdle), meta.to_json, self.to_s]
      trace_logger = @browser.trace_logger
      if trace_logger
        logger = trace_logger.as(Rod::Lib::Utils::Log)
        logger.println(rendered)
      else
        @browser.logger.info { rendered.join(" ") }
      end
      ch = Channel(Hash(String, String)).new

      spawn do
        begin
          wait_list = {} of String => String
          loop do
            break if @ctx.done.closed?
            select
            when list = ch.receive?
              break unless list
              wait_list = list
            when timeout(1.second)
              lines = [Rod.trace_type_label(TraceTypeWaitRequests), self.to_s, wait_list.to_json]
              trace_logger = @browser.trace_logger
              if trace_logger
                logger = trace_logger.as(Rod::Lib::Utils::Log)
                logger.println(lines)
              else
                @browser.logger.info { lines.join(" ") }
              end
            end
          end
        ensure
          ch.close
        end
      end

      ->(list : Hash(String, String)) do
        # Clone to avoid mutation races between event callbacks and logger loop.
        clone = {} of String => String
        list.each { |k, v| clone[k] = v }
        begin
          ch.send(clone)
        rescue Channel::ClosedError
        end
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
      begin
        evaluate(@page.eval_helper(JS::ELEMENT_OVERLAY, id, msg).by_promise)
      rescue
      end
      # Best-effort tracing: avoid teardown eval to prevent instability on some runtimes.
      -> { }
    end

    def try_trace(typ : TraceType, *msg) : Proc(Nil)
      return -> { } unless @page.browser.trace?

      rendered = [Rod.trace_type_label(typ)] + msg.to_a.map(&.to_s) + [self.to_s]
      trace_logger = @page.browser.trace_logger
      if trace_logger
        logger = trace_logger.as(Rod::Lib::Utils::Log)
        logger.println(rendered)
      else
        @page.browser.logger.info { rendered.join(" ") }
      end
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
      value = res.value
      value ? (value.as_bool? || false) : false
    rescue
      true
    end
  end

  def self.write_html(response : HTTP::Server::Response, html : String) : Nil
    response.status_code = 200
    response.content_type = "text/html; charset=utf-8"
    response.print(html)
  end

  def self.write_json(response : HTTP::Server::Response, obj) : Nil
    response.status_code = 200 if response.status_code == 0
    response.content_type = "application/json"
    response.print(obj.to_json)
  end
end
