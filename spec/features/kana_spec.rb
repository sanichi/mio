require 'rails_helper'

describe Wk::Kana, js: true do
  before(:each) do
    login
    visit favourites_wk_kanas_path
  end

  context "stroke order" do
    it "from favourites and back" do
      click_link "ア"

      expect(page).to have_title "ア"
      %w[png gif].each do |ext|
        img = find("img[src='#{Wk::Kana.stroke_order_image('ア', ext)}']")
        expect(img.evaluate_script("this.complete && this.naturalWidth > 0")).to be true
      end

      click_link t("wk.kana.favourites")

      expect(page).to have_title t("wk.kana.favourites")
    end
  end
end
