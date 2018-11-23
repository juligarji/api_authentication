require 'rails/generators/migration'

module ApiAuthentication
  module Generators
    class ModelGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "Generating the api_authentication models"
      argument :model, :type => :string, :required => true

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        files = Dir[Rails.root + 'app/models/*.rb']
        models = files.map{ |m| File.basename(m, '.rb').camelize }

        if models.include? model.classify
          puts ' ********** Error **********'
          puts 'Model name already exists'
          puts '********** ********** **********'
          return
        end

          generate "model", "#{model.downcase.pluralize} --parent ApiAuthentication::User --skip-migration"
       
          migration_template "user_migration.rb.erb", "db/migrate/create_#{model.downcase.pluralize}.rb"
      end
    end
  end
end