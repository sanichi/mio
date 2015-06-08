require 'rails_helper'

describe User do
  include_context "test_data"

  let(:atrs) { attributes_for(:user) }
  let(:data) { build(:user) }
  let(:role) { I18n.t("user.roles.#{data.role}") }

  let(:error) { "div.help-block" }

  before(:each) do
    login
    click_link users
  end

  context "create" do
    it "success" do
      click_link new_user
      fill_in email, with: data.email
      fill_in password, with: data.password
      select role, from: user_role
      click_button save

      expect(page).to have_title data.email

      expect(User.count).to eq 2
      u = User.last

      expect(u.email).to eq data.email
      expect(u.encrypted_password).to eq Digest::MD5.hexdigest(data.password)
      expect(u.person_id).to be_nil
      expect(u.role).to eq data.role
    end
  end

  context "failure" do
    let!(:user) { create(:user) }

    it "no password" do
      click_link new_user
      fill_in email, with: data.email
      select role, from: user_role
      click_button save

      expect(page).to have_title new_user
      expect(User.count).to eq 2
      expect(page).to have_css(error, text: "blank")
    end

    it "duplicate email" do
      click_link new_user
      fill_in email, with: user.email
      fill_in password, with: data.password
      select role, from: user_role
      click_button save

      expect(page).to have_title new_user
      expect(User.count).to eq 2
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    let(:user) { create(:user) }

    it "password" do
      visit user_path(user)
      click_link edit
      
      new_password = user.password.reverse

      expect(page).to have_title edit_user
      fill_in password, with: new_password
      click_button save

      expect(page).to have_title user.email

      expect(User.count).to eq 2
      u = User.last

      expect(u.encrypted_password).to eq Digest::MD5.hexdigest(new_password)
    end

    it "role" do
      visit user_path(user)
      click_link edit
      new_role = User::ROLES.select{ |r| r != role }.sample

      expect(page).to have_title edit_user
      select I18n.t("user.roles.#{new_role}"), from: user_role
      click_button save

      expect(page).to have_title user.email

      expect(User.count).to eq 2
      u = User.last

      expect(u.encrypted_password).to eq Digest::MD5.hexdigest(user.password)
      expect(u.role).to eq new_role
    end
  end

  context "delete" do
    let!(:user) { create(:user) }

    it "success" do
      visit user_path(user)
      click_link edit
      click_link delete

      expect(page).to have_title users
      expect(User.count).to eq 1
    end
  end
end
