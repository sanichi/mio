shared_context "test_data" do
  let(:delete) { I18n.t("delete") }
  let(:edit)   { I18n.t("edit") }
  let(:name)   { I18n.t("name") }
  let(:save)   { I18n.t("save") }

  let(:sign_in)  { I18n.t("session.sign_in") }
  let(:sign_out) { I18n.t("session.sign_out") }
  let(:password) { I18n.t("session.password") }

  let(:test_password) { "birdman" }

  let(:file_upload) { I18n.t("hl.upload.file") }
  let(:load)        { I18n.t("hl.upload.load") }
  let(:new_upload)  { I18n.t("hl.upload.new") }
  let(:upload)      { I18n.t("hl.upload.upload") }
  let(:uploads)     { I18n.t("hl.upload.uploads") }

  let(:transactions) { I18n.t("hl.transaction.transactions") }

  let(:edit_measurement)   { I18n.t("kg.edit") }
  let(:new_measurement)    { I18n.t("kg.new") }
  let(:measurement_date)   { I18n.t("kg.date") }
  let(:measurement_finish) { I18n.t("kg.finish") }
  let(:measurement_list)   { I18n.t("kg.index") }
  let(:measurement_start)  { I18n.t("kg.start") }
  let(:measurements)       { I18n.t("kg.data") }
end
