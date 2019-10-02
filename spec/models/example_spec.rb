require 'rails_helper'

describe Wk::Example do
  let!(:jr) { create(:wk_vocab, characters: "和食") }
  let!(:sc) { create(:wk_vocab, characters: "割り箸") }
  let!(:h1) { create(:wk_vocab, characters: "家") }
  let!(:h2) { create(:wk_vocab, characters: "自宅") }
  let!(:gh) { create(:wk_vocab, characters: "帰る") }

  let(:japanese1) { "{和食}のレストランへ{行く}たびに、{割り箸}を{家}へもって{帰ります|帰る}" }
  let(:japanese2) { "和食のレストランへ{行く}たびに、{割り箸}を{自宅}へもって{帰ります}" }
  let(:japanese3) { "{僕}は{うち|家}に{帰る}" }

  context "associations" do
    it "before" do
      expect(jr.examples).to be_empty
      expect(gh.examples).to be_empty
      expect(sc.examples).to be_empty
      expect(h1.examples).to be_empty
      expect(h2.examples).to be_empty
    end

    it "create" do
      e = create(:wk_example, japanese: japanese1)

      expect(e.vocabs.size).to eq 4
      expect(e.vocabs).to include(jr)
      expect(e.vocabs).to include(sc)
      expect(e.vocabs).to include(h1)
      expect(e.vocabs).to include(gh)
      expect(jr.examples.size).to eq 1
      expect(jr.examples).to include(e)
      expect(sc.examples.size).to eq 1
      expect(sc.examples).to include(e)
      expect(h1.examples.size).to eq 1
      expect(h1.examples).to include(e)
      expect(h2.examples.size).to eq 0
      expect(gh.examples.size).to eq 1
      expect(gh.examples).to include(e)
    end

    it "update" do
      e = create(:wk_example, japanese: japanese1)
      e.update!(japanese: japanese2)

      expect(e.vocabs.size).to eq 2
      expect(e.vocabs).to include(sc)
      expect(e.vocabs).to include(h2)
      expect(jr.examples.size).to eq 0
      expect(sc.examples.size).to eq 1
      expect(sc.examples).to include(e)
      expect(h2.examples.size).to eq 1
      expect(h2.examples).to include(e)
      expect(h1.examples.size).to eq 0
      expect(gh.examples.size).to eq 0
    end

    it "another" do
      e1 = create(:wk_example, japanese: japanese1)
      e2 = create(:wk_example, japanese: japanese3)

      expect(e1.vocabs.size).to eq 4
      expect(e2.vocabs.size).to eq 2
      expect(jr.examples.size).to eq 1
      expect(jr.examples).to include(e1)
      expect(sc.examples.size).to eq 1
      expect(sc.examples).to include(e1)
      expect(h1.examples.size).to eq 2
      expect(h1.examples).to include(e1)
      expect(h1.examples).to include(e2)
      expect(h2.examples.size).to eq 0
      expect(gh.examples.size).to eq 2
      expect(gh.examples).to include(e1)
      expect(gh.examples).to include(e2)
    end
  end

  context "#japanese_markdown" do
    let(:example) { create(:wk_example, japanese: japanese3) }

    it "no bold" do
      expect(example.japanese_markdown).to eq "{僕}は[うち](/wk/vocabs/家)に[帰る](/wk/vocabs/帰る)"
    end

    it "bold characters" do
      expect(example.japanese_markdown(bold: "帰る")).to eq "{僕}は[うち](/wk/vocabs/家)に**帰る**"
    end

    it "bold display" do
      expect(example.japanese_markdown(bold: "家")).to eq "{僕}は**うち**に[帰る](/wk/vocabs/帰る)"
    end
  end
end
