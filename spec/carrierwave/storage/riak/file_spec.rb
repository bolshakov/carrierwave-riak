require 'spec_helper'

describe CarrierWave::Storage::Riak::File do
  let(:uploader) do
    double('CarrierWave::Uploader::Riak',
           riak_genereated_keys: true,
           riak_bucket: 'yellow_bucket',
           riak_nodes: [],
           mounted_as: :file
    )
  end
  let(:storage) { double('CarrierWave::Storage::Riak') }
  let(:filename) { 'the_key.txt' }

  subject {
    CarrierWave::Storage::Riak::File.new(uploader, storage, filename)
  }

  describe '#store' do
    let(:file) { double('File', read: '', content_type: 'text/plain') }
    let(:riak_file) { double('Riak::RObject', key: filename) }
    let(:riak_client) { double('CarrierWave::Storage::Riak::Connection', store: riak_file) }

    before do
      expect(subject).to receive(:riak_client).and_return(riak_client)
    end

    it 'should update column' do
      expect(subject).to receive(:update_model_column).with(filename)

      subject.store(file)
    end
  end

  describe '#update_model_column' do
    let(:model) { double('active_record_model') }
    let(:key) { 'auto_generated_key' }
    before do
      expect(uploader).to receive(:model).and_return(model)
    end

    it 'should update column on AR model' do
      expect(model).to receive(:update_column).with(:file, key)
      subject.send(:update_model_column, key)
    end
  end

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

  describe '#identifier' do
    it 'should return normal supplied identifier' do
      expect(uploader).to receive(:riak_genereated_keys).and_return(nil)
      expect(subject.identifier).to eq 'the_key.txt'
    end

    it 'should return nil if riak_genereated_keys option is true' do
      expect(uploader).to receive(:riak_genereated_keys).and_return(true)
      expect(subject.identifier).to be nil
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
