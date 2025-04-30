module Ks
  class Proc < ActiveRecord::Base
    MAX_COMMAND = 100
    MAX_SHORT = 32

    belongs_to :top, class_name: "Ks::Top", foreign_key: :ks_top_id

    validates :pid, numericality: { only_integer: true, greater_than: 0 }
    validates :mem, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :command, presence: true, length: { maximum: MAX_COMMAND }
    validates :command, length: { maximum: MAX_COMMAND }, allow_nil: true

    default_scope { order(mem: :desc) }
  end
end
