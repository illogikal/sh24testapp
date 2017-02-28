require 'bundler'
require 'json'
Bundler.require
class App < Sinatra::Base
  enable :sessions
  helpers do
    def logged_in?
      session[:login] && session[:password]
    end

    def gh_client
      @gh_client ||= Octokit::Client.new(login: session[:login], password: session[:password])
    end
  end

  def langs_from_repos u
    gh_client.repositories(u).map {|r| r.language }.compact
  rescue Octokit::NotFound
    []
  end

  def langs_from_gists u
    gh_client.gists(u).map {|g| g[:files].map {|f| f.language } }.flatten.compact
  rescue Octokit::NotFound
    []
  end

  def stat_for_lang lang, count, total, idx=0
    "#{idx+1}: #{lang} (#{(count.to_f*100/total).round(1)}%) \n"
  end

  def stats_for_user_lang repos: [], gists: []
    return 'No language found for this user' if repos.count == 0 && gists.count == 0
    totalled_langs = (repos + gists).group_by{|i| i}.map{|k,v| [k, v.count] }.sort {|a,b| b[1] <=> a[1]}
    result         = "Best guess for #{@gh_user.login} (#{@gh_user.name}): \n"
    totalled_langs[0..1].each.with_index { |obj, idx| result << stat_for_lang(obj[0], obj[1], (repos.count + gists.count), idx) }
    result
  end

  get '/' do
    erb :index
  end

  get '/template' do
    erb :template
  end

  post '/login' do
    @gh_client = Octokit::Client.new(login: params[:login], password: params[:password])
    begin
      @gh_client.user
      session[:login], session[:password] = params[:login], params[:password]
    rescue Octokit::Unauthorized
      @gh_client = nil
    end
    redirect to('/')
  end

  post '/logout' do
    @gh_client = session[:login] = session[:password] = nil
    redirect to('/')
  end

  get '/search' do #ajax
    return 'Login first!' unless logged_in?
    begin
      @gh_user = gh_client.user params[:name]
      stats_for_user_lang repos: langs_from_repos(@gh_user), gists: langs_from_gists(@gh_user)
    rescue Octokit::NotFound
      'No user found with that name!'
    rescue Octokit::Unauthorized
      @gh_client = session[:login] = session[:password] = nil
      'Wrong creds!'
    end
  end
end