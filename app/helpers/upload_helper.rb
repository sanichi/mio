module UploadHelper
  def upload_account_menu(upload)
    accs = Upload::ACCOUNTS.map { |acc| [t("upload.account.#{acc}"), acc] }
    accs.unshift [t("select"), ""] if upload.new_record?
    options_for_select(accs, upload.account)
  end
end
