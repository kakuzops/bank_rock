defmodule BankRockWeb.ErrorView do
  use BankRockWeb, :view
  import Ecto.Changeset

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render("422.json", %{changeset: :something_went_wrong}) do
    %{errors: %{detail: "Something went wrong"}}
  end

  def render("422.json", %{changeset: changeset}) do
    %{errors: %{detail: format_changeset_errors(changeset)}}
  end

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def format_changeset_errors(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
