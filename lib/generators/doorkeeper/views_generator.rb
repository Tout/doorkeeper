module Doorkeeper
  module ViewPathTemplates #:nodoc:
    extend ActiveSupport::Concern

    included do
      public_task :copy_views
    end

    def copy_views
      view_directory :applications
      view_directory :authorizations
      view_directory :authorized_applications
    end

    protected

    def view_directory(name, _target_path = nil)
      directory name.to_s, _target_path || "#{target_path}/#{name}"
    end

    def target_path
      "app/views/doorkeeper"
    end

    def target_layout_path
      "app/views/layouts/doorkeeper"
    end

  end

  class ViewsGenerator < Rails::Generators::Base
  end
end