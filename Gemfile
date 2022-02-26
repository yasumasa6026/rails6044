source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.0.4', '>= 6.0.4.4'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false
###gem 'activestorage'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
###ブラウザには、セキュリティの観点から異なるオリジン間でのアクセスを制限する仕組みが備わっています。
### 例えば、https://aaa.example.comというオリジンからhttps://mysite.comにXMLHttpRequestで通信しようとした場合、
###ブラウザに以下のエラーメッセージが表示されます。
###Access to XMLHttpRequest at 'https://mysite.com' from origin 'https://aaa.example.com' has been blocked by CORS policy:
###               No 'Access-Control-Allow-Origin' header is present on the requested resource.
###アプリケーションによっては、別のオリジン間でデータのやりとりをしたいケースもあるため、
###  この制約を部分的に解除する仕組みのことをCORS (Cross-Origin Resource Sharing)と呼びます。
gem 'rack-cors'

###CarrierWaveとは、ファイルのアップロード機能を簡単に追加する事が出来るgemです
###CarrierWaveは、アップロードしたファイルの保存先はデフォルトでpublic/uploadsですが、外部のストレージ(例: Amazon S3)にも設定する事が出来ます。
gem 'carrierwave'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# 「dotenv」は環境変数を環境ごとにファイルベースで管理するのに便利なGemです。
gem 'dotenv-rails'

### before fog
## sudo apt-get install libxml2-dev
## sudo apt-get install build-essential libcurl4-openssl-dev
## gem install ovirt-engine-sdk -v '4.3.0' --source 'https://rubygems.org/'
##gem 'fog'
gem 'json'

###https://www.nopio.com/blog/upload-files-with-rails-active-storage/
gem 'active_model_serializers'

###gem 'ngrok-tunnel'

gem 'sidekiq' 
gem 'rubyzip','~>1.3.0'

gem 'devise'
gem 'devise_token_auth'
gem 'rack-cors'
gem 'omniauth','>= 1.0.0'

