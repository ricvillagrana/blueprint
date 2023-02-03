module Blueprint
  module Generator
    module MigrationGenerator
      extend self
      def generate(blueprint)
        blueprint["models"].each do |model_name, fields|
          migration_file = create_migration_file(model_name, fields)
          write_migration_file(migration_file)
        end
      end

      private

      def create_migration_file(model_name, fields)
        migration_name = "create_#{model_name.pluralize}.rb"

        delete_migration(migration_name)

        file_path = "db/migrate/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{migration_name}"

        class_definition = "class Create#{model_name.capitalize.pluralize} < ActiveRecord::Migration[5.2]"
        change_definition = "  def change"
        migration_commands = fields.map do |field_name, field_data|
          type = field_data['type'].split(':')[0]
          if type == "references"
            next unless ["belongs_to"].include?(field_data["references"])

            "    add_reference :#{model_name.pluralize}, :#{field_name}, foreign_key: true"
          else
            "    add_column :#{model_name.pluralize}, :#{field_name}, :#{type}"
          end
        end.join("\n")

        [file_path, [class_definition, change_definition, migration_commands, "  end", "end"].join("\n")]
      end

      def write_migration_file(migration_file)
        File.open(migration_file[0], "w") do |f|
          f.puts migration_file[1]
        end
      end

      def delete_migration(migration_name)
        Dir.glob("db/migrate/*_#{migration_name}").each do |file|
          File.delete(file)
        end
      end
    end
  end
end
