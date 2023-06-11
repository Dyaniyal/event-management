require 'httparty'

class SocialFeedApi

	include HTTParty
	def self.get_facebook_posts(facebook_tags,date)
		# if date == nil
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4") rescue ""
		# else	
		# 	facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAAEUA07UHnEBABbXziqZBHoQ5sBQBBWsE1u8WQlFrydxcB4FpxWFI5BRV786UwuTkLfVdAIYUF67ZBsEGJB2BZA3KVGkDIlKcxOA48rZA0AUszqvZCLnQbswMgyV2EhMx0wZCoNKs5kGEeApEcWcjaaaK5uVGpS2kZD&limit=4&until=#{date}") rescue ""
		# end	
			facebook_data = HTTParty.get("https://graph.facebook.com/#{facebook_tags}/posts?access_token=EAACHRcYXIoUBAC9NgvtFPCWSFX7dcgsWQGb7tWYYMviTW3IeKPqqAWq2naquJibucTdK3tavSSoAZCcI1qn647G9ZCZAKqi5OQTqlQYjJZB2hZCZBbkFFscx0Je8FoSCxnrfBhzolN6OFZCa19ud7y2bfBGw3TyKRcZD") rescue ""
	end	

	def self.get_twitter_posts(url)
		enconded_url = URI.encode("https://publish.twitter.com/oembed?url=#{url}")
		HTTParty.get(enconded_url)
	end
end
