class CreateLoginMessages < ActiveRecord::Migration
  def change
    create_table :login_messages do |t|
      t.text :message
      t.datetime :start
      t.datetime :end
      t.timestamps
    end
  end
end
