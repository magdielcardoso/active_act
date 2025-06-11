class CreateActiveActActionExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :active_act_action_executions do |t|
      t.string   :action
      t.text     :args
      t.text     :kwargs
      t.text     :result
      t.text     :error
      t.float    :duration
      t.datetime :created_at, null: false
    end
  end
end
