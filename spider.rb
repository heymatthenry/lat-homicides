require 'nokogiri'
require 'mechanize'
require 'csv'

agent = Mechanize.new
page = agent.get("http://projects.latimes.com/homicide/day/monday/")
homicides = []

#page.links_with(:href => /homicide\/post/).each do |l|
  l = page.links_with(:href => /homicide\/post/)[0]
  pg = l.click

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
#end

CSV.open("homicides.csv", "wb") do |csv|
  homicides.each do |h|
    csv << [h[:name], h[:date], h[:address], h[:neighborhood], h[:age], h[:gender], h[:dow], h[:jxn], h[:race]]
  end
end
