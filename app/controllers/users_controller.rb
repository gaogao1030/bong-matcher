require 'rest_client'
class UsersController < ApplicationController
	def new
		redirect_to "http://open-test.bong.cn/oauth/authorize?client_id=1401421769806&redirect_uri=http://haol.org:3000/user/callback&response_type=code"
	end

	def destroy
		logout
		redirect_to root_path
	end

	def callback
		code = params[:code]
		result = RestClient.get "http://open-test.bong.cn/oauth/token?client_id=1401421769806&grant_type=authorization_code&client_secret=706f39dd0a864ce6955925490075a120&redirect_uri=http://haol.org:3000/user/callback&code=#{code}"
		json = JSON.parse(result)
		user_info = RestClient.get "http://open-test.bong.cn/1/userInfo/#{json["uid"]}?access_token=#{json["access_token"]}"
		user_info = JSON.parse(user_info)
		user_info = user_info.merge(json)
		user = push_user_info_to_database(user_info)
		avatar_base64 = RestClient.get "http://open-test.bong.cn/1/userInfo/avatar/#{json["uid"]}?access_token=#{json["access_token"]}"
		avatar_base64 = JSON.parse(avatar_base64)
		user.update_avatar(avatar_base64["value"])
		login_as(user)
		last_day = Time.now - 10.day
		last_day = last_day.strftime("%Y%m%d")
		bongdaysleep = RestClient.get "http://open-test.bong.cn/1/sleep/blocks/#{last_day}/10?uid=#{json["uid"]}&access_token=#{json["access_token"]}"
		bongdaysleep = JSON.parse(bongdaysleep)
		push_bongdaysleep_to_database(bongdaysleep) unless bongdaysleep["value"].empty?
		redirect_to root_path
	end

protected

	def get_last_sleep_data_from_bong(sleep)
		sleep["value"].reverse_each do |s|
			return s unless s["blockList"].empty?
		end
	end

	def push_bongdaysleep_to_database(sleep)
		last_sleep_data = get_last_sleep_data_from_bong(sleep)
		bongday_sleep = get_bongdaysleep(last_sleep_data)
		if bongday_sleep.empty?
			bongday_sleep =	BongdaySleep.new 
			last_sleep_data = get_last_sleep_data_from_bong(sleep)
			bongday_sleep.time_begin 			= last_sleep_data["blockList"][0]["startTime"].to_datetime
			bongday_sleep.time_end 				= last_sleep_data["blockList"][0]["endTime"].to_datetime
			bongday_sleep.bong_type				= last_sleep_data["blockList"][0]["type"]
			bongday_sleep.dsnum			 			= last_sleep_data["blockList"][0]["dsNum"]
			bongday_sleep.lsnum			 			= last_sleep_data["blockList"][0]["lsNum"]
			bongday_sleep.wakenum		 			= last_sleep_data["blockList"][0]["wakeNum"]
			bongday_sleep.waketimes 			= last_sleep_data["blockList"][0]["wakeTimes"]
			bongday_sleep.score			 			= last_sleep_data["blockList"][0]["score"]
			bongday_sleep.user_id					= current_user.id
			if bongday_sleep.save
				bongday_sleep
			end	
		end
	end	

	def push_user_info_to_database(user_info)
		user = get_user(user_info["uid"])
		user = User.new if user.nil?
		user.name     			 = user_info["value"]["name"]
		user.gender   			 = user_info["value"]["gender"]
		user.brithday 			 = user_info["value"]["birthday"]
		user.weight	  			 = user_info["value"]["weight"]
		user.height	  			 = user_info["value"]["height"]
		user.targetsleeptime = user_info["value"]["targetSleepTime"]
		user.targetCalorie   = user_info["value"]["targetCalorie"]
		user.uid						 = user_info["uid"]
		if user.save
			user
		end
	end
	
	def get_bongdaysleep(last_sleep_data)
		time_begin 			= last_sleep_data["blockList"][0]["startTime"].to_datetime
		time_end 				= last_sleep_data["blockList"][0]["endTime"].to_datetime
		sleep = current_user.bongday_sleeps.where(:time_begin => time_begin,:time_end => time_end)
		sleep
	end

	def get_user(uid)
		user = User.find_by(:uid => uid)
		user
	end

end
