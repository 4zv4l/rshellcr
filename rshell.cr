require "socket"
require "colorize"

def usage(err)
  puts "error: #{err}".colorize(:red)
  puts "usage: #{File.basename __FILE__} [ip] [port]"
  exit 1
end

def handle(client)
  puts "[+] New Client"
  while (cmd = client.gets)
    puts "=> #{cmd}"
    client.puts `#{cmd}`
  end
end

ip = ARGV[0]? || usage "missing ip and port"
port = ARGV[1]? || usage "missing port"

TCPServer.open(ip, port.to_i) do |server|
  puts "[+] Listening on #{ip}:#{port}"
  loop do
    handle server.accept
  rescue
    puts "[-] Client Gone"
    next
  end
end
