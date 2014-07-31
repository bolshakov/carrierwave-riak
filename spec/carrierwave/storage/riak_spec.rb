require 'spec_helper'

describe CarrierWave::Storage::Riak do
  let(:uploader) { double('uploader', filename: 'file name.txt') }

  subject { CarrierWave::Storage::Riak.new(uploader) }

  context '#store' do
    let(:riak_file) { double('CarrierWave::Storage::Riak::File') }
    let(:file) { double('File') }

    before do
      expect(CarrierWave::Storage::Riak::File).to receive(:new).with(uploader, subject, uploader.filename).and_return(riak_file)
    end

    it 'should store file given' do
      expect(riak_file).to receive(:store).with(file)
      result = subject.store!(file)
      expect(result).to eq riak_file
    end
  end

  context "#retrieve!" do
    let(:riak_file) { double('CarrierWave::Storage::Riak::File') }
    let(:filename) { 'another file name.txt' }

    before do
      expect(CarrierWave::Storage::Riak::File).to receive(:new).with(uploader, subject, filename).and_return(riak_file)
    end

    it 'should return riak file' do
      result = subject.retrieve!(filename)
      expect(result).to eq riak_file
    end
  end
end
