require 'rails_helper'

describe Fund do
  let(:data)     { build(:fund) }
  let(:attrs)    { attributes_for(:fund) }
  let(:category) { I18n.t("fund.category.#{data.category}") }
  let(:stars)    { data.stars.map { |star| Fund.full_star(star) } }

  before(:each) do
    login
    visit funds_path
  end

  context "create" do
    it "success" do
      click_link t("fund.new")
      fill_in t("name"), with: data.name
      fill_in t("fund.company"), with: data.company
      select category, from: t("fund.category.category")
      select data.sector, from: t("fund.sector")
      stars.each { |star| select star, from: t("fund.stars.stars") }
      fill_in t("fund.size"), with: data.size
      select data.srri.to_s, from: t("fund.srri")
      check t("fund.srri_estimated") if data.srri_estimated
      fill_in t("fund.annual_fee"), with: data.annual_fee
      check t("fund.performance_fee") if data.performance_fee
      click_button t("save")

      expect(page).to have_title data.name

      expect(Fund.count).to eq 1
      f = Fund.first

      expect(f.annual_fee).to eq data.annual_fee
      expect(f.category).to eq data.category
      expect(f.company).to eq data.company
      expect(f.name).to eq data.name
      expect(f.size).to eq data.size
      expect(f.stars).to eq data.stars
      expect(f.srri).to eq data.srri
      expect(f.srri_estimated).to eq data.srri_estimated
      expect(f.performance_fee).to eq data.performance_fee
      expect(f.sector).to eq data.sector
    end
  end

  context "failure" do
    it "no name" do
      click_link t("fund.new")
      fill_in t("fund.company"), with: data.company
      select category, from: t("fund.category.category")
      select data.sector, from: t("fund.sector")
      stars.each { |star| select star, from: t("fund.stars.stars") }
      fill_in t("fund.size"), with: data.size
      select data.srri.to_s, from: t("fund.srri")
      check t("fund.srri_estimated") if data.srri_estimated
      fill_in t("fund.annual_fee"), with: data.annual_fee
      check t("fund.performance_fee") if data.performance_fee
      click_button t("save")

      expect(page).to have_title t("fund.new")
      expect(Fund.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "dulpicate name" do
      Fund.create(attrs)
      expect(Fund.count).to eq 1

      click_link t("fund.new")
      fill_in t("name"), with: data.name
      fill_in t("fund.company"), with: data.company
      select category, from: t("fund.category.category")
      select data.sector, from: t("fund.sector")
      stars.each { |star| select star, from: t("fund.stars.stars") }
      fill_in t("fund.size"), with: data.size
      select data.srri.to_s, from: t("fund.srri")
      check t("fund.srri_estimated") if data.srri_estimated
      fill_in t("fund.annual_fee"), with: data.annual_fee
      check t("fund.performance_fee") if data.performance_fee
      click_button t("save")

      expect(page).to have_title t("fund.new")
      expect(Fund.count).to eq 1
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    let(:fund) { create(:fund, category: "sicav", stars: ["hl_tracker", "rp_rated"]) }

    it "success" do
      visit fund_path(fund)
      click_link t("edit")

      expect(page).to have_title t("fund.edit")
      select category, from: t("fund.category.category")
      fund.stars.each { |star| unselect Fund.full_star(star), from: t("fund.stars.stars") }
      click_button t("save")

      expect(page).to have_title fund.name

      expect(Fund.count).to eq 1
      f = Fund.first

      expect(f.category).to eq data.category
      expect(f.stars).to be_empty
    end
  end

  context "delete" do
    let!(:fund) { create(:fund) }

    it "success" do
      visit funds_path
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("fund.funds")
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
      click_link t("comment.new")
      expect(page).to have_title t("comment.new")

      fill_in t("date"), with: data.date
      fill_in t("comment.source"), with: data.source
      fill_in t("comment.text"), with: data.text
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.length).to eq 1
      comment = fund.comments.first
      expect(comment.date).to eq data.date
      expect(comment.source).to eq data.source
      expect(comment.text).to eq data.text

      click_link t("comment.new")
      expect(page).to have_title t("comment.new")

      fill_in t("date"), with: data2.date
      fill_in t("comment.source"), with: data2.source
      fill_in t("comment.text"), with: data2.text
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.length).to eq 2

      first(".card").click_link(t(:edit))
      expect(page).to have_title t("comment.edit")
      fill_in t("comment.text"), with: data3.text
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.where(text: data3.text).count).to eq 1
      expect(fund.comments.length).to eq 2

      first(".card").click_link(t(:edit))
      click_link t("delete")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.comments.where(text: data3.text).count).to eq 0
      expect(fund.comments.length).to eq 1

      click_link t("edit"), match: :first
      expect(page).to have_title t("fund.edit")

      click_link t("delete")
      expect(page).to have_title t("fund.funds")

      expect(Fund.count).to eq 0
      expect(Comment.count).to eq 0
    end
  end

  context "returns" do
    let(:fund)  { create(:fund) }
    let(:data)  { build(:return) }
    let(:data2) { build(:return, year: data.year - 1) }
    let(:data3) { build(:return, year: data.year - 2, percent: 2 * data.percent) }

    it "add, add another, edit, delete, delete all" do
      visit fund_path(fund)
      click_link t("return.new")
      expect(page).to have_title t("return.new")

      fill_in t("return.year"), with: data.year
      fill_in t("return.percent"), with: data.percent
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.returns.length).to eq 1
      ret = fund.returns.first
      expect(ret.year).to eq data.year
      expect(ret.percent).to eq data.percent

      click_link t("return.new")
      expect(page).to have_title t("return.new")

      fill_in t("return.year"), with: data2.year
      fill_in t("return.percent"), with: data2.percent
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.returns.length).to eq 2

      first(:xpath, "//tr/td[a[contains(@href,'edit')]]").click_link(t(:edit))
      expect(page).to have_title t("return.edit")
      fill_in t("return.percent"), with: data3.percent
      click_button t("save")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.returns.where(percent: data3.percent).count).to eq 1
      expect(fund.returns.length).to eq 2

      first(:xpath, "//tr/td[a[contains(@href,'edit')]]").click_link(t(:edit))
      click_link t("delete")
      expect(page).to have_title fund.name

      fund.reload
      expect(fund.returns.where(percent: data3.percent).count).to eq 0
      expect(fund.returns.length).to eq 1

      click_link t("edit"), match: :first
      expect(page).to have_title t("fund.edit")

      click_link t("delete")
      expect(page).to have_title t("fund.funds")

      expect(Fund.count).to eq 0
      expect(Return.count).to eq 0
    end
  end
end
