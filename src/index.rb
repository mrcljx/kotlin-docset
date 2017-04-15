require 'bundler'
Bundler.require

file_name = ARGV.first

$stderr.print "Processing #{file_name}"

doc = Nokogiri::HTML(ARGF.read)

title = doc.css('head > title').first.content
type = 'Guide'

if title.start_with? 'stdlib /'
  parts = title.gsub('stdlib / ', '').split('.')

  article = doc.css('article[role=main]').first

  title_node = article.css('h1').first

  if title_node
    title = title_node.content
    meta = article.css('code').first.content
  else
    title = parts.last
    meta = ''
  end

  if title == '<init>'
    type = 'Constructor'
    title = parts[-1]
  elsif meta.include? ' annotation class '
    type = 'Annotation'
  elsif meta.include? ' enum class '
    type = 'Enum'
  elsif meta.include? ' class '
    type =
      if meta.end_with? 'Exception'
        'Exception'
      else
        'Class'
      end
  elsif meta.include? ' interface '
    type = 'Interface'
  elsif meta.include? ' object '
    type = 'Object'
  elsif meta.include? ' fun '
    type = 'Method'
  elsif meta.include? ' var '
    type = 'Property'
  elsif meta.include? ' val '
    type = 'Property'
  elsif /^[A-Z0-9_]+$/ =~ title
    type = 'Element' # enum element
  else
    $stderr.print ' ???'
  end
end

$stderr.puts " --> #{type.upcase} #{title}"

puts "INSERT INTO searchIndex VALUES (NULL, '#{title}', '#{type}', '#{file_name}');"
