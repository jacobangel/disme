#!/usr/bin/env ruby
# encoding: utf-8
# Basically a super small app
require 'bundler/setup'
require 'sinatra'
require 'sinatra/json'
require 'multi_json'
require 'yaml'

set :public_folder, File.dirname(__FILE__) + '/public'
set :views, ['views/partials', 'views/pages', 'views/layouts', 'views']

BASE_TITLE = "Disis.me"

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
end
