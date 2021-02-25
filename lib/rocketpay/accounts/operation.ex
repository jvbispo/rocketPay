defmodule Rocketpay.Account.Operation do
  alias Ecto.Multi
  alias Rocketpay.{Account, Repo}

  def call(%{"id" => id, "value" => value}, operation) do
    operation_name = account_operation_name(operation)
    Multi.new()
    |> Multi.run(operation_name, fn repo, _changes -> get_account(repo, id) end)
    |> Multi.run(operation, fn repo, changes ->
      account = Map.get(changes, operation_name)
      update_balance(repo, account, value, operation) end)
    |> run_transaction()
  end

  defp get_account(repo, id) do
    case repo.get(Account, id) do
      nil -> {:error, "Account not found!"}
      account -> {:ok, account}
    end
  end

  defp update_balance(repo, account, value, operation ) do
    account
    |> sum_values(value, operation)
    |> update_account(repo, account)
  end

  defp sum_values(%Account{balance: balance}, value, operation) do
    value
    |> Decimal.cast()
    |> handle_cast(balance, operation)
  end

  defp handle_cast({:ok, value}, balance, :deposit), do: Decimal.add(value, balance)
  defp handle_cast({:ok, value}, balance, :withdraw), do: Decimal.sub(value, balance)
  defp handle_cast({:error, _value}, _balance, _operation), do: {:error, "invalid deposite value!"}

  defp update_account({:error, _value, _reason} = error, _repo, _account ), do: error
  defp update_account(value, repo, account) do
    params = %{balance: value}

    account
    |> Account.changeset(params)
    |> repo.update()
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {{:error, reason}}
      {:ok, %{update_balance: account}} -> {:ok, account}
    end
  end

  defp account_operation_name(operation) do
    operation
    |> "account_#{Atom.to_string()}"
    |> String.to_atom()
  end
end
