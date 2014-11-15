require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'date'
require 'json'
require 'active_support/time'

broadcasts_espn = []

month = "%02d" % Time.now.month #start from the current month

#check 99 days from the start of the month
(1..99).each do |i|

	url = "http://espn.go.com/watchespn/index?tabType=upcoming&xhr=1&startDate=2014#{month}#{i}&searchTerm="
	doc = Nokogiri::HTML(open(url))

	events = doc.css("section#CR").css("ul.league-obj").css("li") #could make this 1 css selector, clearer to chain them imo

	events.each do |e|
		d = Date.strptime("#{e.children[0].text.strip}/#{Time.now.year}", "%m/%d/%Y").strftime("%Y-%m-%d")
		puts "#{d} #{e.children[1].text} #{e.children[3].text[0..-34]}"
		b = {}
		b["site"] = "espn.ico"
		b["name"] = e.children[3].text[0..-34].strip
		b["date"] = d
		b["time"] = e.children[1].text
		broadcasts_espn.push(b)
	end

end

broadcasts_willow = []

url = "http://willowfeeds.willow.tv/fixtureByDate.json"
response = open(url).read


obj = JSON.parse(/HandleFixturesByDate\((.*)\)/.match(response)[1])

obj["matchDetails"].each do |match|
	if !match["smname"].downcase.include?("test")
		b = {}
		date = DateTime.parse(match["st"])
		b["site"] = "willow.ico"		
		b["name"] =  "#{match["t1"]} vs. #{match["t2"]} (#{match["smname"]})"
		b["date"] = date.in_time_zone("Eastern Time (US & Canada)").strftime("%Y-%m-%d")
		b["time"] = date.in_time_zone("Eastern Time (US & Canada)").strftime("%l:%M %p EST").strip
		# p b
		puts "#{b["date"]} #{b["time"]} #{b["name"]}"
		broadcasts_willow.push(b)
	else
		first_date = DateTime.parse(match["st"])
		for i in 1..5
			b = {}
			date = first_date + (i-1)
			b["site"] = "willow.ico"
			b["name"] = "#{match["t1"]} vs. #{match["t2"]} (#{match["smname"]}, Day #{i})"
			b["date"] = date.in_time_zone("Eastern Time (US & Canada)").strftime("%Y-%m-%d")
			b["time"] = date.in_time_zone("Eastern Time (US & Canada)").strftime("%l:%M %p EST").strip
			# p b
			puts "#{b["date"]} #{b["time"]} #{b["name"]}"
			broadcasts_willow.push(b)
		end
	end
end

broadcasts = (broadcasts_espn + broadcasts_willow).sort do |a,b| 
	t_a = DateTime.parse("#{a["date"]}T#{a["time"]}")
	t_b = DateTime.parse("#{b["date"]}T#{b["time"]}")
	t_a <=> t_b
end

File.open("#{File.dirname(__FILE__)}/broadcasts.json", 'w') {|f| f.write(broadcasts.to_json) }