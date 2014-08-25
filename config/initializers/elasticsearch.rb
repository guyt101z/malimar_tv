if Rails.env.production?
    ENV["ELASTICSEARCH_URL"] = 'https://104.131.205.107:9300'
end
