module Blueprint
  module Generator
    module ControllerGenerator
      extend self

      def generate(blueprint)
        blueprint["controllers"].each do |controller_name, actions|
          model_name = controller_name.classify
          before_action = actions.delete("before_action")
          methods = actions.delete("methods")

          File.open("app/controllers/#{controller_name}_controller.rb", 'w') do |f|
            f.puts "class #{controller_name.classify.pluralize}Controller < ApplicationController"
            before_action.each do |action, for_actions|
              f.puts "  before_action :#{action}, only: [:#{for_actions.join(", :")}]"
            end

            f.puts

            actions.each do |action_name, steps|
              f.puts "  def #{action_name}"
              steps.each { |step| write_step(f, step, model_name) }
              f.puts "  end"
              f.puts
            end

            f.puts "  private"
            f.puts

            methods.each do |method_name, steps|
              f.puts "  def #{method_name}"
              steps.each { |step| write_step(f, step, model_name) }
              f.puts "  end"
              f.puts
            end

            f.puts "end"
          end
        end
      end

      def write_step(file, step, model_name)
        command, params = step
        case command
        when "render"
          file.puts "    render '#{params}'"
        when "redirect_to"
          file.puts "    redirect_to #{params}"
        when "find"
          file.puts "    @#{model_name.underscore} = #{model_name}.find(#{params})"
        when "update"
          file.puts "    @#{model_name.underscore}.update(#{params})"
        when "destroy"
          file.puts "    @#{model_name.underscore}.destroy"
        when "save"
          file.puts "    @#{model_name.underscore}.save"
        when "create"
          file.puts "    #{model_name}.create(#{params})"
        when "query"
          file.puts "    @#{model_name.underscore.send(params == 'all' ? 'pluralize' : 'singularize')} = #{model_name}.#{params}"
        end
      end
    end
  end
end
