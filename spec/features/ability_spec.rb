require 'rails_helper'

describe Ability do
  include_context "test_data"

  let(:title) { "//h1[.='%s']" }
  let(:table) { "//table/tbody/tr[td[.='%s'] and td[.='%s'] and td[.='%s']]" }
  let(:error) { "div.help-block" }

  context Mass do
    let(:record) { create(:mass) }

    context "signed out" do
      it "index" do
        visit masses_path
        expect(page).to have_title measurements
      end

      it "graph" do
        visit graph_masses_path
        expect(page).to have_title measurements
      end

      it "new" do
        visit new_mass_path
        expect(page).to have_title sign_in
      end

      it "edit" do
        visit edit_mass_path(record)
        expect(page).to have_title sign_in
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "new" do
        visit new_mass_path
        expect(page).to have_title new_measurement
      end

      it "edit" do
        visit edit_mass_path(record)
        expect(page).to have_title edit_measurement
      end
    end
  end

  context Upload do
    let(:record) { create(:upload) }

    context "signed out" do
      it "index" do
        visit uploads_path
        expect(page).to have_title sign_in
      end

      it "show" do
        visit upload_path(record)
        expect(page).to have_title sign_in
      end

      it "new" do
        visit new_upload_path
        expect(page).to have_title sign_in
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "index" do
        visit uploads_path
        expect(page).to have_title uploads
      end

      it "show" do
        visit upload_path(record)
        expect(page).to have_title upload
      end

      it "new" do
        visit new_upload_path
        expect(page).to have_title new_upload
      end
    end
  end

  context Transaction do
    let(:record) { create(:transaction) }

    context "signed out" do
      it "index" do
        visit transactions_path
        expect(page).to have_title sign_in
      end

      it "summary" do
        visit summary_transactions_path
        expect(page).to have_title sign_in
      end

      it "show" do
        visit transaction_path(record)
        expect(page).to have_title sign_in
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "index" do
        visit transactions_path
        expect(page).to have_title transactions
      end

      it "summary" do
        visit summary_transactions_path
        expect(page).to have_title summary
      end

      it "show" do
        visit transaction_path(record)
        expect(page).to have_title transaction
      end
    end
  end
end
