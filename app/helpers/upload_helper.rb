module UploadHelper
  def upload_account_menu(selected)
    accs = Upload::ACCOUNTS.map { |acc| [t("upload.account.#{acc}"), acc] }
    accs.unshift [t("select"), ""]
    options_for_select(accs, selected)
  end
end
