if Rails.env.production?
    ENV["ELASTICSEARCH_URL"] = 'https://localhost:9300'
end
