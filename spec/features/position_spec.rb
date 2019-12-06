require 'rails_helper'

describe Position do
  let(:data)      { build(:position, opening: opening) }
  let!(:position) { create(:ending) }
  let!(:opening)  { create(:opening) }

  before(:each) do
    login
    click_link t("position.positions")
  end

  context "create" do
    it "success" do
      click_link t("position.new")
      fill_in t("name"), with: data.name
      fill_in t("position.pieces"), with: data.pieces
      select data.active == "w" ? t("position.white") : t("position.black"), from: t("position.active")
      fill_in t("position.castling"), with: data.castling
      fill_in t("position.en_passant"), with: data.en_passant
      fill_in t("position.half_move"), with: data.half_move
      fill_in t("position.move"), with: data.move
      select data.opening.desc, from: t("opening.opening")
      fill_in t("position.opening_365"), with: data.opening_365
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title data.name

      expect(Position.count).to eq 2
      p = Position.last

      expect(p.name).to eq data.name
      expect(p.pieces).to eq data.pieces
      expect(p.active).to eq data.active
      expect(p.castling).to eq data.castling
      expect(p.en_passant).to eq data.en_passant
      expect(p.half_move).to eq data.half_move
      expect(p.last_reviewed).to be_nil
      expect(p.move).to eq data.move
      expect(p.opening).to eq data.opening
      expect(p.opening_365).to eq data.opening_365
      expect(p.notes).to eq data.notes
    end

    it "failure" do
      click_link t("position.new")
      fill_in t("position.pieces"), with: data.pieces
      select data.active == "w" ? t("position.white") : t("position.black"), from: t("position.active")
      fill_in t("position.castling"), with: data.castling
      fill_in t("position.en_passant"), with: data.en_passant
      fill_in t("position.half_move"), with: data.half_move
      fill_in t("position.move"), with: data.move
      select data.opening.desc, from: t("opening.opening")
      fill_in t("position.opening_365"), with: data.opening_365
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title t("position.new")
      expect(Position.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    context "success" do
      it "name and opening" do
        click_link position.name
        click_link t("edit")

        expect(page).to have_title t("position.edit")
        fill_in t("name"), with: data.name
        select t("none"), from: t("opening.opening")
        click_button t("save")

        expect(page).to have_title data.name

        expect(Position.count).to eq 1
        p = Position.last

        expect(p.name).to eq data.name
        expect(p.opening_id).to be_nil
        expect(p.last_reviewed).to be_nil
      end

      it "last_reviewed" do
        click_link position.name
        click_link t("edit")

        expect(page).to have_title t("position.edit")
        check t("position.reviewed_today")
        click_button t("save")

        expect(page).to have_title position.name

        expect(Position.count).to eq 1
        p = Position.last

        expect(p.last_reviewed).to eq Date.today
      end
    end

    it "failure" do
      click_link position.name
      click_link t("edit")

      fill_in t("position.pieces"), with: data.pieces + "rubbish"
      click_button t("save")

      expect(page).to have_title t("position.edit")
      expect(Position.count).to eq 1
    end
  end

  context "delete" do
    it "success" do
      expect(Position.count).to eq 1

      click_link position.name
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("position.positions")
      expect(Position.count).to eq 0
    end
  end
end
