defmodule BankRock.Jobs.Transactions.Withdraw.MailerJob do
  @behaviour Rihanna.Job

  def perform([_transaction], _opts \\ %{}) do
    :ok
  end
end
