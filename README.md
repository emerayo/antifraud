# Real State

Explanation and answers for the challenge are found in [QUESTIONS.md](./QUESTIONS.md).

## System dependencies

* PostgreSQL 14.0+
* Ruby 3.2.1

## Setup

Copy the `sample.env` file:

```shell
$ cp sample.env .env
```

Now open `.env` file and make sure database environment variables are correct for your environment (use your Postgres configuration).

Install all gems and create the development and test databases:

```shell
$ bundle install
$ bin/rails db:setup
```

## Running the server

To run the server locally, run the command:

```shell
$ rails s
```

You can stop the server by pressing:

```
CTRL + C
```

## Running the tests

```shell
$ bundle exec rspec
```

### Checking code coverage for the project

After running `rspec`, it will generate a file in `coverage/index.html` containing the test results,
simply open it on a browser to check the coverage.

## Committing

This project uses [Overcommit](https://github.com/sds/overcommit), a gem that run some checks before allowing you to commit your changes.
Such as RuboCop, TrailingWhitespace and Brakeman.

Install Overcommit hooks:

```shell
$ overcommit --sign
$ overcommit --install
```

Now you can commit.

## API

The examples are using the credentials from the ENVs.

This API contains three endpoints:

### GET api/v1/transactions/:id

Renders the Transaction ID and the recommendation

Running with cURL:

```shell
curl -X GET http://localhost:3000/api/v1/transactions/21323596 -u "antifraud_admin:strong_password"
```

Example response:

```shell
{ "id": 21323596, "recommendation": "approve" }
```

### PATCH api/v1/transactions/:id/chargeback

Changes the flag `has_cbk` to `true` in the Transaction

Running with cURL:

```shell
curl -X PATCH http://localhost:3000/api/v1/transactions/21323596/chargeback -u "antifraud_admin:strong_password"
```
Example response:

```shell
{ "has_cbk": true, "id":21323596, "recommendation": "approve" }
```

### POST api/v1/transactions/

Creates the Transaction and returns the recommendation

Running with cURL:

```shell
curl -X POST http://localhost:3000/api/v1/transactions
-u "antifraud_admin:strong_password"
-H "Content-Type: application/json"
-d '{"id": 2323, "merchant_id": 29744, "user_id": 97051, "card_number": "434505******9116", "date": "2019-12-01T23:16:32.812632", "amount": 374.56, "device_id": 285475 }'
```
Example response:

```shell
{ "id": 2323, "recommendation": "deny" }
```
