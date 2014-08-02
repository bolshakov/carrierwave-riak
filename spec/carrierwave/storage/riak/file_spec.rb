require 'spec_helper'

describe CarrierWave::Storage::Riak::File do
  let(:uploader) do
    object_double(CarrierWave::Uploader::Riak.new,
           riak_bucket: 'yellow_bucket',
           riak_nodes: [],
           mounted_as: :file,
           model: nil
    )
  end
  let(:storage) { instance_double('CarrierWave::Storage::Riak') }
  let(:filename) { 'the_key.txt' }
  let(:riak_generated_key) { 'auto_generated_key' }

  subject {
    CarrierWave::Storage::Riak::File.new(uploader, storage, filename)
  }

  describe '#store' do
    let(:file) { double('File', read: '', content_type: 'text/plain') }
    let(:riak_file) { instance_double('Riak::RObject', key: riak_generated_key) }
    let(:riak_client) { object_double(CarrierWave::Storage::Riak::Connection.new, store: riak_file) }

    before do
      expect(subject).to receive(:riak_key).and_return(riak_key)
      expect(subject).to receive(:riak_client).and_return(riak_client)
    end

    context 'when riak_genereated_keys is true' do
      let(:riak_key) { nil }

      before do
        allow(uploader).to receive(:riak_genereated_keys).and_return(true)
      end

      it 'should update column' do
        expect(subject).to receive(:update_filename).with(riak_file.key)

        subject.store(file)
      end
    end

    context 'when riak_genereated_keys is false' do
      let(:riak_key) { filename }

      before do
        allow(uploader).to receive(:riak_genereated_keys).and_return(false)
      end

      it 'should update column' do
        expect(subject).to receive(:update_filename).with(riak_file.key)

        subject.store(file)
      end

      it 'should not update identifier' do
        expect {
          subject.store(file)
        }.not_to change {
          subject.identifier
        }
      end
    end
  end

  describe '#update_filename' do
    context 'when riak_genereated_keys is true' do
      before do
        allow(uploader).to receive(:riak_genereated_keys).and_return(true)
      end

      it 'should update identifier' do
        expect {
          subject.send :update_filename, riak_generated_key
        }.to change {
          subject.identifier
        }.from(filename).to(riak_generated_key)
      end

      it 'should call #update_model_column' do
        expect(subject).to receive(:update_model_column).with(riak_generated_key)

        subject.send :update_filename, riak_generated_key
      end
    end

    context 'when riak_genereated_keys is false' do
      before do
        allow(uploader).to receive(:riak_genereated_keys).and_return(false)
      end

      it 'should not update identifier' do
        expect {
          subject.send :update_filename, riak_generated_key
        }.not_to change {
          subject.identifier
        }
      end

      it 'should not call #update_model_column' do
        expect(subject).not_to receive(:update_model_column)

        subject.send :update_filename, riak_generated_key
      end
    end
  end

  describe '#update_model_column' do
    let(:model) { double('active_record_model') }

    before do
      allow(uploader).to receive(:model).and_return(model)
    end

    it 'should update column on AR model' do
      expect(model).to receive(:update_column).with(:file, riak_generated_key)

      subject.send(:update_model_column, riak_generated_key)
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
