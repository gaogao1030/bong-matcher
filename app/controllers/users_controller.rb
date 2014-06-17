require 'rest_client'
class UsersController < ApplicationController
	def new
		redirect_to "http://open-test.bong.cn/oauth/authorize?client_id=1401421769806&redirect_uri=http://693b8596.ngrok.com/user/callback&response_type=code"
	end

	def destroy
		logout
		redirect_to root_path
	end

	def callback
		code = params[:code]
		result = RestClient.get "http://open-test.bong.cn/oauth/token?client_id=1401421769806&grant_type=authorization_code&client_secret=706f39dd0a864ce6955925490075a120&redirect_uri=http://693b8596.ngrok.com/user/callback&code=#{code}"
		json = JSON.parse(result)
		user_info = RestClient.get "http://open-test.bong.cn/1/userInfo/#{json["uid"]}?access_token=#{json["access_token"]}"
		user_info = JSON.parse(user_info)
		user_info = user_info.merge(json)
		user = push_user_info_to_database(user_info)
		login_as(user)
		last_day = Time.now - 1.day
		last_day = last_day.strftime("%Y%m%d")
		bongdaysleep = RestClient.get "http://open-test.bong.cn/1/sleep/blocks/#{last_day}?uid=#{json["uid"]}&access_token=#{json["access_token"]}"
		bongdaysleep = JSON.parse(bongdaysleep)
		push_bongdaysleep_to_database(bongdaysleep) unless bongdaysleep["value"].empty?
		redirect_to root_path
	end

protected
	def push_bongdaysleep_to_database(sleep)
		bongday_sleep = get_bongdaysleep
		if bongday_sleep.empty?
			bongday_sleep =	BongdaySleep.new 
			bongday_sleep.time_begin 			= sleep["value"][0]["startTime"].to_datetime
			bongday_sleep.time_end 				= sleep["value"][0]["endTime"].to_datetime
			bongday_sleep.bong_type				= sleep["value"][0]["type"]
			bongday_sleep.dsnum			 			= sleep["value"][0]["dsNum"]
			bongday_sleep.lsnum			 			= sleep["value"][0]["lsNum"]
			bongday_sleep.wakenum		 			= sleep["value"][0]["wakeNum"]
			bongday_sleep.waketimes 			= sleep["value"][0]["wakeTimes"]
			bongday_sleep.score			 			= sleep["value"][0]["score"]
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
	
	def get_bongdaysleep
		sleep = current_user.bongday_sleeps.where("time_end >= :now",{now:Time.now - 1.day })
		sleep
	end

	def get_user(uid)
		user = User.find_by(:uid => uid)
		user
	end

end
