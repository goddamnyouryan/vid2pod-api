class Download < ApplicationRecord
  belongs_to :video
  has_one_attached :file

  validates :status, inclusion: { in: %w[pending downloading completed failed] }
end
