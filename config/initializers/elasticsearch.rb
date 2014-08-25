if Rails.env.production?
    ENV["ELASTICSEARCH_URL"] = 'http://localhost:9300'
end
