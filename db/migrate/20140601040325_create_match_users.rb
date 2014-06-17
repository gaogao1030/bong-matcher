class CreateMatchUsers < ActiveRecord::Migration
  def change
    create_table :match_users do |t|
			t.integer :origin_id
			t.integer :matcher_id
			t.integer :score
      t.timestamps
    end
		add_index :match_users, [:origin_id, :matcher_id, :score]
  end
end
