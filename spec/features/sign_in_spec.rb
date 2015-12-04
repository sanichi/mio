require 'rails_helper'

describe "Authentication" do
  let(:user) { create(:user) }

  context "sign in" do
    it "success" do
      visit root_path
      expect(page).to_not have_link t(:session_sign__out)
      expect(page).to_not have_link t(:transaction_transactions)
      expect(page).to_not have_link t(:upload_uploads)

      click_link t(:session_sign__in)
      fill_in t(:email), with: user.email
      fill_in t(:session_password), with: user.password
      click_button t(:session_sign__in)

      expect(page).to_not have_link t(:session_sign__in)
      expect(page).to have_link t(:session_sign__out)
    end

    it "failure" do
      visit root_path
      click_link t(:session_sign__in)
      fill_in t(:email), with: user.email
      fill_in t(:session_password), with: "rubbish"
      click_button t(:session_sign__in)

      expect(page).to have_link t(:session_sign__in)
      expect(page).to_not have_link t(:session_sign__out)
    end
  end

  context "access" do
    it "signed in" do
      login

      visit transactions_path
      expect(page).to have_title t(:transaction_transactions)

      visit uploads_path
      expect(page).to have_title t(:upload_uploads)

      visit new_upload_path
      expect(page).to have_title t(:upload_new)

      visit todos_path
      expect(page).to have_title t(:todo_todos)

      visit elm_todos_path
      expect(page).to have_title t(:todo_todos)

      visit users_path
      expect(page).to have_title t(:user_users)

      visit logins_path
      expect(page).to have_title t(:login_logins)
    end

    it "signed out" do
      visit transactions_path
      expect(page).to have_title t(:session_sign__in)

      visit uploads_path
      expect(page).to have_title t(:session_sign__in)

      visit new_upload_path
      expect(page).to have_title t(:session_sign__in)

      visit todos_path
      expect(page).to have_title t(:session_sign__in)

      visit elm_todos_path
      expect(page).to have_title t(:session_sign__in)

      visit users_path
      expect(page).to have_title t(:session_sign__in)

      visit logins_path
      expect(page).to have_title t(:session_sign__in)
    end
  end
end
