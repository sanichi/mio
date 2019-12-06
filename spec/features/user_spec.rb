require 'rails_helper'

describe User do
  let(:atrs) { attributes_for(:user) }
  let(:data) { build(:user) }
  let(:role) { I18n.t("user.roles.#{data.role}") }

  before(:each) do
    login
    click_link t("user.users")
  end

  context "create" do
    it "success" do
      click_link t("user.new")
      fill_in t("email"), with: data.email
      fill_in t("session.password"), with: data.password
      select role, from: t("user.role")
      click_button t("save")

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
      click_link t("user.new")
      fill_in t("email"), with: data.email
      select role, from: t("user.role")
      click_button t("save")

      expect(page).to have_title t("user.new")
      expect(User.count).to eq 2
      expect(page).to have_css(error, text: "blank")
    end

    it "duplicate email" do
      click_link t("user.new")
      fill_in t("email"), with: user.email
      fill_in t("session.password"), with: data.password
      select role, from: t("user.role")
      click_button t("save")

      expect(page).to have_title t("user.new")
      expect(User.count).to eq 2
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    let(:user) { create(:user) }

    it "password" do
      visit user_path(user)
      click_link t("edit")

      new_password = user.password.reverse

      expect(page).to have_title t("user.edit")
      fill_in t("session.password"), with: new_password
      click_button t("save")

      expect(page).to have_title user.email

      expect(User.count).to eq 2
      u = User.last

      expect(u.encrypted_password).to eq Digest::MD5.hexdigest(new_password)
    end

    it "role" do
      visit user_path(user)
      click_link t("edit")
      new_role = User::ROLES.select{ |r| r != role }.sample

      expect(page).to have_title t("user.edit")
      select I18n.t("user.roles.#{new_role}"), from: t("user.role")
      click_button t("save")

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
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("user.users")
      expect(User.count).to eq 1
    end
  end
end
