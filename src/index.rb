require 'nokogiri'

file_name = ARGV.first
doc = Nokogiri::HTML(ARGF.read)

puts 'CREATE TABLE IF NOT EXISTS searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);'
puts 'CREATE UNIQUE INDEX IF NOT EXISTS anchor ON searchIndex (name, type, path);'

title = doc.css('head > title').first.content
puts "INSERT INTO searchIndex VALUES (NULL, '#{title}', 'Guide', '#{file_name}');"
