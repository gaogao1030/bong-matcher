class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
	helper_method :current_user
  protect_from_forgery with: :exception
	
	def login_as(user)
		session[:uid]	= user.uid
	end

	def logout
		session.delete(:uid)
		@current_user = nil
	end

	def current_user
		@current_user = login_from_session unless defined?(@current_user)	
		@current_user
	end

	def login_from_session
	  if session[:uid].present?
			begin
				User.find_by(:uid => session[:uid])
			rescue
				session[:uid] = nil
			end
		end
	end

end
