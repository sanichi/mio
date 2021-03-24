require 'rails_helper'

describe Test do
  let!(:p1) { create(:place, category: "prefecture") }
  let!(:p2) { create(:place, category: "prefecture") }
  let!(:b1) { create(:border, from: p1, to: p2) }
  let!(:b2) { create(:border, from: p2, to: p1) }
  let!(:e1) { create(:wk_example) }
  let!(:e2) { create(:wk_example) }

  it "session", js: true do
    expect(Test.count).to eq 6
    expect(Test.where(attempts: 0).count).to eq 6
    expect(Test.where(due: nil).count).to eq 6

    login
    click_link t("wk.japanese", locale: "jp")
    click_link t("test.tests")
    select t("test.order.new"), from: t("order")
    expect(page).to have_title t("test.tests")
    expect(page.all(:css, 'tbody#results tr').size).to eq TestHelper::DEFAULT + 1 # 1 extra for the next page controls

    click_link t("test.review")
    expect(page).to have_title t("test.review")

    click_button t("test.show")
    click_button t("test.answers.poor")
    expect(Test.where(attempts: 0).count).to eq 5
    expect(Test.where(last: "poor").count).to eq 1
    test = Test.find_by(last: "poor")
    expect(test.attempts).to eq 1
    expect(test.level).to eq Test::MIN_LEVEL
    expect(test.due).to_not be_nil

    click_button t("test.show")
    click_button t("test.answers.fair")
    expect(Test.where(attempts: 0).count).to eq 4
    expect(Test.where(last: "fair").count).to eq 1
    test = Test.find_by(last: "fair")
    expect(test.attempts).to eq 1
    expect(test.level).to eq Test::MIN_LEVEL
    expect(test.due).to_not be_nil

    click_button t("test.show")
    click_button t("test.answers.good")
    expect(Test.where(attempts: 0).count).to eq 3
    expect(Test.where(last: "good").count).to eq 1
    test = Test.find_by(last: "good")
    expect(test.attempts).to eq 1
    expect(test.level).to eq Test::MIN_LEVEL + 1
    expect(test.due).to_not be_nil

    click_button t("test.show")
    click_button t("test.answers.excellent")
    expect(Test.where(attempts: 0).count).to eq 2
    expect(Test.where(last: "excellent").count).to eq 1
    test = Test.find_by(last: "excellent")
    expect(test.attempts).to eq 1
    expect(test.level).to eq Test::MIN_LEVEL + 2
    expect(test.due).to_not be_nil

    click_button t("test.show")
    click_button t("test.answers.skip")
    expect(Test.where(attempts: 0).count).to eq 2
    expect(Test.where(last: "skip").count).to eq 1
    test = Test.find_by(last: "skip")
    expect(test.attempts).to eq 0
    expect(test.level).to eq Test::MIN_LEVEL
    expect(test.due).to be_nil

    expect(page).to_not have_selector(:link_or_button, t("test.show"))
    Test::ANSWERS.each do |a|
      expect(page).to_not have_selector(:link_or_button, t("test.answers.#{a}"))
    end
  end
end
