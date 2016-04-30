require 'rails_helper'

describe Position do
  let(:data)      { build(:position) }
  let!(:position) { create(:ending) }

  before(:each) do
    login
    click_link t(:position_positions)
  end

  context "create" do
    it "success" do
      click_link t(:position_new)
      fill_in t(:name), with: data.name
      fill_in t(:position_pieces), with: data.pieces
      select data.active == "w" ? t(:position_white) : t(:position_black), from: t(:position_active)
      fill_in t(:position_castling), with: data.castling
      fill_in t(:position_en__passant), with: data.en_passant
      fill_in t(:position_half__move), with: data.half_move
      fill_in t(:position_move), with: data.move
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title data.name

      expect(Position.count).to eq 2
      p = Position.last

      expect(p.name).to eq data.name
      expect(p.pieces).to eq data.pieces
      expect(p.active).to eq data.active
      expect(p.castling).to eq data.castling
      expect(p.en_passant).to eq data.en_passant
      expect(p.half_move).to eq data.half_move
      expect(p.move).to eq data.move
      expect(p.notes).to eq data.notes
    end

    it "failure" do
      click_link t(:position_new)
      fill_in t(:position_pieces), with: data.pieces
      select data.active == "w" ? t(:position_white) : t(:position_black), from: t(:position_active)
      fill_in t(:position_castling), with: data.castling
      fill_in t(:position_en__passant), with: data.en_passant
      fill_in t(:position_half__move), with: data.half_move
      fill_in t(:position_move), with: data.move
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:position_new)
      expect(Position.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link position.name
      click_link t(:edit)

      expect(page).to have_title t(:position_edit)
      fill_in t(:name), with: data.name
      click_button t(:save)

      expect(page).to have_title data.name

      expect(Position.count).to eq 1
      p = Position.last

      expect(p.name).to eq data.name
    end

    it "failure" do
      click_link position.name
      click_link t(:edit)

      fill_in t(:position_pieces), with: data.pieces + "rubbish"
      click_button t(:save)

      expect(page).to have_title t(:position_edit)
      expect(Position.count).to eq 1
    end
  end

  context "delete" do
    it "success" do
      expect(Position.count).to eq 1

      click_link position.name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:position_positions)
      expect(Position.count).to eq 0
    end
  end
end
