class CreatePosts < ActiveRecord::Migration
  def change
  
    drop_table :posts
    
    create_table :posts do |t|
      t.string :name
      t.string :worktype
      t.string :starttime
      t.string :endtime
      t.decimal :hours
      t.text :notes
      

      t.timestamps
    end
  end
end
