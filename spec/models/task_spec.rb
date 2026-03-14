# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  it 'タイトルがない場合は無効になること' do
    task = build(:task, title: nil) # factorybot
    expect(task).not_to be_valid
    expect(task.errors[:title]).to include("can't be blank")
  end
end
