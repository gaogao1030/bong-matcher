class CreateBongdaySleeps < ActiveRecord::Migration
  def change
    create_table :bongday_sleeps do |t|
			t.datetime :time_begin
			t.datetime :time_end
			t.integer :bong_type
			t.integer :dsnum
			t.integer :lsnum
			t.integer :wakenum
			t.integer :waketimes
			t.integer :score
			t.integer :user_id
      t.timestamps 
    end
		add_index :bongday_sleeps, :user_id
  end
end
