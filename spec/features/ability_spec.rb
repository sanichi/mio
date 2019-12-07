require 'rails_helper'

describe Ability do
  let(:title) { "//h1[.='%s']" }
  let(:table) { "//table/tbody/tr[td[.='%s'] and td[.='%s'] and td[.='%s']]" }

  context Mass do
    let(:record) { create(:mass) }

    context "signed out" do
      it "index" do
        visit masses_path
        expect(page).to have_title t("mass.data")
      end

      it "graph" do
        visit graph_masses_path
        expect(page).to have_title t("mass.data")
      end

      it "new" do
        visit new_mass_path
        expect(page).to have_title t("session.sign_in")
      end

      it "edit" do
        visit edit_mass_path(record)
        expect(page).to have_title t("session.sign_in")
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "new" do
        visit new_mass_path
        expect(page).to have_title t("mass.new")
      end

      it "edit" do
        visit edit_mass_path(record)
        expect(page).to have_title t("mass.edit")
      end
    end
  end
end
