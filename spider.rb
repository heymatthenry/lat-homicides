require 'nokogiri'
require 'mechanize'
require 'csv'

def get_names(day)
  agent = Mechanize.new
  page = agent.get("http://projects.latimes.com/homicide/day/#{day}/")
  homicides = []

  puts "#{day}:"
  page.links_with(:href => /homicide\/post/).each do |l|
    begin
      pg = l.click
      puts "fetching #{pg.title.strip}. . ."

      hom = {
        :name => pg.search(".homicide-post h1").text.split(",")[0],
        :date => pg.link_with(:href => /homicide\/date/).text.gsub(",",""),
        :address => pg.search(".homicide-meta-rail div:first-child").text.strip,
        :neighborhood => pg.link_with(:href => /homicide\/neighborhood/).text,
        :age => pg.link_with(:href => /homicide\/age/).text,
        :gender => pg.link_with(:href => /homicide\/gender/).text,
        :dow => pg.link_with(:href => /homicide\/day/).text,
        :jxn => pg.link_with(:href => /homicide\/jurisdiction/).text,
        :race => pg.link_with(:href => /homicide\/race/).text
      }

      homicides << hom
    rescue => e
      puts e
    end
  end

  write_csv homicides
end

def write_csv(homicides)
  CSV.open("homicides.csv", "a+") do |csv|
    homicides.each do |h|
      csv << [ "#{h[:name]}",
               "#{h[:date]}",
               "#{h[:address]}",
               "#{h[:neighborhood]}",
               "#{h[:age]}",
               "#{h[:gender]}",
               "#{h[:dow]}",
               "#{h[:jxn]}",
               "#{h[:race]}" ]
    end
  end
end

["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"].each { |day| get_names day }
