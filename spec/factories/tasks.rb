# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    association :user
    title { 'テスト' }
    description { 'どこかへ散歩に行く' }
    status { :todo }
  end
end
