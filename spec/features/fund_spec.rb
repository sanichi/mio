require 'rails_helper'

describe Fund do
  include_context "test_data"

  let(:data)     { build(:fund) }
  let(:category) { I18n.t("fund.category.#{data.category}") }

  let(:error) { "div.help-block" }

  before(:each) do
    login
    visit funds_path
  end

  context "create" do
    it "success" do
      click_link new_fund
      fill_in name, with: data.name
      fill_in fund_company, with: data.company
      select category, from: fund_category
      select data.sector, from: fund_sector
      fill_in fund_risk_reward_profile, with: data.risk_reward_profile
      fill_in fund_annual_fee, with: data.annual_fee
      check fund_performance_fee if data.performance_fee
      click_button save

      expect(page).to have_title funds

      expect(Fund.count).to eq 1
      f = Fund.first

      expect(f.annual_fee).to eq data.annual_fee
      expect(f.category).to eq data.category
      expect(f.company).to eq data.company
      expect(f.name).to eq data.name
      expect(f.risk_reward_profile).to eq data.risk_reward_profile
      expect(f.performance_fee).to eq data.performance_fee
      expect(f.sector).to eq data.sector
    end
  end

  context "failure" do
    it "no name" do
      click_link new_fund
      fill_in fund_company, with: data.company
      select category, from: fund_category
      select data.sector, from: fund_sector
      fill_in fund_risk_reward_profile, with: data.risk_reward_profile
      fill_in fund_annual_fee, with: data.annual_fee
      check fund_performance_fee if data.performance_fee
      click_button save

      expect(page).to have_title new_fund
      expect(Fund.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "invalid risk reward profile" do
      click_link new_fund
      fill_in name, with: data.name
      fill_in fund_company, with: data.company
      select category, from: fund_category
      select data.sector, from: fund_sector
      fill_in fund_risk_reward_profile, with: Fund::MAX_RRP + 1
      fill_in fund_annual_fee, with: data.annual_fee
      check fund_performance_fee if data.performance_fee
      click_button save

      expect(page).to have_title new_fund
      expect(Fund.count).to eq 0
      expect(page).to have_css(error, text: "less than")
    end
  end

  context "edit" do
    let!(:fund) { create(:fund, category: "it") }

    it "success" do
      visit fund_path(fund)
      click_link edit

      expect(page).to have_title edit_fund
      select category, from: fund_category
      click_button save

      expect(page).to have_title fund.name

      expect(Fund.count).to eq 1
      f = Fund.first

      expect(f.category).to eq data.category
    end
  end

  context "delete" do
    let!(:fund) { create(:fund) }

    it "success" do
      visit funds_path
      click_link edit
      click_link delete

      expect(page).to have_title funds
      expect(Fund.count).to eq 0
    end
  end

  context "comments" do
    let(:fund)  { create(:fund) }
    let(:data)  { build(:comment) }
    let(:data2) { build(:comment) }
    let(:data3) { build(:comment) }

    it "add, add another, edit, delete, delete all" do
      visit fund_path(fund)
      click_link new_comment
      expect(page).to have_title new_comment

      fill_in date, with: data.date
      fill_in comment_source, with: data.source
      fill_in comment_text, with: data.text
      click_button save
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.length).to eq 1
      comment = fund.comments.first
      expect(comment.date).to eq data.date
      expect(comment.source).to eq data.source
      expect(comment.text).to eq data.text

      click_link new_comment
      expect(page).to have_title new_comment

      fill_in date, with: data2.date
      fill_in comment_source, with: data2.source
      fill_in comment_text, with: data2.text
      click_button save
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.length).to eq 2

      first(".panel").click_link(edit)
      expect(page).to have_title edit_comment
      fill_in comment_text, with: data3.text
      click_button save
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.where(text: data3.text).count).to eq 1
      expect(fund.comments.length).to eq 2

      first(".panel").click_link(edit)
      click_link delete
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.where(text: data3.text).count).to eq 0
      expect(fund.comments.length).to eq 1

      click_link edit, match: :first
      expect(page).to have_title edit_fund

      click_link delete
      expect(page).to have_title funds

      expect(Fund.count).to eq 0
      expect(Comment.count).to eq 0
    end
  end
end
