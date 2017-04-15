# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/CyclomaticComplexity
require 'bundler'
Bundler.require

# Object.try from Rails
class Object
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    elsif !nil?
      __send__(*a, &b)
    end
  end
end

# Extracts info from page
class Parser
  def initialize
    @file_name = ARGV.first
  end

  attr_reader :file_name

  def doc
    @doc ||= Nokogiri::HTML(ARGF.read)
  end

  def title
    @title ||= (doc.css('article[role=main] h1').first.try(:content) || '').strip
  end

  def meta
    @meta ||= (doc.css('article[role=main] .signature code').first.try(:content) || '').strip
  end

  def type
    @type ||= begin
      return 'Constructor' if title == '<init>'
      case meta
      when /\bannotation class\b/ then 'Annotation'
      when /\benum class\b/ then 'Enum'
      when /\bclass\b/ then meta.end_with?('Exception') ? 'Exception' : 'Class'
      when /\binterface\b/ then 'Interface'
      when /\bobject\b/ then 'Object'
      when /\btypealias\b/ then 'Type'
      when /\bfun\b/ then 'Method'
      when /\bva[rl]\b/ then 'Property'
      else
        'Element' if /^[A-Z0-9_]+$/ =~ title
      end
    end || 'Guide'
  end

  def url
    "https://kotlinlang.org/#{file_name[2..-1]}"
  end

  def to_sql
    if title.empty?
      $stderr.puts [url, 'SKIPPED', ' '].join("\n")
    else
      result = "#{type.upcase} | #{title}"
      $stderr.puts [url, meta, result, ' '].join("\n")
      "INSERT INTO searchIndex VALUES (NULL, '#{title}', '#{type}', '#{file_name}');"
    end
  rescue
    $stderr.puts "Processing #{url} --> ERROR"
    raise
  end
end

parser = Parser.new
puts parser.to_sql
