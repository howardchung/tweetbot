class HomeController < ApplicationController

    require 'twitter'

    def index
    if session['access_token'] && session['access_secret']
            prev=client.user_timeline(:include_rts=>false)
            @latest_tweets=prev.map{|obj|obj.text}
            prev_id=0
            last_id=prev.last.id
            while prev_id !=last_id
            current=client.user_timeline(:max_id=>last_id,:include_rts=>false)
            @latest_tweets.concat(current.map{|obj|obj.text})
            prev_id=last_id
            last_id=current.last.id
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
