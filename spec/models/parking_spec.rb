require 'rails_helper'

describe Parking do
  let!(:parking) { create(:parking) }

  it "destroyed by vehicle deletion" do
    expect{ parking.vehicle.destroy }.to change{ Parking.count }.by(-1)
  end
end
