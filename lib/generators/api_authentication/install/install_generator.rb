require 'rails/generators/migration'

module ApiAuthentication
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "add the migrations needed for the gem"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        migration_template "create_api_authentication_users.rb", "db/migrate/create_api_authentication_users.rb"
      end

      def create_initializer_file
        copy_file 'api_authentication.rb', 'config/initializers/api_authentication.rb'
      end

    end
  end
end