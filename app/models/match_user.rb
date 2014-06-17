# == Schema Information
#
# Table name: match_users
#
#  id         :integer          not null, primary key
#  origin_id  :integer
#  matcher_id :integer
#  score      :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_match_users_on_origin_id_and_matcher_id_and_score  (origin_id,matcher_id,score)
#

class MatchUser < ActiveRecord::Base
	belongs_to :origin,  :class_name => "User"
	belongs_to :matcher, :class_name => "User"
end
