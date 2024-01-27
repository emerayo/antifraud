# frozen_string_literal: true

class Recommendation
  DENY = 'deny'
  CARD_NUMBER_LENGTH = 16
  ONE_HOUR_MAX_LIMIT = 1_000
  FIVE_HOUR_MAX_LIMIT = 5_000
  MAX_DEVICES_IN_ONE_HOUR = 2
  MAX_TRANSACTIONS_SAME_DEVICE = 2
  NIGHT_LIMIT = 500

  include ActiveModel::Validations

  attr_reader :transaction

  validate :check_card_number_length
  validate :previous_chargeback
  validate :no_denied_transactions
  validate :five_hours_amount_limit
  validate :one_hour_amount_limit
  validate :same_amount_last_hour
  validate :too_many_devices
  validate :same_device_multiple_times
  validate :night_high_amount

  def initialize(transaction:, transactions:, chargeback:)
    @transaction = transaction
    @transactions = transactions
    @chargeback = chargeback
  end

  private

  attr_reader :chargeback, :transactions

  def check_card_number_length
    return if transaction.card_number.length == CARD_NUMBER_LENGTH

    errors.add(:base, :invalid_card_number)
  end

  def previous_chargeback
    return unless chargeback

    errors.add(:base, :previous_chargeback)
  end

  def last_hour_transactions
    range = transaction.date - 90.minutes..transaction.date + 5.minutes
    @last_hour_transactions ||= transactions.where(date: range)
  end

  def no_denied_transactions
    return unless transactions.exists?(recommendation: DENY)

    errors.add(:base, :previous_denied)
  end

  def five_hours_amount_limit
    return unless transactions.sum(:amount) >= FIVE_HOUR_MAX_LIMIT

    errors.add(:base, :five_hours_limit)
  end

  def one_hour_amount_limit
    return unless last_hour_transactions.sum(:amount) >= ONE_HOUR_MAX_LIMIT

    errors.add(:base, :one_hour_limit)
  end

  def same_amount_last_hour
    return unless last_hour_transactions.exists?(amount: @transaction.amount)

    errors.add(:base, :same_amount_last_hour)
  end

  def too_many_devices
    return unless last_hour_transactions.pluck(:device_id).uniq.size >= MAX_DEVICES_IN_ONE_HOUR

    errors.add(:base, :too_many_devices)
  end

  def same_device_multiple_times
    return unless last_hour_transactions
                  .where(device_id: @transaction.device_id).count >= MAX_TRANSACTIONS_SAME_DEVICE

    errors.add(:base, :same_device_multiple_times)
  end

  def night_high_amount
    return if @transaction.date.hour < 22 && @transaction.date.hour > 6 && @transaction.amount

    return if @transaction.amount < NIGHT_LIMIT

    errors.add(:base, :high_amount_night)
  end
end
