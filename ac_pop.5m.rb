#!/usr/bin/env ruby

# <xbar.title>Asheron's Call Server Population</xbar.title>
# <xbar.version>v0.1</xbar.version>
# <xbar.author>John Kisor</xbar.author>
# <xbar.author.github>jkisor</xbar.author.github>
# <xbar.desc>Display Asheron's Call server population</xbar.desc>

require "net/http"
require "json"

def pipe(input, ops)
  ops.reduce(input) { |v,l| l.(v) }
end

def fetch_data(url)
  pipe(url, [
    -> url { Net::HTTP.get(URI(url)) },
    -> response { JSON.parse(response) },
  ])
end

def fetch_servers
  fetch_data("https://treestats.net/player_counts-latest.json")
end

def fetch_character(name)
  fetch_data("https://treestats.net/Levistras/#{name}.json")
end

def server_view(server)
  "🌀#{server["count"]}"
end

def character_view(char)
  "#{char['name']}: #{char['level']} | href=https://treestats.net/#{SERVER_NAME}/#{char['name']}"
end

SERVER_NAME = "Levistras"
CHARACTER_NAMES = ["Loaf", "Tea"]

server = fetch_servers.detect { |s| s["server"] == SERVER_NAME }
characters = CHARACTER_NAMES.map { |name| fetch_character(name) }

view = [
  server_view(server),
  "---",
  characters.map(&method(:character_view))
].flatten

view.each { |line| puts line }
