# encoding: utf-8

require 'nokogiri'

module DzInfo
  module Scraper
    module Parser
      class NoParserAvailableError < StandardError; end

      def self.for_file(file)
        file = File.open(file.to_s, 'r') unless file.is_a?(IO)
        doc = Nokogiri::HTML(file)

        case file.path
        when /uspa\.org/
          UspaParser.new(doc)
        when /dropzone\.com/
          DropzoneParser.new(doc)
        else
          raise NoParserAvailableError.new("No parser found")
        end
      end

      class Base
        @@parse_calls = 0
        def initialize(doc)
          @doc = doc
        end

        def parse!(node=nil)
          node ||= @doc
          @@parse_calls += 1

          #dz = Model::Dropzone.new(source: source,
          #                         name: s[:name].call(@doc),
          #                         coordinates: s[:coordinates].call(@doc))
          #dz.save!
          puts "Num: #{@@parse_calls}" 
          puts "Name: #{name(node)}"
          puts "Coords: #{coords(node)}"
          puts "Source: #{source}"
          puts "URL: #{url(node)}"
          puts
        end
      end

      class DropzoneParser < Base
        def name(node)
          node.css('h1 span.fn').first.content.strip
        end

        def coords(node)
          node.css('.halfblock.floatleft').each do |script|
            latlng = script.content.scan(/Lat: (-?\d+\.\d+)\s+Lng: (-?\d+\.\d+)/).flatten
            return latlng.map(&:to_f) unless latlng.empty?
          end
          return nil 
        end

        def url(node)
          html = node.css(".halfblock:first").to_s
          html.scan(/<a href="[^"]+\/jump\.cgi[^"]+"[^>]*>(https?:\/\/[^<]+)<\/a>/).flatten.first
        end

        def source
          "dropzone"
        end

        def parse!
          node = @doc.css("div.boxContent:first").first
          super(node)
        end
      end

      class UspaParser < Base
        def name(node)
          node.css("div:first > div:first > span.subhead").first.content
        end

        def coords(node)
          latlng = node.css("div:first > div:nth-child(3)").first.content.scan(/LAT: (-?\d+\.\d+)\s+LNG: (-?\d+\.\d+)/).flatten
          latlng.empty? ? nil : latlng
        end

        def url(node)
          node.css("div:first > div:first > a").first.try(:attribute, "href").try(:value)
        end

        def source
          "uspa"
        end

        def parse!
          @doc.css('td[valign=middle]:has(a[name])').each do |node|
            super(node)
          end
        end
      end
    end
  end
end
