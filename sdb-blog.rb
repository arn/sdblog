require 'rubygems'
require 'sinatra'
require 'aws_sdb'

before do
  @sdb    = AwsSdb::Service.new
  @domain = 'hello'
end

get '/' do
  results, @more = @sdb.query('hello', "['epoc_second' > '0'] sort 'epoc_second' desc", '3')
  @posts  = []

  results.each do |p|
    @posts << @sdb.get_attributes(@domain, p)
  end

  erb :home
end

post '/' do
  time = Time.now.to_i
  @sdb.put_attributes(@domain, time, params.merge!({'epoc_second' => time}))
  redirect '/'
end

get '/page/:id' do
  results, @more = @sdb.query('hello', "['epoc_second' > '0'] sort 'epoc_second' desc", '3', "#{params[:id]}")
  @posts  = []

  results.each do |p|
    @posts << @sdb.get_attributes(@domain, p)
  end

  erb :home
end

__END__

@@ layout

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html>
  <head>
    <meta http-equiv="Content-type" content="text/html;charset=utf-8">

    <title>blawg</title>
  </head>
  
  <body>
    <%= yield %>
  </body>
</html>

@@ home

<% if @more %>
<h3>  <a href="/page/<%= @more %>">more</a></h3>
<% end %>

<% @posts.each do |p| %>
  <h2><%= p['title'] %></h2>
  <h4><%= p['author'] %></h4>
  <p><%= p['content'] %></p>
<% end %>
