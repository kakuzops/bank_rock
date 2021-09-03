defmodule BankRock.Fixtures.Accounts do
  alias BankRock.Repo
  alias BankRock.Accounts.Account
  alias Comeonin.Bcrypt

  import Ecto.Query, only: [from: 2]

  def account(fixture_name, attrs \\ %{})

  def account(:joe, attrs) do
    account =
      %Account{
        id: "79845ea3-c18e-418b-8f7a-0f342c5389ba",
        name: "Joe Armistrong",
        email: "joe@armistrong.com.br",
        encrypted_password: Bcrypt.hashpwsalt("1234567"),
        balance: 1000 * 100
      }
      |> Map.merge(attrs)

    get_or_create_account(account)
  end

  def account(:maria, attrs) do
    account =
      %Account{
        id: "79845ea3-c18e-418b-8f7a-0f342c538123",
        name: "Maria Vladas",
        email: "maria@valdirme.com.br",
        encrypted_password: Bcrypt.hashpwsalt("1234567"),
        balance: 1000 * 100
      }
      |> Map.merge(attrs)

    get_or_create_account(account)
  end

  defp get_or_create_account(account) do
    query = from(a in Account, where: a.id == ^account.id, limit: 1)

    case Repo.one(query) do
      nil -> Repo.insert!(account)
      _ -> Repo.one(query)
    end
  end
end
