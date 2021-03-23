module TestHelper
  NUMBERS = [1, 2, 5, 10]
  DEFAULT = NUMBERS[2]

  def test_number_menu(selected)
    opts = NUMBERS.map { |n| [n.to_s, n] }
    options_for_select(opts, selected)
  end

  def test_type_menu(selected)
    opts = %w/example place border/.map{ |t| [t("test.types.#{t}"), t] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def test_last_menu(selected)
    opts = Test::ANSWERS.map{ |l| [t("test.answers.#{l}"), l] }
    opts.unshift [t("all"), ""]
    options_for_select(opts, selected)
  end

  def test_order_menu(selected)
    opts = %w/due new level attempts/.map do |o|
      [o == "updated" ? t(o) : t("test.#{o}"), o]
    end
    Test::ANSWERS.each do |o|
      opts.push [t("test.answers.#{o}"), o] unless o == "skip"
    end
    options_for_select(opts, selected)
  end

  def test_type(test)
    case test.testable_type
    when "Wk::Example"
      t("test.types.example")
    when "Place"
      t("test.types.place")
    when "Border"
      t("test.types.border")
    else
      t("test.types.unknown")
    end
  end

  def test_due(time)
    return "" unless time.present?
    count = time.to_f - Time.now.to_f
    if count <= 0.0
      "now"
    else
      if count < 60.0
        "#{seconds.round}s"
      else
        count /= 60.0
        if count < 60.0
          "#{count.round}m"
        else
          count /= 60.0
          if count <= 24.0
            "#{count.round}h"
          else
            count /= 24.0
            if count < 7.0
              "#{count.round}d"
            else
              count /= 7.0
              if count < 52.0
                "#{count.round}w"
              else
                count /= 52.0
                "#{count.round}y"
              end
            end
          end
        end
      end
    end
  end

  def test_btn_style(ans)
    "btn-" +
      case ans
      when "poor"
        "danger"
      when "fair"
        "warning"
      when "good"
        "success"
      when "excellent"
        "primary"
      else
        "outline-secondary"
      end
  end
end
