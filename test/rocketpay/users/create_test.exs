defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase


  alias Rocketpay.User
  alias Rocketpay.Users.Create

  describe("call/1") do
    test "when all params are valid, returns an user" do
      params = %{
        name: "Jv",
        password: "123456",
        email: "jv@test.com",
        nickname: "jv",
        age: 27
      }

      {:ok, %User{id: user_id}} = Create.call(params)
      user = Repo.get(User, user_id)

      assert %User{name: "Jv", age: 27, id: ^user_id} = user
    end

    test "when are invalid params, dont returns an user" do
      params = %{
        name: "Jv",
        email: "jv@test.com",
        nickname: "jv",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_response = %{
        age: ["must be greater than or equal to 18"],
        password: ["can't be blank"]
      }

      assert  errors_on(changeset) == expected_response
    end
  end
end
