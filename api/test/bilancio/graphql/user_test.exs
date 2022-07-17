defmodule Bilancio.Graphql.UserTest do
  use ExUnit.Case

  alias Bilancio.Graphql.Schema

  alias Bilancio.Token, as: Token

  alias Bilancio.Domain.User, as: UserDomain

  alias Noether.Either

  @jwt_sign Application.compile_env!(:bilancio, :jwt)[:sign]

  @jwt_exp_days Application.compile_env!(:bilancio, :jwt)[:exp_days]

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

  @logout_mutation """
  mutation {
    logout {
      __typename
      ... on LogoutSuccess {
        message
      }
      ... on LogoutFailure {
        error
      }
    }
  }
  """

  @delete_movement_mutation """
  mutation ($movement_identifier: Uuid!) {
    deleteMovement(identifier: $movement_identifier) {
      __typename
      ... on DeleteMovementFailure {
        error
      }
      ... on DeleteMovementSuccess {
        message
      }
    }
  }
  """

  @user_query """
  query {
    me {
      firstName
      lastName
      insertedAt
      status
      movements{
        identifier
        title
        description
        value
        occurredAt
      }
    }
  }
  """

  @user_movement """
  query ($identifier: Uuid!) {
    movement(identifier: $identifier) {
      title
      description
      identifier
      occurredAt
      value
    }
  }
  """

  @user_movements_query """
  query($orderBy: MovementsOrder){
    me {
      movements(order: $orderBy){
        identifier
        title
        description
        value
        occurredAt
      }
    }
  }
  """

  @first_active_user_credential %{
    "email" => "baroni.marco.91@gmail.com",
    "password" => "diocane"
  }

  @second_first_active_user_credential %{
    "email" => "vincenzo.ferragamo@gmail.com",
    "password" => "vincenzoferragamopassword"
  }

  @not_first_active_user_credential %{
    "email" => "rocco.papaleo.not.active@gmail.com",
    "password" => "roccopapaleopassword"
  }

  @wrong_user_credential %{
    "email" => "baroni.marco.91+not_active@gmail.com",
    "password" => "password-sbagliata"
  }

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bilancio.Repo)
  end

  describe "Login" do
    test "succeed", _context do
      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginSuccess"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: nil,
                 variables: @first_active_user_credential
               )
    end

    test "succeed, check token validity", _context do
      {:ok, %{data: %{"login" => %{"token" => token}}}} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @first_active_user_credential
        )

      assert {:ok, %{"sub" => _sub, "exp" => _exp}} =
               Token.verify_and_validate(token, Joken.Signer.create(@jwt_sign, "secret"))
    end

    test "succeed, check the expired day of jwt", _context do
      {:ok, %{data: %{"login" => %{"token" => token}}}} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @first_active_user_credential
        )

      {:ok, %{"sub" => _sub, "exp" => exp}} =
        Token.verify_and_validate(token, Joken.Signer.create(@jwt_sign, "secret"))

      {:ok, exp_date} = DateTime.from_unix(exp)
      diff_days = DateTime.diff(exp_date, DateTime.utc_now(), :second) / 60 / 60 / 24

      assert diff_days == @jwt_exp_days
    end

    test "user with status: no_active can't login", _context do
      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginFailure"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: nil,
                 variables: @not_first_active_user_credential
               )
    end

    test "wrong credential, failed loggend in", _context do
      assert {:ok, %{data: %{"login" => %{"__typename" => "LoginFailure"}}}} =
               Absinthe.run(
                 @login_mutation,
                 Schema,
                 context: nil,
                 variables: @wrong_user_credential
               )
    end
  end

  describe "logout" do
    test "logout success", _context do
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

      assert {:ok, %{data: %{"logout" => %{"__typename" => "LogoutSuccess"}}}} =
               Absinthe.run(
                 @logout_mutation,
                 Schema,
                 context: absinthe_context,
                 variables: nil
               )
    end

    test "logout without token, error!", _context do
      assert {:ok, %{data: nil}} =
               Absinthe.run(
                 @logout_mutation,
                 Schema,
                 context: nil,
                 variables: nil
               )
    end
  end

  describe "get user data" do
    test "get user data success!", _context do
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

      assert {:ok,
              %{
                data: %{
                  "me" => %{
                    "firstName" => first_name,
                    "lastName" => last_name,
                    "movements" => movements
                  }
                }
              }} =
               Absinthe.run(
                 @user_query,
                 Schema,
                 context: absinthe_context,
                 variables: nil
               )

      assert "Marco" == first_name

      assert "Baroni" == last_name

      assert 3 == Enum.count(movements)
    end

    test "get user movement success!", _context do
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

      {:ok, %{data: %{"me" => %{"movements" => movements}}}} =
        Absinthe.run(@user_query, Schema, context: absinthe_context, variables: nil)

      movement_identifier_to_get =
        movements
        |> List.first()
        |> Map.get("identifier")

      assert {:ok, %{data: %{"movement" => %{"value" => _}}}} =
               Absinthe.run(@user_movement, Schema,
                 context: absinthe_context,
                 variables: %{"identifier" => movement_identifier_to_get}
               )
    end

    test "get user movement that does not exist", _context do
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

      assert {:ok, %{data: %{"movement" => nil}}} =
               Absinthe.run(@user_movement, Schema,
                 context: absinthe_context,
                 variables: %{"identifier" => UUID.string_to_binary!(UUID.uuid4())}
               )
    end

    test "try to fetch a movement which does not belong to the user", _context do
      {:ok,
       %{
         data: %{
           "login" => %{
             "__typename" => "LoginSuccess",
             "token" => token_main_user,
             "identifier" => main_user_identifier
           }
         }
       }} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @first_active_user_credential
        )

      main_user_absinthe_context =
        %{}
        |> Map.put(:authorization_token, token_main_user)
        |> Map.put(:current_user, %UserDomain{identifier: main_user_identifier})

      {:ok,
       %{
         data: %{
           "login" => %{
             "__typename" => "LoginSuccess",
             "token" => token_second_user,
             "identifier" => second_user_identifier
           }
         }
       }} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @second_first_active_user_credential
        )

      second_user_absinthe_context =
        %{}
        |> Map.put(:authorization_token, token_second_user)
        |> Map.put(:current_user, %UserDomain{identifier: second_user_identifier})

      {:ok, %{data: %{"me" => %{"movements" => movements_second_user}}}} =
        Absinthe.run(@user_query, Schema, context: second_user_absinthe_context, variables: nil)

      movement_identifier_to_get =
        movements_second_user
        |> List.first()
        |> Map.get("identifier")

      assert {:ok, %{data: %{"movement" => nil}}} =
               Absinthe.run(@user_movement, Schema,
                 context: main_user_absinthe_context,
                 variables: %{"identifier" => movement_identifier_to_get}
               )
    end

    test "get user data with token that has been logged out, error!", _context do
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

      assert {:ok, %{data: %{"logout" => %{"__typename" => "LogoutSuccess"}}}} =
               Absinthe.run(
                 @logout_mutation,
                 Schema,
                 context: absinthe_context,
                 variables: nil
               )

      assert {:ok, %{data: %{"me" => nil}}} =
               Absinthe.run(
                 @user_query,
                 Schema,
                 context: absinthe_context,
                 variables: nil
               )
    end

    test "get user data without token, error!", _context do
      assert {:ok, %{data: %{"me" => nil}}} =
               Absinthe.run(
                 @user_query,
                 Schema,
                 context: nil,
                 variables: nil
               )
    end
  end

  describe "user movements orderby" do
    test "check orderby date desc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "OCCURRED_AT", "type" => "DESC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.map(fn movement = %{"occurredAt" => occurred_at} ->
          Map.put(
            movement,
            :occurredAt,
            occurred_at |> Timex.parse("{YYYY}-{0M}-{D}") |> Either.unwrap()
          )
        end)
        |> Enum.sort_by(
          fn %{"occurredAt" => occurred_at} ->
            occurred_at
          end,
          :desc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end

    test "check orderby date asc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "OCCURRED_AT", "type" => "ASC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.map(fn movement = %{"occurredAt" => occurred_at} ->
          Map.put(
            movement,
            :occurredAt,
            occurred_at |> Timex.parse("{YYYY}-{0M}-{D}") |> Either.unwrap()
          )
        end)
        |> Enum.sort_by(
          fn %{"occurredAt" => occurred_at} ->
            occurred_at
          end,
          :asc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end

    test "check orderby title desc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "TITLE", "type" => "DESC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.sort_by(
          fn %{"title" => title} ->
            title
          end,
          :desc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end

    test "check orderby title asc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "TITLE", "type" => "ASC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.sort_by(
          fn %{"title" => title} ->
            title
          end,
          :asc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end

    test "check orderby value desc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "VALUE", "type" => "DESC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.sort_by(
          fn %{"value" => value} ->
            value
          end,
          :desc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end

    test "check orderby value asc movements", _context do
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

      {:ok,
       %{
         data: %{
           "me" => %{
             "movements" => movements
           }
         }
       }} =
        Absinthe.run(
          @user_movements_query,
          Schema,
          context: absinthe_context,
          variables: %{"orderBy" => %{"by" => "VALUE", "type" => "ASC"}}
        )

      movement_identifiers =
        Enum.map(movements, fn %{"identifier" => identifier} ->
          identifier
        end)

      expected_identifiers =
        movements
        |> Enum.sort_by(
          fn %{"value" => value} ->
            value
          end,
          :asc
        )
        |> Enum.map(fn %{"identifier" => identifier} ->
          identifier
        end)

      assert movement_identifiers == expected_identifiers
    end
  end

  describe "delete a user movement" do
    test "sucess!", _context do
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

      {:ok, %{data: %{"me" => %{"movements" => movements}}}} =
        Absinthe.run(@user_query, Schema, context: absinthe_context, variables: nil)

      movement_identifier_to_delete =
        movements
        |> List.first()
        |> Map.get("identifier")

      {:ok, %{data: %{"deleteMovement" => %{"__typename" => "DeleteMovementSuccess"}}}} =
        Absinthe.run(@delete_movement_mutation, Schema,
          context: absinthe_context,
          variables: %{"movement_identifier" => movement_identifier_to_delete}
        )
    end

    test "try to delete movement that does not exist!", _context do
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

      {:ok, %{data: %{"deleteMovement" => %{"__typename" => "DeleteMovementFailure"}}}} =
        Absinthe.run(@delete_movement_mutation, Schema,
          context: absinthe_context,
          variables: %{"movement_identifier" => UUID.string_to_binary!(UUID.uuid4())}
        )
    end

    test "try to delete a movement that does not belong to user", _context do
      {:ok,
       %{
         data: %{
           "login" => %{
             "__typename" => "LoginSuccess",
             "token" => token_main_user,
             "identifier" => main_user_identifier
           }
         }
       }} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @first_active_user_credential
        )

      main_user_absinthe_context =
        %{}
        |> Map.put(:authorization_token, token_main_user)
        |> Map.put(:current_user, %UserDomain{identifier: main_user_identifier})

      {:ok,
       %{
         data: %{
           "login" => %{
             "__typename" => "LoginSuccess",
             "token" => token_second_user,
             "identifier" => second_user_identifier
           }
         }
       }} =
        Absinthe.run(
          @login_mutation,
          Schema,
          context: nil,
          variables: @second_first_active_user_credential
        )

      second_user_absinthe_context =
        %{}
        |> Map.put(:authorization_token, token_second_user)
        |> Map.put(:current_user, %UserDomain{identifier: second_user_identifier})

      {:ok, %{data: %{"me" => %{"movements" => movements_second_user}}}} =
        Absinthe.run(@user_query, Schema, context: second_user_absinthe_context, variables: nil)

      movement_identifier_to_delete =
        movements_second_user
        |> List.first()
        |> Map.get("identifier")

      assert {:ok, %{data: %{"deleteMovement" => %{"__typename" => "DeleteMovementFailure"}}}} =
               Absinthe.run(@delete_movement_mutation, Schema,
                 context: main_user_absinthe_context,
                 variables: %{"movement_identifier" => movement_identifier_to_delete}
               )
    end
  end
end
