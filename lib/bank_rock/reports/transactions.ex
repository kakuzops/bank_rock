defmodule BankRock.Reports.Transactions do
  alias BankRock.Transactions

  @doc """
  Returns a map with this properties:
    - total_by_day when report is by_day
    - total_by_month when report is by_month
    - total_by_year when report is by_year
    - total_amount when report is total
  Returns:
  {:ok, transactions, amount}
  """

  def get_report(:by_day) do
    transactions = Transactions.filter_by_day()

    amount =
      transactions
      |> IO.inspect()
      |> calculate_total_amount

    {:ok, %{transactions: format_to_currency(transactions, :transaction), amount: amount}}
  end

  def get_report(:by_month) do
    transactions = Transactions.filter_by_month()

    amount =
      transactions
      |> calculate_total_amount

    {:ok, %{transactions: format_to_currency(transactions, :transaction), amount: amount}}
  end

  def get_report(:by_year) do
    transactions = Transactions.filter_by_year()

    amount =
      transactions
      |> calculate_total_amount

    {:ok, %{transactions: format_to_currency(transactions, :transaction), amount: amount}}
  end

  def get_report(:total) do
    transactions = Transactions.all()

    amount =
      transactions
      |> calculate_total_amount

    {:ok, %{transactions: format_to_currency(transactions, :transaction), amount: amount}}
  end

  def get_report(_) do
    {:error, :invalid_report_type}
  end

  @doc """
  Calculates total amount from transactions.
  It receive a List with transactions and return sum of amounts.
  """
  def calculate_total_amount(transactions) do
    transactions
    |> Enum.reduce(0, fn transaction, acc -> Map.get(transaction, :amount) + acc end)
    |> format_to_currency(:amount)
  end

  @doc """
  Format amount from cents to currency.
  """
  def format_to_currency(transactions, :transaction) do
    transactions
    |> Enum.map(fn transaction ->
      amount =
        Map.get(transaction, :amount)
        |> Money.new(:BRL)
        |> Money.to_string()

      Map.put(transaction, :amount, amount)
    end)
  end

  def format_to_currency(amount, :amount) do
    amount
    |> Money.new(:BRL)
    |> Money.to_string()
  end
end
