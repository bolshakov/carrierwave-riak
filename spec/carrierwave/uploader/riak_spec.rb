require 'spec_helper'

describe CarrierWave::Uploader::Riak do
  class SomeUploader < described_class
    def initialize(*)
      self.riak_bucket = 'some_bucket'
    end
  end

  let(:uploader) { SomeUploader.new }

  before do
    expect(uploader).to receive(:filename).and_return('some_key')
  end

  it "is inspectable" do
    expect(uploader.inspect).to eq(%Q[#<SomeUploader key="some_key" bucket="some_bucket">])
  end

end
