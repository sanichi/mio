shared_context "test_data" do
  let(:amount)      { I18n.t("amount") }
  let(:delete)      { I18n.t("delete") }
  let(:description) { I18n.t("description") }
  let(:edit)        { I18n.t("edit") }
  let(:name)        { I18n.t("name") }
  let(:save)        { I18n.t("save") }

  let(:password) { I18n.t("session.password") }
  let(:sign_in)  { I18n.t("session.sign_in") }
  let(:sign_out) { I18n.t("session.sign_out") }

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
  let(:transaction)  { I18n.t("transaction.transaction") }
  let(:transactions) { I18n.t("transaction.transactions") }

  let(:edit_measurement)   { I18n.t("mass.edit") }
  let(:mass)               { I18n.t("mass.mass") }
  let(:measurement_date)   { I18n.t("mass.date") }
  let(:measurement_finish) { I18n.t("mass.finish") }
  let(:measurement_start)  { I18n.t("mass.start") }
  let(:measurements)       { I18n.t("mass.data") }
  let(:new_measurement)    { I18n.t("mass.new") }

  let(:edit_expense)     { I18n.t("expense.edit") }
  let(:expense_category) { I18n.t("expense.category.category") }
  let(:expense_period)   { I18n.t("expense.period.period") }
  let(:expenses)         { I18n.t("expense.expenses") }
  let(:new_expense)      { I18n.t("expense.new") }

  let(:edit_income)     { I18n.t("income.edit") }
  let(:income_category) { I18n.t("income.category.category") }
  let(:income_finish)   { I18n.t("income.finish") }
  let(:income_period)   { I18n.t("income.period.period") }
  let(:income_start)    { I18n.t("income.start") }
  let(:incomes)         { I18n.t("income.incomes") }
  let(:joint)           { I18n.t("income.joint") }
  let(:new_income)      { I18n.t("income.new") }
end
