defmodule RocketpayWeb.AccountsView do
  alias Rocketpay.Account
  alias Rocketpay.Accounts.Transactions.Response, as: TransactionResponse

  def render("update.json", %{
        account: %Account{
          id: account_id,
          balance: balance
        }
      }) do
    %{
      message: "Ballance changed successfully!",
      account: %{
        id: account_id,
        balance: balance
      }
    }
  end

  def render("transaction.json", %{
        transaction: %TransactionResponse{from_account: account_origin, to_account: account_destination}
      }) do
    %{
      message: "Transaction done successfully!",
      transaction: %{
        account_origin: %{
          id: account_origin.id,
          balance: account_origin.balance
        },
        account_destination: %{
          id: account_destination.id,
          balance: account_destination.balance
        }
      }
    }
  end
end
