require 'rails_helper'

describe Wordle do
  it "it has a list of unique 5-letter, lower case words" do
    expect(Wordle::LIST).to be_a Array
    expect(Wordle::LIST.length).to be > 2300
    expect(Wordle::LIST.length).to be < 2350
    expect(Wordle::LIST.length).to eq Wordle::TOTAL
    expect(Wordle::LIST.select{|w| w.is_a?(String)}.length).to eq Wordle::TOTAL
    expect(Wordle::LIST.select{|w| w.match?(/\A[a-z]{5}\z/)}.length).to eq Wordle::TOTAL
    expect(Wordle::LIST.uniq.length).to eq Wordle::TOTAL
  end
end
