module InterfaceHelper
  def interface_device_menu(interface)
    dev = Device.ordered.map { |d| [d.network_name, d.id] }
    dev.unshift [t("select"), ""]
    options_for_select(dev, interface.device_id)
  end
end
