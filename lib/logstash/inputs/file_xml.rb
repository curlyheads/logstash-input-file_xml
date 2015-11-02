# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::FileXml < LogStash::Inputs::Base
  config_name "file_xml"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  # The path to the file to use as an input.
  # You can use a filename pattern here, such as `/var/log/*.log`.
  # The path must be absolute and cannot be relative.
  config :path, :validate => :string, :required => true

  # Exclusions (matched against the filename, not full path). Filename
  # patterns are valid here, too. For example, if you have
  # [source,ruby]
  #     path => "/var/log/*"
  #
  # You might want to exclude gzipped files:
  # [source,ruby]
  #     exclude => "*.gz"
  config :exclude, :validate => :array
  
  # The element path from as xpath query
  config :xpath, :validate => :string, :required => true

  public
  def register
    require 'nokogiri'
    require "filewatch/tail"

    @xml = Nokogiri::XML(File.open(@path))
    @logger.info("Registering file input", :path => @path)

    @watch_config = {
      :logger => @logger
    }

    if Pathname.new(@path).relative?
      raise ArgumentError.new("File paths must be absolute, relative path specified: #{@path}")
    end
  end # def register

  def run(queue)
    @watch = FileWatch::Watch.new(@watch_config)
    @watch.exclude(@exclude)
    @watch.watch(@path)
    @watch.subscribe {
      @xml.xpath(@xpath).each { |record|
        # record to XML, to string, remove leading and trailing whitespace,
        # remove record separator from the end of the string, and replace
        # multiple whitespace with single whitespace. 
        record = record.to_xml(:encoding => 'UTF-8').to_s.strip.chomp.gsub(/\s+/, " ")
        @logger.debug? && @logger.debug("Received record", :path => @path, :text => record)
        @codec.decode(record) do |event|
          decorate(event)
          queue << event
        end
      }
    }
    finished
  end # def run

  def teardown
    if @watch
      @watch.quit
      @watch = nil
    end
  end # def teardown
end # class LogStash::Inputs::FileXml
