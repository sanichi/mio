shared_context "test_data" do
  let(:transactions) { I18n.t("transaction.transactions") }

  let(:delete) { I18n.t("delete") }
  let(:name)   { I18n.t("name") }

  let(:file_upload) { I18n.t("upload.file") }
  let(:load)        { I18n.t("upload.load") }
  let(:new_upload)  { I18n.t("upload.new") }
  let(:upload)      { I18n.t("upload.upload") }
  let(:uploads)     { I18n.t("upload.uploads") }

  let(:sign_in)  { I18n.t("session.sign_in") }
  let(:sign_out) { I18n.t("session.sign_out") }
  let(:password) { I18n.t("session.password") }

  let(:test_password) { "birdman" }
end
