defmodule BankRock.Fixtures.Transactions do
  alias BankRock.Repo
  alias BankRock.Fixtures
  alias BankRock.Transactions.Transaction

  import Ecto.Query, only: [from: 2]

  def transaction(fixture_name, attrs \\ %{})

  def transaction(:default, attrs) do
    transaction =
      %Transaction{
        id: "ae4aaa13-676e-483e-919e-42fb13e159c7",
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: Fixtures.Accounts.account(:maria).id,
        amount: 100 * 100,
        operation_type: "transfer"
      }
      |> Map.merge(attrs)

    get_or_create_transaction(transaction)
  end

  def transaction(:transfer, attrs) do
    transaction =
      %Transaction{
        id: "25570009-038b-49ab-9a59-aaf0e2ea0d90",
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: Fixtures.Accounts.account(:maria).id,
        amount: 100 * 100,
        operation_type: "transfer"
      }
      |> Map.merge(attrs)

    get_or_create_transaction(transaction)
  end

  def transaction(:withdraw, attrs) do
    transaction =
      %Transaction{
        id: "9c431e06-6fa2-4ddd-af16-46db0d9cffaa",
        payer_id: Fixtures.Accounts.account(:maria).id,
        receiver_id: nil,
        amount: 100 * 100,
        operation_type: "withdraw"
      }
      |> Map.merge(attrs)

    get_or_create_transaction(transaction)
  end

  defp get_or_create_transaction(transaction) do
    query = from(t in Transaction, where: t.id == ^transaction.id, limit: 1)

    case Repo.one(query) do
      nil -> Repo.insert!(transaction)
      _ -> Repo.one(query)
    end
  end
end
