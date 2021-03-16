defmodule Rocketpay.Account.Transaction do
  alias Ecto.Multi
  alias Rocketpay.Repo
  alias Rocketpay.Account.Operation
  alias Rocketpay.Accounts.Transactions.Response, as: TransactionResponse

  def call(%{"id_origin" => id_origin, "id_destination" =>  id_destination,  "value" => value}) do
    withdraw_params = build_params(id_origin, value)
    deposit_params = build_params(id_destination, value)

    Multi.new()
    |> Multi.merge(fn _changes -> Operation.call(withdraw_params, :withdraw) end)
    |> Multi.merge(fn _changes -> Operation.call(deposit_params, :deposit) end)
    |> run_transaction()
  end

  defp build_params(id, value), do: %{"id" => id, "value" => value}

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{deposit: account_deposit, withdraw: account_withdraw}} ->
      {:ok, TransactionResponse.build(account_withdraw, account_deposit)}
    end
  end

end
