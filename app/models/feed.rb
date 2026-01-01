class Feed < ApplicationRecord
  validates :name, presence: true

  has_many :videos, dependent: :destroy
end

