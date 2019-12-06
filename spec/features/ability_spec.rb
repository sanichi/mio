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

  context Upload do
    let(:record) { create(:upload) }

    context "signed out" do
      it "index" do
        visit uploads_path
        expect(page).to have_title t("session.sign_in")
      end

      it "show" do
        visit upload_path(record)
        expect(page).to have_title t("session.sign_in")
      end

      it "new" do
        visit new_upload_path
        expect(page).to have_title t("session.sign_in")
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "index" do
        visit uploads_path
        expect(page).to have_title t("upload.uploads")
      end

      it "show" do
        visit upload_path(record)
        expect(page).to have_title t("upload.upload")
      end

      it "new" do
        visit new_upload_path
        expect(page).to have_title t("upload.new")
      end
    end
  end

  context Transaction do
    let(:record) { create(:transaction) }

    context "signed out" do
      it "index" do
        visit transactions_path
        expect(page).to have_title t("session.sign_in")
      end

      it "summary" do
        visit summary_transactions_path
        expect(page).to have_title t("session.sign_in")
      end

      it "show" do
        visit transaction_path(record)
        expect(page).to have_title t("session.sign_in")
      end
    end

    context "signed in" do
      before(:each) do
        login
      end

      it "index" do
        visit transactions_path
        expect(page).to have_title t("transaction.transactions")
      end

      it "summary" do
        visit summary_transactions_path
        expect(page).to have_title t("transaction.summary")
      end

      it "show" do
        visit transaction_path(record)
        expect(page).to have_title t("transaction.transaction")
      end
    end
  end
end
