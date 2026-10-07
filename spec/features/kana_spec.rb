require 'rails_helper'

describe Wk::Kana, js: true do
  before(:each) do
    login
    visit favourites_wk_kanas_path
  end

  def shown = all("img.compare-image").map { |i| CGI.unescape(File.basename(i[:src], ".png")) }

  context "stroke order" do
    it "from favourites and back" do
      click_link "ア"

      expect(page).to have_title "ア"
      %w[png gif].each do |ext|
        img = find("img[src='#{Wk::Kana.stroke_order_image('ア', ext)}']")
        expect(img.evaluate_script("this.complete && this.naturalWidth > 0")).to be true
      end

      click_link "イ"

      expect(page).to have_title "イ"

      click_link t("wk.kana.favourites")

      expect(page).to have_title t("wk.kana.favourites")
    end

    it "links to comparisons with similar kana" do
      kana = Wk::Kana::SIMILAR_PAIRS.first.first
      similar = Wk::Kana.similar_to(kana)

      click_link kana

      expect(page).to have_link count: similar.size, href: /compare/
      click_link similar.first, href: /compare/

      expect(page).to have_title t("wk.kana.compare_kana")
      expect(shown).to eq [kana, similar.first]
    end

    it "has no similar kana links when there are none" do
      kana = (Wk::Kana::FAVOURITES.keys - Wk::Kana::SIMILAR_PAIRS.flatten).first

      click_link kana

      expect(page).to have_title kana
      expect(page).to have_no_link href: /compare/
    end
  end

  context "compare" do
    it "shows the kana in the params and changes one without reloading" do
      visit compare_wk_kanas_path(left: "し", right: "ツ")

      expect(page).to have_title t("wk.kana.compare_kana")
      expect(shown).to eq %w[し ツ]

      select "tsu – つ", from: "right"

      expect(page).to have_css "img[src$='つ.png']"
      expect(shown).to eq %w[し つ]
      expect(current_url).to include "left=%E3%81%97&right=%E3%81%A4"
    end

    it "remembers the last choice and otherwise picks a similar pair" do
      visit compare_wk_kanas_path
      expect(Wk::Kana::SIMILAR_PAIRS.map(&:sort)).to include shown.sort

      visit compare_wk_kanas_path(left: "ソ", right: "ン")
      visit compare_wk_kanas_path

      expect(shown).to eq %w[ソ ン]
    end

    it "links each image to its stroke order page" do
      visit compare_wk_kanas_path(left: "し", right: "ツ")

      find("a[href='#{stroke_order_wk_kanas_path(kana: 'ツ')}']").click

      expect(page).to have_title "ツ"
      expect(page).to have_current_path stroke_order_wk_kanas_path(kana: "ツ")
    end

    it "is linked from the favourites page" do
      click_link t("wk.kana.compare_kana")

      expect(page).to have_title t("wk.kana.compare_kana")
    end
  end
end
