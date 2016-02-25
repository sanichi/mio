module ResidentHelper
  def resident_block_menu(resident)
    blk = (Resident::MIN_BLOCK..Resident::MAX_BLOCK).map { |b| [b, b] }
    blk.unshift [t("select"), ""] if resident.new_record?
    options_for_select(blk, resident.block)
  end

  def resident_flat_menu(resident)
    flt = (Resident::MIN_FLAT..Resident::MAX_FLAT).map { |f| [f, f] }
    flt.unshift [t("select"), ""] if resident.new_record?
    options_for_select(flt, resident.flat)
  end
end
