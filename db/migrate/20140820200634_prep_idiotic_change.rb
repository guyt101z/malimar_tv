class PrepIdioticChange < ActiveRecord::Migration
  def change
      #move from per-account to per-Roku
      remove_column :users, :expiry
  end
end
