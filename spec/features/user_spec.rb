require 'rails_helper'

describe User, js: true do
  let(:atrs) { attributes_for(:user) }
  let(:data) { build(:user) }
  let(:user) { create(:user) }
  let(:otpu) { create(:user, otp_required: true) }
  let(:role) { I18n.t("user.roles.#{data.role}") }

  context "admin" do
    before(:each) do
      login
      click_link t("other")
      click_link t("user.users")
    end

    context "create, login" do
      it "success" do
        click_link t("user.new")
        fill_in t("email"), with: data.email
        fill_in t("session.password"), with: data.password
        fill_in t("person.first_name"), with: data.first_name
        fill_in t("person.last_name"), with: data.last_name
        select role, from: t("user.role")
        uncheck t("otp.required")
        click_button t("save")

        expect(page).to have_title data.email

        expect(User.count).to eq 2
        a = User.first
        u = User.last

        expect(u.email).to eq data.email
        expect(u.first_name).to eq data.first_name
        expect(u.last_name).to eq data.last_name
        expect(u.role).to eq data.role
        expect(u.otp_required).to eq false
        expect(u.otp_secret).to be_nil
        expect(u.last_otp_at).to be_nil

        click_link(t("session.sign_out", user: a.initials))
        click_link(t("session.sign_in"))
        fill_in t("email"), with: data.email
        fill_in t("session.password"), with: data.password
        click_button t("session.sign_in")
        click_link(t("session.sign_out", user: u.initials))
      end
    end

    context "create, otp, login" do
      it "success" do
        click_link t("user.new")
        fill_in t("email"), with: data.email
        fill_in t("session.password"), with: data.password
        fill_in t("person.first_name"), with: data.first_name
        fill_in t("person.last_name"), with: data.last_name
        select role, from: t("user.role")
        check t("otp.required")
        click_button t("save")

        expect(page).to have_title data.email

        expect(User.count).to eq 2
        a = User.first
        u = User.last

        expect(u.email).to eq data.email
        expect(u.first_name).to eq data.first_name
        expect(u.last_name).to eq data.last_name
        expect(u.role).to eq data.role
        expect(u.otp_required).to eq true
        expect(u.otp_secret).to be_nil
        expect(u.last_otp_at).to be_nil

        click_link(t("session.sign_out", user: a.initials))
        click_link(t("session.sign_in"))
        fill_in t("email"), with: data.email
        fill_in t("session.password"), with: data.password
        click_button t("session.sign_in")

        expect(page).to have_title t("otp.new")
        expect(page).to have_css "p#su_code", text: User::OTP_TEST_SECRET

        fill_in t("otp.otp"), with: otp_attempt
        click_button t("otp.submit")
        click_link(t("session.sign_out", user: u.initials))
      end
    end

    context "failure" do
      let!(:user) { create(:user) }

      it "no password" do
        click_link t("user.new")
        fill_in t("email"), with: data.email
        fill_in t("person.first_name"), with: data.first_name
        fill_in t("person.last_name"), with: data.last_name
        select role, from: t("user.role")
        uncheck t("otp.required")
        click_button t("save")

        expect(page).to have_title t("user.new")
        expect(User.count).to eq 2
        expect_error(page, "blank")
      end

      it "duplicate email" do
        click_link t("user.new")
        fill_in t("email"), with: user.email
        fill_in t("session.password"), with: data.password
        fill_in t("person.first_name"), with: data.first_name
        fill_in t("person.last_name"), with: data.last_name
        select role, from: t("user.role")
        uncheck t("otp.required")
        click_button t("save")

        expect(page).to have_title t("user.new")
        expect(User.count).to eq 2
        expect_error(page, "taken")
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

        expect(u.role).to eq new_role
      end
    end

    context "delete" do
      let!(:user) { create(:user) }

      it "success" do
        visit user_path(user)
        click_link t("edit")
        accept_confirm do
          click_link t("delete")
        end

        expect(page).to have_title t("user.users")
        expect(User.count).to eq 1
      end
    end
  end

  context "user" do
    it "login" do
      visit sign_in_path
      click_link(t("session.sign_in"))
      fill_in t("email"), with: user.email
      fill_in t("session.password"), with: user.password
      click_button t("session.sign_in")

      expect(page).to_not have_title t("otp.challenge")

      click_link(t("session.sign_out", user: user.initials))
    end

    it "otp login" do
      visit sign_in_path
      click_link(t("session.sign_in"))
      fill_in t("email"), with: otpu.email
      fill_in t("session.password"), with: otpu.password
      click_button t("session.sign_in")

      expect(page).to have_title t("otp.challenge")
      expect(page).to_not have_link(t("session.sign_out", user: user.initials))

      fill_in t("otp.otp"), with: otp_attempt
      click_button t("otp.submit")

      expect(page).to_not have_title t("otp.challenge")
      click_link(t("session.sign_out", user: otpu.initials))
    end
  end
end
