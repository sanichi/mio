shared_context "test_data" do
  let(:delete) { I18n.t("delete") }
  let(:edit)   { I18n.t("edit") }
  let(:name)   { I18n.t("name") }
  let(:save)   { I18n.t("save") }

  let(:sign_in)  { I18n.t("session.sign_in") }
  let(:sign_out) { I18n.t("session.sign_out") }
  let(:password) { I18n.t("session.password") }

  let(:test_password) { "birdman" }

  let(:account)     { I18n.t("upload.account.acc") }
  let(:capital)     { I18n.t("upload.account.cap") }
  let(:file_upload) { I18n.t("upload.file") }
  let(:income)      { I18n.t("upload.account.inc") }
  let(:load)        { I18n.t("upload.load") }
  let(:new_upload)  { I18n.t("upload.new") }
  let(:upload)      { I18n.t("upload.upload") }
  let(:uploads)     { I18n.t("upload.uploads") }

  let(:summary)      { I18n.t("transaction.summary") }
  let(:transactions) { I18n.t("transaction.transactions") }
  let(:transaction)  { I18n.t("transaction.transaction") }

  let(:edit_measurement)   { I18n.t("mass.edit") }
  let(:mass)               { I18n.t("mass.mass") }
  let(:new_measurement)    { I18n.t("mass.new") }
  let(:measurement_date)   { I18n.t("mass.date") }
  let(:measurement_finish) { I18n.t("mass.finish") }
  let(:measurement_start)  { I18n.t("mass.start") }
  let(:measurements)       { I18n.t("mass.data") }
end
