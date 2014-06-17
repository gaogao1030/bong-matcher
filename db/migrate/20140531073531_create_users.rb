class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
			t.string :name
			t.integer :gender
			t.integer :brithday
			t.integer :weight
			t.integer :height
			t.integer :targetsleeptime
			t.integer :targetCalorie
			t.integer :uid
      t.timestamps
    end
		add_index :users, :uid
  end
end
