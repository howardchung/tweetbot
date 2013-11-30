class HomeController < ApplicationController

    require 'twitter'

    def index
    if session['access_token'] && session['access_secret']
        @latest_tweets = Rails.cache.read "latest_tweets"
        if !@latest_tweets
            puts "API call"
            @user = client.user(include_entities: true)
            @timeline=client.user_timeline(@user, :count=>3200, :include_rts=>false).map{|obj|obj.text}
            @latest_tweets = @timeline
            Rails.cache.write("latest_tweets", @timeline, :expires_in => 5.minutes)
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
