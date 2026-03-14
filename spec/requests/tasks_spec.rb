# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  let(:user) { create(:user) }

  describe 'GET /tasks' do
    it '一覧画面の表示に成功すること' do
      sign_in user
      create_list(:task, 3, user: user)
      get tasks_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('テスト')
    end
  end
end
