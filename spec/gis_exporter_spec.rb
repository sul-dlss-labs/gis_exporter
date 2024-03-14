# frozen_string_literal: true

require 'gis_exporter'

RSpec.describe GisExporter do
  let(:export_dir) { 'spec/temp/gis_export' }
  let(:gis) { described_class.new(bag_dir, export_dir) }

  before do
    FileUtils.rm_r(export_dir) if File.directory?(export_dir)
  end

  context 'when item has a data.zip' do
    let(:bag_dir) { 'spec/fixtures/bb131xn0863' }

    describe '#has_data_zip' do
      it 'can see the item lacks a data.zip' do
        expect(gis.data_zip?).to be(true)
      end
    end

    describe '#content_files' do
      it 'can find item content files' do
        filenames = gis.content_files.map { |path| path.basename.to_s }.sort
        expect(filenames).to eq(['preview.jpg'])
      end
    end

    describe '#data_zip_entries' do
      it 'can find files inside the data.zip, minus the iso XML files' do
        filenames = gis.data_zip_entries.map(&:name).sort
        expect(filenames).to eq(
          %w[
            ice19980716.dbf
            ice19980716.prj
            ice19980716.shp
            ice19980716.shp.xml
            ice19980716.shx
          ]
        )
      end
    end

    describe '#run_export' do
      it 'has the correct files and file sizes' do
        gis.run_export
        files = Pathname.new(export_dir).children.sort
        expect(files.length).to eq(6)

        expect(files[0].basename.to_s).to eq('ice19980716.dbf')
        expect(files[0].size).to eq(1809)

        expect(files[1].basename.to_s).to eq('ice19980716.prj')
        expect(files[1].size).to eq(145)

        expect(files[2].basename.to_s).to eq('ice19980716.shp')
        expect(files[2].size).to eq(124_808)

        expect(files[3].basename.to_s).to eq('ice19980716.shp.xml')
        expect(files[3].size).to eq(17_020)

        expect(files[4].basename.to_s).to eq('ice19980716.shx')
        expect(files[4].size).to eq(572)

        expect(files[5].basename.to_s).to eq('preview.jpg')
        expect(files[5].size).to eq(2_680)
      end
    end
  end

  context 'when item lacks a data.zip' do
    let(:bag_dir) { 'spec/fixtures/bad' }

    describe '#has_data_zip' do
      it 'can see the item lacks a data.zip' do
        expect(gis.data_zip?).to be(false)
      end
    end

    describe '#run_export' do
      it 'export raises an exception' do
        expect { gis.run_export }.to raise_error(GisExporter::MissingDataZip)
      end
    end
  end
end
