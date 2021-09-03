Bank_rock Phoenix application responsible for making transactions between accounts involving withdraw and transfer operations.

## Installation
You will need some applications to make the project run, such as:
* Elixir on version 1.12.2
* Erlang on version 24.0.1
* Postgresql on version >= 11.0.

### Guide
1. Clone this repository
```
git clone https://github.com/kakuzops/bank_rock
```
2. Install **Elixir**  (Oficial documentation).
```
https://elixir-lang.org/install.html
```
3. Install **Erlang** (Oficial documentation).
```
https://erlang.org/doc/installation_guide/INSTALL.html
```

4. Move to the repository dire
```
cd bank_rock
```

5. Install dependencies
```
mix deps.get
```

6. Create a database
```
mix ecto.setup
```

7. Run Server
```
mix phx.server
```

8. Access via port 4000

### With Docker
1. Simple run:
```
docker-compose up -d
```

```
mix test
```
## Documentation

### Without authentication.

### Endpoint:
```
POST /api/account/sign_up
```

#### Params:

```
      {
        "account" :
        {
          "name" : name,
          "email" : email,
          "password" : password
        }
      }
```

### Response

#### 200
```
%{
  "balance" => "R$1,000.00",
  "email" => "kakuzops@gmail.com",
  "id" => "01c1c990-b750-42a4-9707-f12040da3f22",
  "jwt" => "token",
  "name" => "KakuzoPs"
}
```
#### 422
```
{"errors" : {"detail" : {"email" : ["can't be blank"]}}}
```

### Endpoint:
```
POST /api/account/sign_in
```

#### Params:

```
      {
        "account":
        {
          "email": email,
          "password": password
        }
      }
```

### Response

#### 200
```
{
  "jwt" => "token"
}
```
#### 401
```
{"errors" : %{"detail" : "Unauthorized"}}
```


### Basic Auth Endpoint

For these endpoints, you should auth with Basic Auth.

#### Default Credentials:
| username | bankRock |
|----------:|-----:|
| **password** | **password** |

### Endpoint:
```
POST /api/report/transactions
```

#### Params:
type could be this following options:
1. "by_day" -> Returns only transactions and amount from the current day.
2. "by_month" -> Returns only transactions and amount from the current month.
3. "by_year" -> Returns only transactions and amount from current year.
4. "total" -> Returns transactions and amount with no date scope.

```
{
  {
    "report" : {"type" : type}
  }
}
```

### Response

#### 200
```
{"amount" : "R$0.00", "transactions" : []}
```

#### 400
```
{"errors": %{"detail": "Bad Request"}}
```

### Bearer Authentication (JWT Token)
For these endpoints, you should pass an account token to make a request.

### Endpoint:
```
POST /api/transaction/create
```

#### Params:
1. operation_type -> Only accept "transfer" or "withdraw" as values.
2. amount -> Amount of operation in cents.
3. receiver_id -> Only when operation_type is transfer.

##### Transfer:
```
      {
        "transaction":
        {
          "operation_type": "transfer",
          "amount": 100000,
          "receiver_id": "Random.uuid"
        }
      }
```

##### Withdraw:
```
      {
        "transaction":
        {
          "operation_type": "withServer's Up!draw",
          "amount": 100000,
        }
      }
```

### Response

#### 200 (Transfer)
```
{
  "amount" => "R$100.00",
  "id" => "ce5318bf-4e24-4aee-b47b-6c1741927838",
  "inserted_at" => "2020-01-24T15:17:21",
  "operation_type" => "transfer",
  "payer_id" => "79845ea3-c18e-418b-8f7a-0f342c5389ba",
  "receiver_id" => "79845ea3-c18e-418b-8f7a-0f342c538123"
}
```

#### 200 (Withdraw)
```
{
  "amount" => "R$100.00",
  "id" => "097816d7-f421-4960-95bc-5fefc04164a9",
  "inserted_at" => "2020-01-24T15:18:15",
  "operation_type" => "withdraw",
  "payer_id" => "79845ea3-c18e-418b-8f7a-0f342c5389ba",
  "receiver_id" => nil
}
```

#### 422
```
"errors": {"detail": {"balance": ["amount cannot be negative"]}}
```

## Deploy

Application available at:
```
https://bankrock.gigalixirapp.com/
```