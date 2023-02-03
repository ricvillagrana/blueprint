module Blueprint
  module Generator
    module ModelGenerator
      extend self

      def generate(blueprint)
        blueprint["models"].each do |model_name, fields|
          File.open("app/models/#{model_name.classify.underscore}.rb", 'w') do |f|
            f.write <<~RB
              class #{model_name.classify} < ApplicationRecord
              #{build_references(fields).join("\n")}

              #{fields.map { |field_name, field_data| validations(field_name, field_data) }.compact.join("\n")}
              end
            RB
          end
        end
      end

      private

      def validations(field_name, field_data)
        validations = field_data['validates']
        return if validations.nil?

        "  validates :#{field_name}, #{validations.map { |validation| validation.include?(":") ? validation : "#{validation}: true" }.join(", ")}"
      end

      def build_references(fields)
        references = fields.select { |_, field_data| field_data["type"] == "references" }
        references.map do |field_name, field_data|
          "  #{field_data["references"]} :#{field_name}"
        end
      end
    end
  end
end
