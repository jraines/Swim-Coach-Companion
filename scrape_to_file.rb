require 'rubygems'
require 'pry'
require 'open-uri'
require 'nokogiri'
require 'ruby-debug'

url = 'http://results.liveswim.net/bp/CSSCJO'
url += '/' unless url[/\/$/]
event_list_path = 'evtindex.htm'
event_list_url = url + event_list_path
debugger
doc = Nokogiri::HTML(open(event_list_url))
links = doc.xpath '//a'
event_links = links.collect {|l| l if l.text[/^#/]}
event_links.compact!

el = event_links.map do |l| 
  { :event => l.text, :path => l.attributes['href'].value }
end

@blocks = []
el.each do |el|
  event_url = url + el[:path]
  @blocks << {:event => el[:event], :text => `curl #{event_url} | grep CSSC-CA`}
end

binding.pry
