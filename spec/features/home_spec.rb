require 'rails_helper'

describe "Pages" do
  context "Home" do
    it "root" do
      visit "/"
      expect(page).to have_css("p", text: I18n.t("mio"))
    end

    it "home" do
      visit "/home"
      expect(page).to have_css("p", text: I18n.t("mio"))
    end
  end
end
