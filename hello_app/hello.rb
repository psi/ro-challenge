require 'sinatra'

get '/hello' do
  if params[:name]
    "Hello, #{params[:name]}!"
  else
    "Hello!"
  end
end
