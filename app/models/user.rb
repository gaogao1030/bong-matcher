# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  gender          :integer
#  brithday        :integer
#  weight          :integer
#  height          :integer
#  targetsleeptime :integer
#  targetCalorie   :integer
#  uid             :integer
#  created_at      :datetime
#  updated_at      :datetime
#  avatar          :string(255)
#
# Indexes
#
#  index_users_on_uid  (uid)
#

class User < ActiveRecord::Base
	has_many :bongday_sleeps
	has_many :match_users, :foreign_key => "origin_id"
	mount_uploader :avatar, AvatarUploader

	def update_avatar(avatar_base64)
		tmp = Tempfile.new("fileuplpoad")	
		tmp.binmode
		tmp.write(Base64.decode64(avatar_base64))
		upload_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tmp, :filename => 'avatar.jpg',:original_filename => "avatar.jpg")
		self.update_attributes(:avatar => upload_file)
	end

	def match_all_user
		arr=[]
		match_user = User.where.not(:id => self.id)
		match_user.each do |user|
			result = self.bong_matcher(user)
			result = 100 if result > 100 
			result = 0 if result < 0 
			record(self,user,result)
		end
	end

	def gender
		if self.read_attribute(:gender) == 1
			return "汉子"
		else
		  return "妹子"
		end
	end

	def record(me,matcher,result)
		match_user = me.match_users.find_by(:matcher_id => matcher.id)	
		match_user = MatchUser.new if match_user.nil?
		match_user.origin_id   = me.id
		match_user.matcher_id = matcher.id
		match_user.score			 = result
		if match_user.save
			match_user
		end
	end

	def bong_matcher(tuser)
		return (100 - second_to_hour(self.get_unrepeat_max_time(tuser)) * (second_to_hour(self.get_sleep_time_diffrence(tuser))+5)*5 - self.get_dsnum_and_lsnum_ratio_diffrence(tuser) * get_max_wake_num(tuser)*10 - get_score_diffrence(tuser)).to_i
	end

	def get_score_diffrence(tuser)	
		self.lastday_sleep_info.score - tuser.lastday_sleep_info.score
	end

	def get_max_wake_num(tuser)
		[self.lastday_sleep_info.wakenum,tuser.lastday_sleep_info.wakenum].max
	end

	def lastday_sleep_info
		sleep_info = self.bongday_sleeps.first
	end

	def have_repeat_time(tuser)
		if self.lastday_sleep_info.time_begin < tuser.lastday_sleep_info.time_end && self.lastday_sleep_info.time_end > tuser.lastday_sleep_info.time_begin
			return true
		end
		return false
	end
	
	def check_repeat_time_type(tuser)
	 if self.lastday_sleep_info.time_begin < tuser.lastday_sleep_info.time_end && self.lastday_sleep_info.time_begin > tuser.lastday_sleep_info.time_begin &&
			self.lastday_sleep_info.time_end > tuser.lastday_sleep_info.time_end
		return "right_repeat"
	 end
	 if self.lastday_sleep_info.time_end > tuser.lastday_sleep_info.time_begin && self.lastday_sleep_info.time_end < tuser.lastday_sleep_info.time_end &&
			self.lastday_sleep_info.time_begin < tuser.lastday_sleep_info.time_begin
		return "left_repeat"
	 end
	 if self.lastday_sleep_info.time_begin > tuser.lastday_sleep_info.time_begin && self.lastday_sleep_info.time_end < tuser.lastday_sleep_info.time_end
		return "included"
	 end
	 if self.lastday_sleep_info.time_begin < tuser.lastday_sleep_info.time_begin && self.lastday_sleep_info.time_end > tuser.lastday_sleep_info.time_end
		return "include"
	 end
	end

	def second_to_hour(second)
		(second/3600).to_i
	end

	def get_repeat_time(tuser)
		if self.have_repeat_time(tuser)
			repeat_type = check_repeat_time_type(tuser)
			case repeat_type
			when "right_repeat"	
				return tuser.lastday_sleep_info.time_end - self.lastday_sleep_info.time_begin
			when "left_repeat"
				return self.lastday_sleep_info.time_end - tuser.lastday_sleep_info.time_begin
			when "include"
				return tuser.lastday_sleep_info.time_end - tuser.lastday_sleep_info.time_begin
			when "included"
				return self.lastday_sleep_info.time_end - self.lastday_sleep_info.time_begin
			end  
		end
		return 0
	end

	def get_unrepeat_max_time(tuser)
		if self.have_repeat_time(tuser)
			repeat_type = check_repeat_time_type(tuser)
			case repeat_type
			when "right_repeat"	
				left_unrepeat_time = self.lastday_sleep_info.time_begin - tuser.lastday_sleep_info.time_begin
				right_unrepeat_time = self.lastday_sleep_info.time_end - tuser.lastday_sleep_info.time_end
				return [left_unrepeat_time,right_unrepeat_time].max
			when "left_repeat"
				left_unrepeat_time = tuser.lastday_sleep_info.time_begin - self.lastday_sleep_info.time_begin
				right_unrepeat_time = tuser.lastday_sleep_info.time_end - self.lastday_sleep_info.time_end
				return [left_unrepeat_time,right_unrepeat_time].max
			when "include"
				left_unrepeat_time = tuser.lastday_sleep_info.time_begin - self.lastday_sleep_info.time_begin
				right_unrepeat_time = self.lastday_sleep_info.time_end - tuser.lastday_sleep_info.time_end
				return [left_unrepeat_time,right_unrepeat_time].max
			when "included"
				left_unrepeat_time = self.lastday_sleep_info.time_begin - tuser.lastday_sleep_info.time_begin
				right_unrepeat_time = tuser.lastday_sleep_info.time_end - self.lastday_sleep_info.time_end
				return [left_unrepeat_time,right_unrepeat_time].max
			end 
		 else
	    	(self.lastday_sleep_info.time_begin - tuser.lastday_sleep_info.time_begin).abs
		end
	end

	def get_sleep_time
		sleep_time = self.lastday_sleep_info.time_end - self.lastday_sleep_info.time_begin
	end

	def get_sleep_time_diffrence(tuser)
		self_sleep_time = self.get_sleep_time
		tuser_sleep_time = tuser.get_sleep_time
		return (self_sleep_time - tuser_sleep_time).abs
	end

	def dsnum_and_lsnum_ratio
		Float(self.lastday_sleep_info.dsnum)/Float(self.lastday_sleep_info.lsnum).round(2)
	end

	def get_dsnum_and_lsnum_ratio_diffrence(tuser)
		(self.dsnum_and_lsnum_ratio - tuser.dsnum_and_lsnum_ratio).abs
	end

end
