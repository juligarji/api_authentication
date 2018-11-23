module ApiAuthentication
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Creating the initializer for the api_authentication gem"

      def create_initializer_file
        copy_file 'api_authentication.rb', 'config/initializers/api_authentication.rb'
        inject_into_class "app/controllers/application_controller.rb", ApplicationController, "  filter_parameter :password\n"
      end
    end
  end
end