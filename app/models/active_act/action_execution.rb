module ActiveAct
  class ActionExecution < ApplicationRecord
    self.table_name = 'active_act_action_executions'

    validates :status, presence: true
    validates :executed_at, presence: true
  end
end 