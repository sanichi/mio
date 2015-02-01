require 'rails_helper'

describe Mass do
  include_context "test_data"

  let(:title) { "//h1[.='%s']" }
  let(:table) { "//table/tbody/tr[td[.='%s'] and td[.='%s'] and td[.='%s']]" }
  let(:error) { "div.help-block" }

  before(:each) do
    login
  end

  context "create" do
    let(:data)  { build(:mass) }

    it "success" do
      click_link new_measurement
      fill_in measurement_date, with: data.date
      fill_in measurement_start, with: data.start
      fill_in measurement_finish, with: data.finish
      click_button save

      expect(page).to have_xpath title % measurements
      expect(page).to have_xpath table % [data.date.to_s(:db), "%.1f" % data.start, "%.1f" % data.finish]

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start
      expect(m.finish).to eq data.finish
    end

    context "failure" do
      it "not enough" do
        click_link new_measurement
        fill_in measurement_date, with: data.date
        click_button save

        expect(page).to have_xpath title % new_measurement
        expect(Mass.count).to eq 0
        expect(page).to have_css(error, text: "at least 1")
      end

      it "out of range" do
        click_link new_measurement
        fill_in measurement_date, with: data.date
        fill_in measurement_start, with: data.start
        fill_in measurement_finish, with: Mass::MAX_KG + 10
        click_button save

        expect(page).to have_xpath title % new_measurement
        expect(Mass.count).to eq 0
        expect(page).to have_css(error, text: "must be less than")
      end

      it "no date" do
        click_link new_measurement
        fill_in measurement_date, with: ""
        fill_in measurement_start, with: data.start
        fill_in measurement_finish, with: data.finish
        click_button save

        expect(page).to have_xpath title % new_measurement
        expect(Mass.count).to eq 0
        expect(page).to have_css(error, text: "can't be blank")
      end
    end
  end

  context "edit" do
    let(:data)  { build(:mass) }
    let!(:mass) { create(:mass) }

    it "success" do
      click_link measurement_list
      click_link edit

      expect(page).to have_xpath title % edit_measurement
      fill_in measurement_start, with: data.start + 10
      fill_in measurement_finish, with: ""
      click_button save

      expect(page).to have_xpath title % measurements
      expect(page).to have_xpath table % [data.date.to_s(:db), "%.1f" % (data.start + 10), ""]

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start + 10
      expect(m.finish).to be_nil
    end
  end

  context "delete" do
    let!(:mass) { create(:mass) }

    it "success" do
      expect(Mass.count).to eq 1

      click_link measurement_list
      click_link delete

      expect(page).to have_xpath title % measurements
      expect(Mass.count).to eq 0
    end
  end
end
