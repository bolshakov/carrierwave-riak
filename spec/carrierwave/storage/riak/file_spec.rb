require 'spec_helper'

describe CarrierWave::Storage::Riak::File do
  let(:uploader) do
    double('CarrierWave::Uploader::Riak',
           bucket: 'yellow_bucket',
           riak_nodes: []
    )
  end
  let(:storage) { double('CarrierWave::Storage::Riak') }
  let(:filename) { 'the_key.txt' }

  subject {
    CarrierWave::Storage::Riak::File.new(uploader, storage, filename)
  }

  describe '#path' do
    it 'should return full path' do
      expect(subject.path).to eq '/yellow_bucket/the_key.txt'
    end
  end

  describe "#filename" do
    it "should extract filename from url" do
      expect(subject.filename).to eq 'the_key.txt'
    end
  end

  describe '#path' do
    it 'should return full path in riak storage' do
      expect(subject.path).to eq '/yellow_bucket/the_key.txt'
    end
  end

  describe '==' do
    it 'should be equal if all attributes are equal' do
      expect(subject).to eq CarrierWave::Storage::Riak::File.new(uploader, storage, filename)
    end

    ['uploader', 'storage', 'filename'].each_with_index do |argument, idx|
      it "should not be equal if #{argument}s are not equal" do
        arguments = [uploader, storage, filename]
        arguments[idx] = double(argument)
        expect(subject).not_to eq CarrierWave::Storage::Riak::File.new(*arguments)
      end
    end
  end
end