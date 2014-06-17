BongMatcher::Application.routes.draw do
	resource :user do
		collection do
			get 'callback' => 'users#callback'  
			delete 'destroy'	 => 'users#destroy'
		end
	end

	get "match_user" => "home#match_user", :as => :match
	root :to => 'home#index'
end
