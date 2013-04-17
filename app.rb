#!/usr/bin/env ruby
# encoding: utf-8
# Basically a super small app
require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'multi_json'
require 'yaml'
require 'mail'

# Defaults
set :public_folder, File.dirname(__FILE__) + '/public'
set :views, ['views/partials', 'views/pages', 'views/layouts', 'views']

BASE_TITLE = "Disis.me"
BASE_DOMAIN = 'www.example.com'
TO_ADDY = 'whomever+disme@example.com'

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.sendgrid.net',
    :port => '587',
    :domain => BASE_DOMAIN,
    :user_name => ENV['SENDGRID_USERNAME'],
    :password => ENV['SENDGRID_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end


# Routes
get '/' do
	@title = "Jonathan Doe | #{BASE_TITLE}"
	@body_class = "page-home"
	@resume = YAML.load_file('data/resume.yaml')

	erb :index
end


get '/resume.json' do
	resume = YAML.load_file('data/resume.yaml')

	json resume
end

get '/contact' do 
	redirect to ('/#/contact')
end

post '/contact' do
	logger.info request.xhr?
	if !(params[:body] && params[:from] && params[:subject] && params[:secret_code] == "pooh") then
		if request.xhr? then	
			return json({ success: false, message: "Missing required fields!"})
		else
			redirect to ('/#/contact')
		end
	end

	body_text = params[:body]
	from_address = "%s <%s>" % [params[:name], params[:from]]
	subject_text = params[:subject]

	mail = Mail.new do
		to 		TO_ADDY
		from 	from_address
		subject subject_text 
		body 	body_text
	end

	begin
		mail.deliver!
		if request.xhr? then 
			json ({success: true, message: "You did it!"})
		else 
			redirect to ('/#/contact/success')
		end
	rescue Exception => e
		if request.xhr? then 
			json ({success: false, message: e.message })
		else 
			redirect to ('/#/contact')	
		end
	end	
end

# Helpers
helpers do

	# render partials views
	def render(*args)
		if args.first.is_a?(Hash) && args.first.keys.include?(:partial)
			return erb "#{args.first[:partial]}".to_sym, :layout => false
		else
			super
		end
	end

	# find templates in alternate directories
	def find_template(views, name, engine, &block)
		Array(views).each { |v| super(v, name, engine, &block) }
	end

	# logging functions
	def logger
		request.logger
	end
end
