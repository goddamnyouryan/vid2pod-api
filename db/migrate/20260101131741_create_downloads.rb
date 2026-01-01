class CreateDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :downloads do |t|
      t.belongs_to :video, null: false, foreign_key: true, type: :uuid
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :downloads, :status
  end
end
