class Video < ApplicationRecord
  validates :url, :platform, presence: true
  validates :platform, inclusion: { in: %w[youtube] }

  belongs_to :feed
  has_one :download, dependent: :destroy
end
