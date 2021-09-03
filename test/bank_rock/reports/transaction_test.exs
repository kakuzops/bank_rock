defmodule BankRock.Reports.TransactionTest do
  use BankRock.DataCase, async: true
  alias BankRock.Repo
  alias BankRock.Reports.Transactions
  alias BankRock.Transactions.Transaction
  alias BankRock.Fixtures
  import Ecto.Query, only: [from: 2]

  def call_fixtures(_context) do
    Fixtures.Transactions.transaction(:withdraw)
    Fixtures.Transactions.transaction(:transfer)
    :ok
  end

  describe "get_report/1" do
    setup [:call_fixtures]

    test "by_day" do
      {:ok, result} = Transactions.get_report(:by_day)
      assert result |> Map.get(:amount) == "R$200.00"
      assert result |> Map.get(:transactions) |> Enum.count() == 2
    end

    test "by_month" do
      old_date = ~N[2018-11-15 10:00:00]

      Repo.one(from t in Transaction, limit: 1)
      |> change(inserted_at: old_date)
      |> Repo.update!()

      {:ok, result} = Transactions.get_report(:by_month)

      assert result |> Map.get(:amount) == "R$100.00"
      assert result |> Map.get(:transactions) |> Enum.count() == 1
    end

    test "by_year" do
      old_date = ~N[2018-11-15 10:00:00]

      Repo.one(from t in Transaction, limit: 1)
      |> change(inserted_at: old_date)
      |> Repo.update!()

      {:ok, result} = Transactions.get_report(:by_year)
      assert result |> Map.get(:amount) == "R$100.00"
      assert result |> Map.get(:transactions) |> Enum.count() == 1
    end

    test "total" do
      old_date = ~N[2018-11-15 10:00:00]

      Repo.one(from t in Transaction, limit: 1)
      |> change(inserted_at: old_date)
      |> Repo.update!()

      {:ok, result} = Transactions.get_report(:total)
      assert result |> Map.get(:amount) == "R$200.00"
      assert result |> Map.get(:transactions) |> Enum.count() == 2
    end

    test "invalid type" do
      {:error, result} = Transactions.get_report(:random)

      assert result == :invalid_report_type
    end
  end
end
