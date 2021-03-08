defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase
  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Jv",
        password: "123456",
        email: "jv@test.com",
        nickname: "jv",
        age: 27
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic asdfa")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response =
      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:ok)


    end
  end
end
