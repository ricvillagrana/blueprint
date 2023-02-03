# frozen_string_literal: true

require "yaml"
require "active_support/inflector"
require "pry"

require_relative "blueprint/version"
require_relative "blueprint/logger"
require_relative "blueprint/generator/controller_generator"
require_relative "blueprint/generator/model_generator"

module Blueprint
  class Error < StandardError; end

  FILE = "blueprint.yml"

  class << self
    def generate(_)
      Logger.log("Generating your from #{FILE}...")

      Logger.log("Creating directories...")
      create_directories

      Logger.log("Creating models...")
      Generator::ModelGenerator.generate(blueprint)

      Logger.log("Creating migrations...")
      generate_migrations

      Logger.log("Creating controllers...")
      Generator::ControllerGenerator.generate(blueprint)

      Logger.log("Finished!")
    end

    private

    def blueprint
      if File.exist?(FILE)
        @blueprint ||= YAML.safe_load(File.read(FILE))
      else
        puts "File does not exist"
      end
    end

    def create_directories
      # Split the file path into individual directories
      directories = ['app', 'app/models', 'app/controllers', 'db', 'db/migrate',]

      # Create the subdirectories
      directories.each do |dir|
        Dir.mkdir(dir) unless Dir.exist?(dir)
      end
    end

    def generate_migrations
      @blueprint["models"].each do |model_name, fields|
        migration_name = "create_#{model_name.pluralize}.rb"

        delete_migration(migration_name)

        # Create the migration file
        File.open("db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{migration_name}", "w") do |f|
          # Write the class definition
          f.puts "class Create#{model_name.capitalize.pluralize} < ActiveRecord::Migration[5.2]"
          f.puts "  def change"
          # Write the migration command for each field
          fields.each do |field_name, field_data|
            type = field_data['type'].split(':')[0]
            f.puts "    add_column :#{model_name.pluralize}, :#{field_name}, :#{type}"
          end
          f.puts "  end"
          f.puts "end"
        end
      end
    end

    def delete_migration(migration_name)
      Dir.glob("db/migrate/*_#{migration_name}").each do |file|
        File.delete(file)
      end
    end
  end
end
