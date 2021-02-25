defmodule Rocketpay.Account.Transaction do
  alias Ecto.Multi
  alias Rocketpay.{Account, Repo}
  alias Rocketpay.Account.Operation

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
      {:error, _operation, reason, _changes} -> {{:error, reason}}
      {:ok, %{deposit: id_destination, withdraw: id_origin}} -> {:ok, %{id_destination: id_destination, id_origin: id_origin}}
    end
  end

end
