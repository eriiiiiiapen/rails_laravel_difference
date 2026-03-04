class Task < ApplicationRecord
    has_one_attached :image
    belongs_to :user
    enum :status, { todo: 0, doing: 1, done: 2 }

    validates :title, :status, presence: true
end
