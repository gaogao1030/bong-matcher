# == Schema Information
#
# Table name: bongday_sleeps
#
#  id         :integer          not null, primary key
#  time_begin :datetime
#  time_end   :datetime
#  bong_type  :integer
#  dsnum      :integer
#  lsnum      :integer
#  wakenum    :integer
#  waketimes  :integer
#  score      :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_bongday_sleeps_on_user_id  (user_id)
#

class BongdaySleep < ActiveRecord::Base
	belongs_to :user
end
