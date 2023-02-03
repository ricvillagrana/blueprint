# frozen_string_literal: true

require "yaml"
require "active_support/inflector"
require "pry"

require_relative "blueprint/version"
require_relative "blueprint/logger"
require_relative "blueprint/generator/migration_generator"
require_relative "blueprint/generator/model_generator"
require_relative "blueprint/generator/controller_generator"

module Blueprint
  class Error < StandardError; end

  FILE = "./blueprint.yml"

  class << self
    def generate(_)
      Logger.log("Generating your from #{FILE}...")

      Logger.log("Creating directories...")
      create_directories

      Logger.log("Creating models...")
      Generator::ModelGenerator.generate(blueprint)

      Logger.log("Creating migrations...")
      Generator::MigrationGenerator.generate(blueprint)

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
  end
end
