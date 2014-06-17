class HomeController < ApplicationController
	def index
	end

	def match_user
		redirect_to root_path if current_user.nil?
		current_user.match_all_user
		@match_user = current_user.match_users.order(:score).first
		@message = get_message(@match_user.score)	
	end

protected
	def get_message(score)
		if score < 60
			return "注定孤独一生"
		end
		if score > 60 and score < 70
			return "或许有些姻缘" 
		end
		if score > 70 and score < 80
			return "不错，有戏！"
		end
		if score > 70 and score < 80
			return "千里回眸，就是TA!"
		end
		if score >80 and score < 100
			return "真爱!在一起!"
		end
	end

end
