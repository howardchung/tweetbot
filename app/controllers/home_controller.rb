class HomeController < ApplicationController

    require 'twitter'

    def index
    if session['access_token'] && session['access_secret']
            firstPage=client.user_timeline(:count=>200,:include_rts=>false)
            @latest_tweets=firstPage.map{|obj|obj.text}
            prev_id=0
            current_id=firstPage.last.id
            while prev_id !=current_id
              #last page is added twice
              nextPage=client.user_timeline(:count=>200, :max_id=>current_id+1,:include_rts=>false)
              prev_id=current_id
              current_id=nextPage.last.id
              @latest_tweets.concat(nextPage.map{|obj|obj.text}) if prev_id!=current_id
            end
    else
      render "signin"
    end
  end

  def error
    flash[:error] = "Sign in with Twitter failed"
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out"
  end

    def create
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect_to root_path, notice: "Signed in"
  end

  def client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.oauth_token = session['access_token']
      config.oauth_token_secret = session['access_secret']
    end
  end

end
