class ReadjustEpisodeStructure < ActiveRecord::Migration
  def change
      add_column :shows, :actors, :text
      add_column :shows, :genres, :text

      remove_column :episodes, :actors, :text
      remove_column :episodes, :genres, :text
  end
end
