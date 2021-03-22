module TestHelper
  NUMBER = [5, 10, 1, 2, 20]
  NEW = "test_new"
  OLD = "test_old"
  ANS = "test_answers"

  def test_number_menu(selected)
    opts = NUMBER.map { |n| [n.to_s, n] }
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

  def test_new_save(ids)
    session[NEW] = ids.join("_")
  end

  def test_new_review_ids
    session[NEW].to_s.split("_").map(&:to_i).select{ |i| i > 0 }
  end

  def test_new_review?
    !test_new_review_ids.empty?
  end

  def test_new_use
    session[OLD] = session[NEW]
    session[ANS] = ""
  end

  def test_review_ids
    session[OLD].to_s.split("_").map(&:to_i).select{ |i| i > 0 }
  end

  def test_review?
    !test_review_ids.empty?
  end

  def test_answers
    session[ANS].to_s.split("_").select{ |a| Test::ANSWERS.include?(a) }
  end

  def test_index
    test_answers.length
  end

  def test_add_answer(last)
    if session[ANS].present?
      session[ANS] += "_#{last}"
    else
      session[ANS] = last
    end
  end

  def test_style(ans)
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
      "light"
    end
  end
end
