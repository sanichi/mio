shared_context "test_data" do
  let(:error) { "div.help-block" }

  let(:amount)      { I18n.t("amount") }
  let(:date)        { I18n.t("date") }
  let(:delete)      { I18n.t("delete") }
  let(:description) { I18n.t("description") }
  let(:edit)        { I18n.t("edit") }
  let(:email)       { I18n.t("email") }
  let(:name)        { I18n.t("name") }
  let(:none)        { I18n.t("none") }
  let(:save)        { I18n.t("save") }

  let(:password) { I18n.t("session.password") }
  let(:sign_in)  { I18n.t("session.sign_in") }
  let(:sign_out) { I18n.t("session.sign_out") }

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

  let(:fund_annual_fee)      { I18n.t("fund.annual_fee") }
  let(:edit_fund)            { I18n.t("fund.edit") }
  let(:fund_category)        { I18n.t("fund.category.category") }
  let(:fund_company)         { I18n.t("fund.company") }
  let(:fund_performance_fee) { I18n.t("fund.performance_fee") }
  let(:fund_srri)            { I18n.t("fund.srri") }
  let(:fund_srri_estimated)  { I18n.t("fund.srri_estimated") }
  let(:fund_sector)          { I18n.t("fund.sector") }
  let(:fund_size)            { I18n.t("fund.size") }
  let(:fund_stars)           { I18n.t("fund.stars.stars") }
  let(:funds)                { I18n.t("fund.funds") }
  let(:new_fund)             { I18n.t("fund.new") }

  let(:comment_source) { I18n.t("comment.source") }
  let(:comment_text)   { I18n.t("comment.text") }
  let(:edit_comment)   { I18n.t("comment.edit") }
  let(:new_comment)    { I18n.t("comment.new") }

  let(:return_percent) { I18n.t("return.percent") }
  let(:return_year)    { I18n.t("return.year") }
  let(:edit_return)    { I18n.t("return.edit") }
  let(:new_return)     { I18n.t("return.new") }

  let(:edit_user) { I18n.t("user.edit") }
  let(:new_user)  { I18n.t("user.new") }
  let(:user_role) { I18n.t("user.role") }
  let(:users)     { I18n.t("user.users") }

  let(:edit_person)         { I18n.t("person.edit") }
  let(:new_person)          { I18n.t("person.new") }
  let(:people)              { I18n.t("person.people") }
  let(:person_born)         { I18n.t("person.born") }
  let(:person_born_guess)   { I18n.t("person.born_guess") }
  let(:person_died)         { I18n.t("person.died") }
  let(:person_died_guess)   { I18n.t("person.died_guess") }
  let(:person_father)       { I18n.t("person.father") }
  let(:person_female)       { I18n.t("person.male") }
  let(:person_first_names)  { I18n.t("person.first_names") }
  let(:person_gender)       { I18n.t("person.gender") }
  let(:person_known_as)     { I18n.t("person.known_as") }
  let(:person_last_name)    { I18n.t("person.last_name") }
  let(:person_married_name) { I18n.t("person.married_name") }
  let(:person_male)         { I18n.t("person.male") }
  let(:person_mother)       { I18n.t("person.mother") }
  let(:person_notes)        { I18n.t("person.notes") }
  let(:person_person)       { I18n.t("person.person") }

  let(:edit_picture)     { I18n.t("picture.edit") }
  let(:new_picture)      { I18n.t("picture.new") }
  let(:pictures)         { I18n.t("picture.pictures") }
  let(:picture_file)     { I18n.t("picture.file") }
  let(:picture_portrait) { I18n.t("picture.portrait") }

  let(:edit_partnership)     { I18n.t("partnership.edit") }
  let(:partnership_divorce)  { I18n.t("partnership.divorce") }
  let(:partnership_husband)  { I18n.t("partnership.husband") }
  let(:partnership_marriage) { I18n.t("partnership.marriage") }
  let(:partnership_wedding)  { I18n.t("partnership.wedding") }
  let(:partnership_wife)     { I18n.t("partnership.wife") }
  let(:partnership_singular) { I18n.t("partnership.partnership") }
  let(:partnerships)         { I18n.t("partnership.partnerships") }
  let(:new_partnership)      { I18n.t("partnership.new") }

  let(:new_todo)        { I18n.t("todo.new") }
  let(:todo_done)       { I18n.t("todo.done") }
  let(:todo_priority)   { I18n.t("todo.priority") }
  let(:todo_priorities) { I18n.t("todo.priorities") }
  let(:todo_rails)      { I18n.t("todo.rails") }
  let(:todo_todo)       { I18n.t("todo.todo") }
  let(:todo_todos)      { I18n.t("todo.todos") }

  let(:todo_elm)         { I18n.t("todo.elm.app") }
  let(:todo_elm_cancel)  { I18n.t("todo.elm.cancel") }
  let(:todo_elm_confirm) { I18n.t("todo.elm.confirm") }
  let(:todo_elm_delete)  { I18n.t("todo.elm.delete") }
  let(:todo_elm_done)    { I18n.t("todo.elm.done") }
  let(:todo_elm_down)    { I18n.t("todo.elm.down") }
  let(:todo_elm_up)      { I18n.t("todo.elm.up") }
end
