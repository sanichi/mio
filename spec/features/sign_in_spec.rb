require 'rails_helper'

describe "Authentication" do
  include_context "test_data"

  let(:user) { create(:user) }

  context "sign in" do
    it "success" do
      visit root_path
      expect(page).to_not have_link sign_out
      expect(page).to_not have_link transactions
      expect(page).to_not have_link uploads

      click_link sign_in
      fill_in email, with: user.email
      fill_in password, with: user.password
      click_button sign_in

      expect(page).to_not have_link sign_in
      expect(page).to have_link sign_out
    end

    it "failure" do
      visit root_path
      click_link sign_in
      fill_in email, with: user.email
      fill_in password, with: "rubbish"
      click_button sign_in

      expect(page).to have_link sign_in
      expect(page).to_not have_link sign_out
    end
  end

  context "access" do
    it "signed in" do
      login

      visit transactions_path
      expect(page).to have_title transactions

      visit uploads_path
      expect(page).to have_title uploads

      visit new_upload_path
      expect(page).to have_title new_upload

      visit todos_path
      expect(page).to have_title todo_todos

      visit elm_todos_path
      expect(page).to have_title todo_todos

      visit users_path
      expect(page).to have_title users

      visit logins_path
      expect(page).to have_title login_logins
    end

    it "signed out" do
      visit transactions_path
      expect(page).to have_title sign_in

      visit uploads_path
      expect(page).to have_title sign_in

      visit new_upload_path
      expect(page).to have_title sign_in

      visit todos_path
      expect(page).to have_title sign_in

      visit elm_todos_path
      expect(page).to have_title sign_in

      visit users_path
      expect(page).to have_title sign_in

      visit logins_path
      expect(page).to have_title sign_in
    end
  end
end
