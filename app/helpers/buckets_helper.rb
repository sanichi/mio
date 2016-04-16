module BucketsHelper
  def bucket_fan_search_menu(fan)
    fans =
    [
      [t("any"), ""],
      [t("bucket.mark"),   "m"],
      [t("bucket.sandra"), "s"],
    ]
    options_for_select(fans, fan)
  end

  def bucket_level_menu(vote)
    levels = t("bucket.level").each_with_index.map { |v, i| [v, i] }
    options_for_select(levels, vote)
  end
end
