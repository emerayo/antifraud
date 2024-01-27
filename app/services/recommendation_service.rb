# frozen_string_literal: true

class RecommendationService
  APPROVE = 'approve'
  DENY = 'deny'

  def initialize(transaction:)
    @transaction = transaction
  end

  def recommend
    validate_recommendation ? APPROVE : DENY
  end

  private

  def validate_recommendation
    Recommendation.new(transaction: @transaction,
                       transactions: transactions,
                       chargeback: any_chargeback?).valid?
  end

  def transactions
    @transactions ||= Transaction
                      .where(user_id: @transaction.user_id,
                             date: @transaction.date - 5.hours..@transaction.date + 5.minutes)
  end

  def any_chargeback?
    Transaction.exists?(user_id: @transaction.user_id, has_cbk: true)
  end
end
