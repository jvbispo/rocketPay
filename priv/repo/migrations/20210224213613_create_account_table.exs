defmodule Rocketpay.Repo.Migrations.CreateAccountTable do
  use Ecto.Migration

  def change do
    create table :account do
      add :balance, :decimal
      add :user_id, references(:users, type: :binary_id)

      timestamps()
    end

    create constraint(:account, :balance_must_be_positive_or_zero, check: "balance >= 0")
  end
end
