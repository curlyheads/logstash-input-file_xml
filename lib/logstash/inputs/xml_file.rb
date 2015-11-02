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

  # The path(s) to the file(s) to use as an input.
  # You can use filename patterns here, such as `/var/log/*.log`.
  # Paths must be absolute and cannot be relative.
  #
  # You may also configure multiple paths. See an example
  # on the <<array,Logstash configuration page>>.
  config :path, :validate => :array, :required => true

  # Exclusions (matched against the filename, not full path). Filename
  # patterns are valid here, too. For example, if you have
  # [source,ruby]
  #     path => "/var/log/*"
  #
  # You might want to exclude gzipped files:
  # [source,ruby]
  #     exclude => "*.gz"
  config :exclude, :validate => :array
  
  # The element path from the root element
  config :xml_element, :validate => :string, :required => false

  # The element path from as xpath query
  config :xpath, :validate => :string, :required => true

  public
  def register
  end # def register

  def run(queue)
  end # def run

end # class LogStash::Inputs::FileXml
