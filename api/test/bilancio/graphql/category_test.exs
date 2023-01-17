defmodule Bilancio.Graphql.CategoryTest do
  use ExUnit.Case

  alias Bilancio.Graphql.Schema

  alias Bilancio.Domain.User, as: UserDomain

  @login_mutation """
  mutation($email: String!, $password: String!)  {
    login(email: $email, password: $password) {
      __typename
      ... on LoginSuccess {
        token
        identifier
      }
      ... on LoginFailure {
        error
      }
    }
  }
  """

  @user_categories_mutation """
    query {
    	categories {
    		title
    		color
    		identifier
    	}
    }

  """

  @first_active_user_credential %{
    "email" => "baroni.marco.91@gmail.com",
    "password" => "diocane"
  }

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bilancio.Repo)
  end

  describe "Fetch user categories" do
    test "succeed", _context do
      {:ok,
       %{
         data: %{
           "login" => %{
             "__typename" => "LoginSuccess",
             "token" => token,
             "identifier" => user_identifier
           }
         }
       }} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @first_active_user_credential
        )

      absinthe_context =
        %{}
        |> Map.put(:authorization_token, token)
        |> Map.put(:current_user, %UserDomain{identifier: user_identifier})

      {:ok, %{data: %{"categories" => categories}}} =
        Absinthe.run(
          @user_categories_mutation,
          Schema,
          context: absinthe_context,
          variables: nil
        )

      assert is_list(categories)
    end
  end
end
