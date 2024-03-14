# frozen_string_literal: true

require 'zip'

# A class for exporting the original files from an old-style GIS item for
# reaccessioning with Preassembly.
class GisExporter
  attr_accessor :bag_dir, :export_dir

  def self.export(bag_dir, export_dir)
    new(bag_dir, export_dir).run_export
  end

  def initialize(bag_dir, export_dir)
    @bag_dir = bag_dir
    @export_dir = Pathname.new(export_dir)
  end

  def run_export
    raise ExportDirExists, "#{@export_dir} already exists" if Pathname.new(@export_dir).directory?
    raise MissingDataZip, "#{content_dir} doesn't contain data.zip" unless data_zip?

    FileUtils.mkdir_p(@export_dir)

    export_zip_files
    export_content_files
  end

  def export_zip_files
    data_zip_entries.each do |entry|
      File.open(@export_dir.join(entry.name), 'wb') do |output|
        entry.get_input_stream do |input|
          while (data = input.read(1024))
            output.write(data)
          end
        end
      end
    end
  end

  def export_content_files
    content_files.each do |path|
      # use copy_entry to copy directories if they are present (shouldn't be)
      FileUtils.copy_entry(path, @export_dir.join(path.basename))
    end
  end

  # returns a list of any content files that are present and are not one of the zip files
  def content_files
    content_dir.children.filter do |path|
      !['data.zip', 'data_EPSG_4326.zip'].include?(path.basename.to_s)
    end
  end

  def content_dir
    Pathname.new(@bag_dir).join('data/content/')
  end

  def data_zip?
    data_zip_path.file?
  end

  def data_zip_path
    content_dir.join('data.zip')
  end

  def data_zip_entries
    Zip::File.new(data_zip_path).filter do |f|
      f.name !~ /-(iso19110|iso19139|fgdc).xml$/
    end
  end

  class Error < RuntimeError
  end

  class MissingDataZip < Error
  end

  class ExportDirExists < Error
  end
end
