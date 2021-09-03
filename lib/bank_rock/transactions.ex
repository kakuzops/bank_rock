defmodule BankRock.Transactions do
  import Ecto.Query, only: [from: 2]
  alias BankRock.Repo
  alias BankRock.Transactions.Transaction
  alias BankRock.Jobs.Transactions.Withdraw.MailerJob
  alias BankRock.Accounts.Account
  alias BankRock.Accounts
  alias Ecto.Multi
  use Timex

  @doc """
  Creates a transaction.
  Mandatory transactions properties:
    - operation_type (string: [ withdraw or transfer ]
    - amount (integer(amount in cents): min 0)
    - payer_id ( UUID )
    - receiver_id ( UUID )
  """

  def run_create(multi, %{} = transaction_params) do
    multi
    |> Multi.run(:create_transaction, fn _repo, _changes ->
      %Transaction{}
      |> Transaction.changeset(transaction_params)
      |> Repo.insert()
    end)
  end

  def run_account_balance_update(multi) do
    multi
    |> Multi.run(:account_balance_update, fn _repo, %{create_transaction: transaction} ->
      payer = Accounts.filter_by_uuid(transaction.payer_id)
      receiver = Accounts.filter_by_uuid(transaction.receiver_id)

      {:ok, payer_balance: payer_balance, receiver_balance: receiver_balance} =
        Accounts.calculate_balance(
          String.to_atom(transaction.operation_type),
          payer,
          receiver,
          transaction.amount
        )

      unless is_nil(payer) && is_nil(payer_balance) do
        payer
        |> Account.change_account(%{balance: payer_balance})
        |> Repo.update()
      end

      unless is_nil(receiver) && is_nil(receiver_balance) do
        receiver
        |> Account.change_account(%{balance: receiver_balance})
        |> Repo.update()
      end

      {:ok, transaction}
    end)
  end

  def run_notify_by_mail(multi) do
    multi
    |> Multi.run(:notify_by_mail, fn _repo, %{account_balance_update: transaction} ->
      if transaction.operation_type == "withdraw" do
        Rihanna.enqueue({MailerJob, :perform, [transaction]})
      end

      {:ok, transaction}
    end)
  end

  def create_and_update_account_balance(%{} = transaction_params) do
    transaction_result =
      Multi.new()
      |> run_create(transaction_params)
      |> run_account_balance_update()
      |> run_notify_by_mail()
      |> Repo.transaction()

    case transaction_result do
      {:ok, %{notify_by_mail: transaction}} ->
        {:ok, transaction}

      {:error, failed_operation, failed_value, changes_so_far} ->
        {:error, {failed_operation, failed_value, changes_so_far}}
    end
  end

  @doc """
  Returns transactions by intervals:
    - per_day (current_day)
    - per_month (current_month)
    - per_year (current_year)
    - all (all transactions)
  """

  def filter_by_day do
    date =
      DateTime.utc_now()
      |> Timex.beginning_of_day()

    query = from t in Transaction, where: t.inserted_at >= ^date

    query
    |> Repo.all()
  end

  def filter_by_month do
    date =
      DateTime.utc_now()
      |> Timex.beginning_of_month()

    query = from t in Transaction, where: t.inserted_at >= ^date

    query
    |> Repo.all()
  end

  def filter_by_year do
    date =
      DateTime.utc_now()
      |> Timex.beginning_of_year()

    query = from t in Transaction, where: t.inserted_at >= ^date

    query
    |> Repo.all()
  end

  def all do
    Repo.all(Transaction)
  end

  def put_payer_id(transaction_params, account) do
    struct =
      transaction_params
      |> Map.put("payer_id", account.id)

    {:ok, struct}
  end

  def format_to_currency(transaction, :transaction) do
    amount =
      transaction
      |> Map.get(:amount)
      |> Money.new(:BRL)
      |> Money.to_string()

    {:ok, Map.put(transaction, :amount, amount)}
  end
end
