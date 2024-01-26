# Recommendation Service

This is the explanation around the whole Service.

It will look into past Transactions and other specific params to approve or deny the Transaction.
Independently we will save the transaction, for future references (in case User is trying to commit fraud)

This is an explanation around all checks:

- Check if there is any other Transaction for the user that has the flag `has_cbk` set to `TRUE`;
- Check if the current time is after midnight and before dawn plus the amount is too high;
- Check if user had any Transaction in past hour;
- Check if the sum of Transactions in last 5 hours is above the 5 hour limit amount;
- Check if the sum of Transactions in last 90 minutes is above the 90 minutes limit amount;
- Check if the Transaction's amount is the same as previous Transactions in past 90 minutes;
- Check if User made Transactions in multiple devices in last 90 minutes;
- Check if User made Transactions in same device multiple times in last 90 minutes

If any of these checks is true, the recommendation will be `deny`.

If all the checks are negative, the recommendation will be `approve`.
