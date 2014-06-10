require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'json'

broadcasts = []

month = "%02d" % Time.now.month #start from the current month

#check 99 days from the start of the month
(1..99).each do |i|

	url = "http://espn.go.com/watchespn/index?tabType=upcoming&xhr=1&startDate=2014#{month}#{i}&searchTerm="
	doc = Nokogiri::HTML(open(url))

	events = doc.css("section#CR").css("ul.league-obj").css("li") #could make this 1 css selector, clearer to chain them imo

	events.each do |e|
		puts "#{e.children[0].text} #{e.children[1].text} #{e.children[3].text[0..-34]}"
		b = {}
		b["date"] = e.children[0].text
		b["time"] = e.children[1].text
		b["name"] = e.children[3].text[0..-34]
		broadcasts.push(b)
	end

	#puts "#{i}"

	#STDOUT.flush

end


File.open('broadcasts.json', 'w') {|f| f.write(broadcasts.to_json) }