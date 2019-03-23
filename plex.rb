#!/usr/bin/env ruby
$LOAD_PATH.unshift ("./gems/httparty-0.16.4/lib")
$LOAD_PATH.unshift ("./gems/multi_xml-0.6.0/lib")
$LOAD_PATH.unshift ("./gems/mime-types-3.2.2/lib")
$LOAD_PATH.unshift ("./gems/mime-types-data-3.2018.0812/lib")
$LOAD_PATH.unshift ("./gems/alfred-3_workflow-0.1.0/lib")


require 'httparty'
require 'alfred-3_workflow'

require 'open-uri'
require 'fileutils'
require 'nokogiri'

workflow = Alfred3::Workflow.new

query = ARGV[0]

pms_ip_address = ENV["pms-ip-address"]
plex_token = ENV["plex-token"]

get = ""
get_on_deck = "/library/onDeck"
get_search = "/search"


if query.include? "deck"
  get = get_on_deck
else
  get = get_search
end

search_query = "&query=" + query

if get == "/library/onDeck"
  search_query = ""
end

initial_search =
  HTTParty.get("http://"+ pms_ip_address + get + "?X-Plex-Token=" + plex_token + search_query)

xml = Nokogiri::XML(initial_search.to_s)
video_object = xml.css("Video")

title = ""
summary = ""

video_counter = 0
for video in video_object
  the_video = video_object[video_counter]
  if the_video["type"] != "movie"
    title = the_video["grandparentTitle"] + " - " + the_video["title"]
    summary = the_video["summary"]
  elsif
    title = the_video["title"]
    summary = the_video["tagline"]
  end
  workflow.result
      .title(title)
      .subtitle(summary)
      .arg(query)
  video_counter += 1
end

if query == "update!"
  workflow.result
      .title("Hit enter to update the workflow")
      .subtitle("This will pull the latest version from git. Any modifications will be overwritten.")
      .arg("update!")
elsif video_object[0] == nil
  workflow.result
      .title("Can't find any results.")
      .subtitle("Sorry 😦")
      .arg(query)
end

print workflow.output 