defmodule BankRockWeb.Api.Report.TransactionController do
  use BankRockWeb, :controller
  alias BankRock.Reports.Transactions
  alias BankRockWeb.ErrorView

  @doc """
  Receives a params with this following struct:
  %{
    "report" => %{"type" => type}
  }
  type could be:
    - "by_day" -> Returns only transactions and amount from current day.
    - "by_month" -> Returns only transactions and amount from current month.
    - "by_year" -> Returns only transactions and amount from current year.
    - "total" -> Returns transactions and amount with no date scope.
  """
  def index(conn, %{"report" => %{"type" => type}}) do
    with {:ok, report} <- Transactions.get_report(String.to_atom(type)) do
      conn
      |> put_status(:ok)
      |> json(report)
    else
      {:error, _report} ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json")
    end
  end

  def index(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json")
  end
end
