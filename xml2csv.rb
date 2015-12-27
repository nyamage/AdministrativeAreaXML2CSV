#!/usr/bin/env ruby
require 'nokogiri'
require 'pp'
require 'csv'

def parseAdministrativeBoundaryXML(file)
	f = open(file)
	xml = Nokogiri::XML(f)
	begin
		boundaries = xml.xpath("//ksj:AdministrativeBoundary")
		areaes = boundaries.map{|b| 
			area={}
			b.children.each{|el| 
				if ["prefectureName", "countyName", "cityName"].include?(el.name)
					area[el.name]=el.text 
				end
			}; 
			area 
		}
		areaes.uniq!
	rescue Nokogiri::XML::XPath::SyntaxError
		pp "it's not xml we expected. skip it."
	end
	areaes
end

xmlfiles = Dir.glob('data/**/*.xml')

areaesInJapan = []
xmlfiles.each{|file|
	areaes = parseAdministrativeBoundaryXML(file)
	next if areaes.nil?
	areaesInJapan.concat(areaes)
}

CSV.open('area.csv', 'w') do |csv|
	csv << ["prefecture", "county", "city"]
	areaesInJapan.each{|area|
		csv << [ area['prefectureName'], area['countyName'], area['cityName']]
	}
end
