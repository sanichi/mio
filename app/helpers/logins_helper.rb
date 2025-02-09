module LoginsHelper
  def login_success_menu(success)
    opts = [[t("symbol.tick") + t("symbol.cross"), ""], [t("symbol.tick"), "true"], [t("symbol.cross"), "false"]]
    options_for_select(opts, success)
  end
end
