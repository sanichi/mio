class Relation
  attr_reader :type, :grand, :degree, :removal, :law, :step, :past

  def initialize(type, grand: 0, degree: 0, removal: 0, law: false, step: false, past: false)
    @type, @grand, @degree, @removal, @law, @step, @past = type, grand, degree, removal, law, step, past
  end

  def self.infer(my_ancestor, their_ancestor, me, them)
    return new(:none) unless my_ancestor && their_ancestor
    opt = { past: !!me.died }
    my_depth, their_depth = my_ancestor.depth, their_ancestor.depth
    my_order, their_order = my_ancestor.order, their_ancestor.order
    type =
      case
      when my_depth == 0 && their_depth == 0
        my_order == "" && their_order == "" ? :self : (me.male ? :husband : :wife)
      when my_depth > 0 && their_depth == 0
        opt[:grand] = my_depth - 1
        opt[:law] = my_order.match(/^M/)
        opt[:step] = their_order.match(/^M/)
        me.male ? :son : :daughter
      when my_depth == 0 && their_depth > 0
        opt[:grand] = their_depth - 1
        opt[:law] = their_order.match(/^M/)
        opt[:step] = their_order.match(/M$/)
        me.male ? :father : :mother
      when my_depth == 1 && their_depth == 1
        opt[:law] = my_order.match(/^M/) || their_order.match(/^M/)
        opt[:step] = my_order.match(/M$/) || their_order.match(/M$/)
        me.male ? :brother : :sister
      when my_depth > 1 && their_depth == 1
        opt[:grand] = my_depth - 1
        me.male ? :nephew : :niece
      when my_depth == 1 && their_depth > 1
        opt[:grand] = their_depth - 1
        me.male ? :uncle : :aunt
      when my_depth >= 2 && their_depth >= 2
        opt[:degree] = [my_depth, their_depth].min - 1
        opt[:removal] = (my_depth - their_depth).abs
        :cousin
      else
        :none
      end
    if type == :husband || type == :wife
      partnership = me.male ? me.partnerships_as_male.find_by(wife_id: them.id) : me.partnerships_as_female.find_by(husband_id: them.id)
      opt[:past] = true if them.died || (partnership && partnership.divorce)
      type = :partner if !partnership || !partnership.marriage
    end
    new(type, **opt)
  end

  def to_s
    rel =
      case type
      when :self
        "the same as"
      when :none
        "no relation of"
      when :father, :mother
        if !step && !law && grand == 0
          "the " + type.to_s + " of"
        else
          "a " + step_part + great_part + grand_part + type.to_s + law_part + " of"
        end
      when :son, :daughter
        "a " + step_part + great_part + grand_part + type.to_s + law_part + " of"
      when :uncle, :aunt
        if grand < 2
          "an " + type.to_s + " of"
        else
          "a " + great_part + type.to_s + " of"
        end
      when :nephew, :niece
        "a " + great_part + type.to_s + " of"
      when :brother, :sister
        "a " + step_part + type.to_s + law_part + " of"
      when :cousin
        "a " + degree_part + type.to_s + removal_part + " of"
      else
        "the " + type.to_s + " of"
      end
    "#{past ? 'was' : 'is'} #{rel}"
  end

  private

  def great_part
    grand > 1 ? "great-" * (grand - 1) : ""
  end

  def grand_part
    grand > 0 ? "grand" : ""
  end

  def degree_part
    case degree
    when 1 then "1st "
    when 2 then "2nd "
    when 3 then "3rd "
    else "#{degree}th "
    end
  end

  def removal_part
    case removal
    when 0 then ""
    when 1 then " once removed"
    when 2 then " twice removed"
    else "#{removal}-times removed"
    end
  end

  def law_part
    law ? "-in-law" : ""
  end

  def step_part
    step ? "step-" : ""
  end
end
