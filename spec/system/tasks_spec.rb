# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  it 'タスクを新規登録できること' do
    visit new_task_path
    fill_in 'Title', with: 'RSpecの学習'
    click_button 'Create Task'

    expect(page).to have_content 'Task was successfully created.'
    expect(page).to have_content 'RSpecの学習'
  end
end
