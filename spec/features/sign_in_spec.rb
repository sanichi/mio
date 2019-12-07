require 'rails_helper'

describe "Authentication" do
  let(:user) { create(:user) }

  context "sign in" do
    it "success" do
      visit root_path
      expect(page).to_not have_link t("session.sign_out")

      click_link t("session.sign_in")
      fill_in t("email"), with: user.email
      fill_in t("session.password"), with: user.password
      click_button t("session.sign_in")

      expect(page).to_not have_link t("session.sign_in")
      expect(page).to have_link t("session.sign_out")
    end

    it "failure" do
      visit root_path
      click_link t("session.sign_in")
      fill_in t("email"), with: user.email
      fill_in t("session.password"), with: "rubbish"
      click_button t("session.sign_in")

      expect(page).to have_link t("session.sign_in")
      expect(page).to_not have_link t("session.sign_out")
    end
  end

  context "access" do
    it "signed in" do
      login

      visit users_path
      expect(page).to have_title t("user.users")

      visit logins_path
      expect(page).to have_title t("login.logins")
    end

    it "signed out" do
      visit users_path
      expect(page).to have_title t("session.sign_in")

      visit logins_path
      expect(page).to have_title t("session.sign_in")
    end
  end
end
