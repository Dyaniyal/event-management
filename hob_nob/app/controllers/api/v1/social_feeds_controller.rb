class Api::V1::SocialFeedsController < ApplicationController

	skip_before_filter :authenticate_user,:load_filter
	require 'social_feed_api'

	def index
	    @event = Event.find_by_id(params[:event_id]) 
               #Rails.cache.fetch("/#{request.url}", :expires_in => 5.minutes) do
		if @event.present? or @event.facebook_social_tags.present? or @event.twitter_social_tags.present? #or @event.twitter_handle.present? 
			#@facebook_posts
			if @event.facebook_social_tags.present?
				@facebook_posts = get_feacebook_posts(@event.facebook_social_tags)
			else
				@facebook_posts = []
			end
		#twitter posts	
		if @event.twitter_social_tags.present? or @event.twitter_handle.present? 
			@twitter_posts = get_twitter_posts(@event)
		else
			@twitter_posts = []
		end
			@total_posts = @facebook_posts + @twitter_posts
	  	@social_feeds =  @total_posts.sort_by { |hsh| hsh[:created_at] }.reverse!
	  end	
          render :layout => false
        #end
  end
end

	def get_feacebook_posts(facebook_tags)
               Rails.cache.fetch("facebook_posts_#{request.url}", :expires_in => 3.minutes) do
			#session[:facebook_post_date] = (Date.today).to_date if request.format == "html"
			session[:facebook_post_date] = (Date.today+1).to_date if request.format == "html"
			@posts = SocialFeedApi.get_facebook_posts(facebook_tags,session[:facebook_post_date])
			#session[:facebook_post_date] = @posts["data"].last["created_time"].to_date if @posts.present? && @posts["data"].present?
			if 	@posts.present? && @posts["data"].present?
				session[:facebook_post_date] = @posts["data"].last["created_time"].to_date
			else
			  session[:facebook_post_date] = (session[:facebook_post_date]).to_date - 1		
			end
			data = []
			@posts["data"].each do |post|
				hsh = {:facebook_frames =>post["id"],:created_at=>post["created_time"].to_datetime}
				data << hsh
			end if @posts["data"].present?
			@facebook_posts = data
                 end
	end	

	def get_twitter_posts(event)
        Rails.cache.fetch("twitter_posts_#{request.url}", :expires_in => 3.minutes) do
		@twitter_tags =  @twitter_tags = event.twitter_social_tags.split(',').map{|x| '#'+x}.join(' OR ') if event.twitter_social_tags.present?
		@tweet_handle = event.twitter_handle if event.twitter_handle.present?
		session[:last_twitter_id] = nil if request.format == "html"
		session[:last_handle_id] = nil if request.format == "html"
		last_tweet_date = event.last_tweet_date.strftime("%Y-%m-%d") if event.last_tweet_date.present?
		@twitter_posts = CLIENT.search(@twitter_tags, result_type: "recent",since:"#{last_tweet_date}",max_id:session[:last_twitter_id],exclude:"retweets").take(100) rescue[] 
		@twitter_handle_post = CLIENT.search(@tweet_handle, result_type: "recent",since:"#{last_tweet_date}",max_id:session[:last_handle_id],exclude:"retweets").take(100) rescue[] 		
		session[:last_twitter_id] = @twitter_posts.last.id-1  if @twitter_posts.present?
		session[:last_handle_id] = @twitter_handle_post.last.id-1  if @twitter_handle_post.present?
		@twitter_posts = @twitter_posts + @twitter_handle_post 
		@twitter_posts = @twitter_posts.uniq.sort_by{ |k, v| k.created_at}.reverse!
	  data = []
	  @twitter_posts.each do |post|
		 	@posts = SocialFeedApi.get_twitter_posts(post.url)
			twitter_data = {:twitter_frame => @posts["html"],:created_at => post.created_at}
			data << twitter_data  
		end
		@posts = data
        end
	end	
