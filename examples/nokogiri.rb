require 'nokogiri'

def fuzz(bytes)
  html_doc = Nokogiri::HTML(bytes)
end
