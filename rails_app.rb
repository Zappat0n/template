def source_paths
  Array(super) +
    [File.join(__dir__, 'assets')]
end

gem_group :development do
  gem 'guard'
  gem 'guard-livereload'
  gem 'rack-livereload'
end

gem_group :development, :test do
  gem 'rspec-rails'
  gem 'hirb'
end

copy_file '.rubocop.yml'
copy_file '.stylelintrc.json'
copy_file 'linters.yml', '.github/workflows/linters.yml'
copy_file 'application.html.erb', 'app/views/layouts/application.html.erb', force: true
copy_file '_head.html.erb', 'app/views/layouts/_head.html.erb'
copy_file '_header.html.erb', 'app/views/layouts/_header.html.erb'
copy_file '_notice.html.erb', 'app/views/layouts/_notice.html.erb'
copy_file '_shim.html.erb', 'app/views/layouts/_shim.html.erb'
copy_file '_footer.html.erb', 'app/views/layouts/_footer.html.erb'

gsub_file 'config/environments/production.rb', '# config.force_ssl = true', 'config.force_ssl = true'

bootstrap = yes?('Would you like to install Bootstrap?')

if bootstrap
  gem 'bootstrap-sass'
  gem 'jquery-rails'
end

devise = yes?('Would you like to install Devise?')

gem 'devise' if devise

if yes?('Would you like to install Omniauth?')
  gem 'omniauth'
  gem 'omniauth-google-apps'
end

after_bundle do
  run 'guard init'
  run 'guard init livereload'
  environment "config.middleware.insert_after ActionDispatch::Static, Rack::LiveReload\n", env: 'development'

  generate 'rspec:install'

  if bootstrap
    insert_into_file 'app/assets/stylesheets/application.css',
                     "\n@import 'bootstrap-sprockets';\n" \
                     "@import 'bootstrap';\n",
                     after: ' */'
    insert_into_file 'app/javascript/packs/application.js',
                     "\nimport \"bootstrap\"\n" \
                     "import \"../stylesheets/application\"\n",
                     after: 'import "channels"'
    copy_file 'application.js', 'app/assets/javascripts/application.js'
  end

  if devise
    generate 'devise:install'
    environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
    environment "config.action_mailer.default_url_options = { host: '', port: 3000 }", env: 'production'
    insert_into_file 'spec/rails_helper.rb',
                     "\n  config.include Devise::Test::ControllerHelpers, type: :controller\n" \
                     "  config.include Devise::Test::ControllerHelpers, type: :view\n" \
                     "  config.include Devise::Test::IntegrationHelpers, type: :feature\n",
                     after: 'RSpec.configure do |config|'
  end
end
