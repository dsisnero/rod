require "../../../src/rod"
require "http/server"

private HTML = <<-HTML
<html lang="en">
<head><meta charset="UTF-8"><title>Title</title></head>
<body>
<h1 id="title" class="link"><a href="https://test.com/helloworld">content of h1 1</a><span>hello</span> world</h1>
</body></html>
HTML

def print_nodes(io : IO, nodes : Array(Cdp::DOM::Node)?, padding : String, indent : String)
  return unless nodes
  nodes.each do |node|
    if node.node_name == "#text"
      io.puts "#{padding}#text: #{node.node_value.inspect}"
    else
      io.puts "#{padding}#{node.node_name.downcase}:"
      attrs = node.attributes || [] of String
      unless attrs.empty?
        io.puts "#{padding}#{indent}attributes:"
        i = 0
        while i < attrs.size
          io.puts "#{padding}#{indent}#{indent}#{attrs[i]}: #{attrs[i + 1].inspect}"
          i += 2
        end
      end
    end

    if node.child_node_count
      io.puts "#{padding}#{indent}children:"
      print_nodes(io, node.children, padding + indent + indent, indent)
    end
  end
end

server = HTTP::Server.new(&.response.print(HTML))
addr = server.bind_tcp("127.0.0.1", 0)
spawn { server.listen }

page = Rod::Browser.new.must_connect.must_page("http://127.0.0.1:#{addr.port}")
node = page.must_element("body").describe(-1, true)
print_nodes(STDOUT, node.children, "", "  ")
