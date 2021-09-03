defmodule BankRock.Guardian do
  use Guardian, otp_app: :bank_rock

  def subject_for_token(%BankRock.Accounts.Account{id: id}, _claims) do
    {:ok, id}
  end

  def subject_for_token(_, _) do
    {:error, :id_is_not_present}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = BankRock.Accounts.filter_by_uuid(id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :account_doesnt_exists}
  end
end
