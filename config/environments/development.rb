Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  ###config.action_mailer.default_url_options = { host: 'localhost', port: 3001 }
  config.action_mailer.default_url_options = { host: 'MyComputer', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  
   ## https://devise-token-auth.gitbook.io/devise-token-auth/config/email_auth
   config.action_mailer.delivery_method = :smtp
   config.action_mailer.raise_delivery_errors = true
   config.action_mailer.smtp_settings = {
     address: 'localhost',
     ###address: 'MyComputer',
     ##address: '192.168.10.149',
     port: '1025',
   }
   config.action_mailer.logger = Logger.new(config.paths['log'].first)
   config.action_mailer.logger.level = Logger::INFO
 
   ###config.action_controller.asset_host = 'http://localhost:3001'
   config.action_controller.asset_host = 'http://MyComputer:3001'
   
   config.action_controller.forgery_protection_origin_check = false
   config.consider_all_requests_local = false
 
   ###config.logger = Logger.new(STDOUT)
   config.logger = Logger.new('log/development.log', 'daily')
   config.hosts << "MyComputer"
end


###
# MailCatcher
# https://qiita.com/uenomoto/items/1af0626e18bde4c2e245  から引用
###

# MailCatcherのgemを使って、送信メールをブラウザで確認します。

# まずはインストールから
# gem install mailcatcher
# このGemはbundle installでインストールすると正常に動作しないことがあるらしいです。
# このGemの開発者もgem install mailcatcherでインストールすることをすすめています

# 次に、Railsの設定を変更します。開発環境の設定
# config/environments/development.rbを以下のように設定します
# 大体41行あたりです

# # Don't care if the mailer can't send.
# config.action_mailer.raise_delivery_errors = false
# # ここから追加
# config.action_mailer.delivery_method = :smtp
# config.action_mailer.smtp_settings = { address: "localhost", port: 1025 }

# これで、Railsアプリケーションから送信されるメールはMailCatcherによってキャッチされ、
# http://localhost:1080 で閲覧可能になります。

# これらの設定後、実際にメールを送信するアクション(注文確定)すると
# メールが送信できているのかを確認します。

# orders#createアクションを起こしてこのようなログが出ていれば成功です。

# OrderMailer#order_confirmation: processed outbound mail in 114.5ms
# rails_ec-web-1  | Delivered mail 6497c8b6e979_13fd4-491@63818aa95769.mail (120.8ms)
# 最後にMailCatcherを起動します
# mailcatcherとコマンドを記述します

# mailcatcher

# Starting MailCatcher v0.8.2
# ==> smtp://127.0.0.1:1025
# ==> http://127.0.0.1:1080
# *** MailCatcher runs as a daemon by default. Go to the web interface to quit.
# このようにレスポンスがあれば接続できています
# http://127.0.0.1:1080のIPアドレスでアクセスするか
# http://localhost:1080 でアクセスしたら送信されたメールをブラウザで確認できます。