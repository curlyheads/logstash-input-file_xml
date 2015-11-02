require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/file_xml"

describe LogStash::Inputs::FileXml do

  it_behaves_like "an interruptible input plugin" do
    let(:config) { { "interval" => 100 } }
  end

end
