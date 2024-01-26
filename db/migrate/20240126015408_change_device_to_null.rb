# frozen_string_literal: true

class ChangeDeviceToNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :transactions, :device_id, true
  end
end
