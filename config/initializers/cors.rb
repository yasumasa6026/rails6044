# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins 'example.com'
#
#     resource '*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end


Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      ##origins 'localhost:3000', '127.0.0.1:3000',
      origins 'mycomputer:3000','127.0.0.1:3000', ## 追加  MyComputerはng 
      /\Ahttp:\/\/192\.168\.1\.\d{1,3}(:\d+)?\z/,
      /\Ahttp:\/\/192\.168\.10\.\d{1,3}(:\d+)?\z/
      # regular expressions can be used here
 
      resource '*',
        headers: :any,
        expose: ['access-token', 'uid','client','expiry'], ## 追加
        methods: [:get, :post, :put, :patch, :delete, :options, :head]
    end
  end
 
