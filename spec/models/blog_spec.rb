require 'rails_helper'

describe Blog do
  let(:long1)  { create(:blog, story: "Para1\n\nPara2", title: "Title") }
  let(:long2)  { create(:blog, story: "\n\n\n  Para1 \n\t\n\n \n Para2\n\t ", title: "\t Title\t") }
  let(:short1) { create(:blog, story: "\n\nPara1\n \t\n") }
  let(:short2) { create(:blog, story: "Sent1\nSent2") }

  it "normalisation" do
    expect(long1.title).to eq "Title"
    expect(long1.story).to eq "Para1\n\nPara2"
    expect(long2.title).to eq "Title"
    expect(long2.story).to eq "Para1\n\nPara2"
    expect(short1.story).to eq "Para1"
    expect(short2.story).to eq "Sent1\nSent2"
  end

  it "#first_paragraph" do
    expect(long1.first_paragraph).to eq "Para1"
    expect(long2.first_paragraph).to eq "Para1"
    expect(short1.first_paragraph).to eq "Para1"
    expect(short2.first_paragraph).to eq "Sent1\nSent2"
  end

  it "#paragraphs" do
    expect(long1.paragraphs).to eq 2
    expect(long2.paragraphs).to eq 2
    expect(short1.paragraphs).to eq 1
    expect(short2.paragraphs).to eq 1
  end
end
