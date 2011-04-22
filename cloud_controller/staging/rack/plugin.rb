require File.expand_path('../database_support', __FILE__)

class RackPlugin < StagingPlugin
  include GemfileSupport
  include RackDatabaseSupport

  def framework
    'rack'
  end

  # PWD here is after we change to the 'app' directory.
  def start_command
    if uses_bundler?
      # Specify Thin if the app bundled it
      "#{local_runtime} #{gem_bin_dir}/bundle exec thin -R config.ru $@ start"
    else
      "#{local_runtime} -S thin -R config.ru $@ start"
    end
  end

  # Returns a path relative to the 'app' directory.
  def gem_bin_dir
    "./rubygems/ruby/#{library_version}/bin"
  end


  def stage_application
    Dir.chdir(destination_directory) do
      create_app_directories
      copy_source_files
      compile_gems
      create_startup_script
    end
  end

  def startup_script
    vars = environment_hash
    # PWD here is before we change to the 'app' directory.
    if uses_bundler?
      local_bin_path = File.dirname(runtime['executable'])
      vars['PATH'] = "$PWD/app/rubygems/ruby/#{library_version}/bin:#{local_bin_path}:/usr/bin:/bin"
      vars['GEM_PATH'] = vars['GEM_HOME'] = "$PWD/app/rubygems/ruby/#{library_version}"
    end
    # bindings = configure_database
    # vars['DATABASE_URL'] = database_url_for(bindings.first)
    generate_startup_script(vars)
  end

end

