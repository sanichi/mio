require 'rails_helper'

describe String do
  it "converts hiragana correctly" do
    expect("あ".shift_row("i")).to eq "い"
    expect("お".shift_row("e")).to eq "え"
    expect("げ".shift_row("a")).to eq "が"
    expect("が".shift_row("e")).to eq "げ"
    expect("ゆ".shift_row("o")).to eq "よ"
    expect("びゃ".shift_row("o")).to eq "びょ"
    expect("しゅ".shift_row("a")).to eq "しゃ"
  end

  it "handles tricky conversion cases correctly" do
    expect("つ".shift_row("i")).to eq "ち"
    expect("つ".shift_row("o")).to eq "と"
    expect("ち".shift_row("u")).to eq "つ"
    expect("ち".shift_row("a")).to eq "た"
    expect("ふ".shift_row("e")).to eq "へ"
    expect("ひ".shift_row("u")).to eq "ふ"
  end

  it "ignores inappropriate conversion input" do
    expect("a".shift_row("i")).to eq "a"
    expect("ん".shift_row("e")).to eq "ん"
    expect("グ".shift_row("a")).to eq "グ"
    expect("お".shift_row("o")).to eq "お"
  end

  it "detects correct row correctly" do
    expect("あ".is_row?("a")).to be true
    expect("お".is_row?("o")).to be true
    expect("げ".is_row?("e")).to be true
    expect("が".is_row?("a")).to eq true
    expect("ゆ".is_row?("u")).to eq true
    expect("ち".is_row?("i")).to eq true
  end

  it "detects incorrect row correctly" do
    expect("あ".is_row?("o")).to be false
    expect("お".is_row?("i")).to be false
    expect("げ".is_row?("u")).to be false
    expect("が".is_row?("e")).to eq false
    expect("ゆ".is_row?("a")).to eq false
    expect("ち".is_row?("o")).to eq false
  end

  it "deals with inappropriate detection input" do
    expect("あ".is_row?("x")).to be false
    expect("o".is_row?("o")).to be false
  end
end
