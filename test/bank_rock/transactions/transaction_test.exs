defmodule BankRock.Transactions.TransactionsTest do
  use BankRock.DataCase, async: true

  alias BankRock.Transactions
  alias BankRock.Transactions.Transaction
  alias BankRock.Accounts
  alias BankRock.Fixtures
  alias BankRock.Job

  describe "transactions" do
    defp valid_attrs(:transfer) do
      %{
        operation_type: "transfer",
        amount: 100 * 100,
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: Fixtures.Accounts.account(:maria).id
      }
    end

    defp valid_attrs(:withdraw) do
      %{
        operation_type: "withdraw",
        amount: 100 * 100,
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: Fixtures.Accounts.account(:maria).id
      }
    end

    defp invalid_attrs do
      %{
        operation_type: "joelzinho",
        amount: -500 * 100,
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: nil
      }
    end

    defp equal_payer_and_receiver_attrs do
      %{
        operation_type: "withdraw",
        amount: 100 * 100,
        receiver_id: Fixtures.Accounts.account(:joe).id,
        payer_id: Fixtures.Accounts.account(:joe).id
      }
    end

    test "create_and_update_account_balance/1 with valid data (operation: withdraw) creates a transaction and change account balances" do
      maria_account = Fixtures.Accounts.account(:maria)

      assert maria_account.balance == 1_000_00

      {:ok, %Transaction{} = transaction} =
        Transactions.create_and_update_account_balance(valid_attrs(:withdraw))

      assert Job.enqueued() |> Enum.empty?() == false

      assert transaction.amount == 100_00
      assert transaction.operation_type == "withdraw"
      assert transaction.payer_id == valid_attrs(:withdraw).payer_id
      assert transaction.receiver_id == valid_attrs(:withdraw).receiver_id

      maria_account = Accounts.filter_by_uuid(maria_account.id)
      assert maria_account.balance == 90_000
    end

    test "create_and_update_account_balance/1 with valid data (operation: transfer) creates a transaction and change account balances" do
      maria_account = Fixtures.Accounts.account(:maria)
      joe_account = Fixtures.Accounts.account(:joe)

      assert maria_account.balance == 1_000_00
      assert joe_account.balance == 1_000_00

      {:ok, %Transaction{} = transaction} =
        Transactions.create_and_update_account_balance(valid_attrs(:transfer))

      assert Job.enqueued() == []

      assert transaction.amount == 100_00
      assert transaction.operation_type == "transfer"
      assert transaction.payer_id == valid_attrs(:transfer).payer_id
      assert transaction.receiver_id == valid_attrs(:transfer).receiver_id

      maria_account = Accounts.filter_by_uuid(maria_account.id)
      joe_account = Accounts.filter_by_uuid(joe_account.id)

      assert maria_account.balance == 900_00
      assert joe_account.balance == 1_100_00
    end

    test "create_and_update_account_balance/1 with invalid data returns a invalid transaction" do
      {:error, {_action, changeset, _changes_so_far}} =
        Transactions.create_and_update_account_balance(invalid_attrs())

      assert Job.enqueued() == []

      assert changeset.valid? == false
      assert changeset.errors |> Enum.empty?() == false
    end

    test "create_and_update_account_balance/1 with invalid data (equal receiver and payer) returns a invalid transaction" do
      {:error, {_action, changeset, _changes_so_far}} =
        Transactions.create_and_update_account_balance(equal_payer_and_receiver_attrs())

      assert Job.enqueued() == []

      assert changeset.valid? == false
      assert changeset.errors |> Enum.empty?() == false
    end
  end
end
