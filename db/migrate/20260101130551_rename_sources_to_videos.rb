class RenameSourcesToVideos < ActiveRecord::Migration[8.0]
  def change
    rename_table :sources, :videos

    remove_column :videos, :source_type, :string
    add_column :videos, :title, :string
    add_column :videos, :description, :text
    add_column :videos, :external_id, :string
    add_column :videos, :duration, :string
  end
end
