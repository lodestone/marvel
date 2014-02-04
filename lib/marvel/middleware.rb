class Marvel::SetAuthParams < Faraday::Middleware
  def call(env)
    env[:url].query = "#{Marvel::DEFAULT_PARAMS}&#{env[:url].query}"
    @app.call(env)
  end
end

class Marvel::JsonParser < Faraday::Response::Middleware
  def on_complete(env)
    json = JSON.parse(env[:body], :symbolize_names => true)
    if json[:code] == 200
      json = json[:data][:results] || json[:data][:result]
      json.each do |j|
        j[:characters] = j[:characters][:items] if j[:characters].present?
        j[:comics]     = j[:comics][:items]     if j[:comics].present?
        j[:creators]   = j[:creators][:items]   if j[:creators].present?
        j[:events]     = j[:events][:items]     if j[:events].present?
        j[:series]     = j[:series][:items]     if j[:series].present?
        j[:stories]    = j[:stories][:items]    if j[:stories].present?
      end
      # TODO: We don't *alwyas* want to do this
      json = json.first if json.length == 1
      errors = json.delete(:errors) || {}
      metadata = json.delete(:metadata) || []
      env[:body] = { :data => json, :errors => errors, :metadata => metadata }
    else
      # TODO: Raise an error
      env[:body] = { :data => json, :errors => json[:status], :metadata => metadata }
    end
  end
end

