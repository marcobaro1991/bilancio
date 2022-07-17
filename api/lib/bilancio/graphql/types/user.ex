defmodule Bilancio.Graphql.Types.User do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias Bilancio.Graphql.Resolver.User
  alias Bilancio.Graphql.Middleware.UserAuthentication
  alias Noether.Either

  object :user_queries do
    field :me, :user do
      middleware(UserAuthentication)
      resolve(&User.me/2)
    end

    field :movement, :movement do
      arg :identifier, non_null(:uuid)
      middleware(UserAuthentication)
      resolve(&User.get_movement/2)
    end
  end

  object :user_mutations do
    field :login, non_null(:login_response) do
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      resolve(&User.login/2)
    end

    field :logout, non_null(:logout_response) do
      middleware(UserAuthentication)
      resolve(&User.logout/2)
    end

    field :deactivate_user, non_null(:deactivate_user_response) do
      middleware(UserAuthentication)
      resolve(&User.deactivate/2)
    end

    field :create_movement, non_null(:create_movement_response) do
      arg :movement, non_null(:input_movement)
      middleware(UserAuthentication)
      resolve(&User.create_movement/2)
    end

    field :delete_movement, non_null(:delete_movement_response) do
      arg :identifier, non_null(:uuid)
      middleware(UserAuthentication)
      resolve(&User.delete_movement/2)
    end
  end

  input_object :input_movement do
    field :title, non_null(:string)
    field :description, :string
    field :value, non_null(:float)
    field :occurred_at, non_null(:date)
  end

  input_object :movements_order do
    field :by, non_null(:movements_order_by)
    field :type, non_null(:movements_order_type)
  end

  object :user do
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :email, non_null(:string)

    field :identifier, non_null(:uuid) do
      resolve fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end
    end

    field :status, non_null(:user_status)
    field :registration_type, non_null(:user_registration_type)
    field :inserted_at, non_null(:datetime)

    field :movements, type: non_null(list_of(:movement)) do
      arg :order, :movements_order
      resolve(&User.movements/2)
    end
  end

  object :movement do
    field :title, non_null(:string)
    field :description, :string

    field :identifier, non_null(:uuid) do
      resolve fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end
    end

    field :value, non_null(:float)
    field :occurred_at, non_null(:date)
  end

  object :login_success, is_type_of: :login_response do
    field :token, non_null(:string)
    field :identifier, non_null(:string)
  end

  object :login_failure, is_type_of: :login_response do
    field :error, non_null(:login_error)
  end

  object :logout_success, is_type_of: :logout_response do
    field :message, non_null(:string)
  end

  object :logout_failure, is_type_of: :logout_response do
    field :error, non_null(:logout_error)
  end

  object :deactivate_user_success, is_type_of: :deactivate_user_response do
    field :message, non_null(:string)
  end

  object :deactivate_user_failure, is_type_of: :deactivate_user_response do
    field :error, non_null(:deactivate_user_error)
  end

  object :movement_not_created, is_type_of: :create_movement_response do
    field :error, non_null(:movement_created_error)
  end

  object :delete_movement_success, is_type_of: :delete_movement_response do
    field :message, non_null(:string)
  end

  object :delete_movement_failure, is_type_of: :delete_movement_response do
    field :error, non_null(:string)
  end

  union :login_response do
    types [:login_success, :login_failure]

    resolve_type fn
      %{token: _}, _ -> :login_success
      %{error: _}, _ -> :login_failure
    end
  end

  union :logout_response do
    types [:logout_success, :logout_failure]

    resolve_type fn
      %{message: _}, _ -> :logout_success
      _, _ -> :logout_failure
    end
  end

  union :deactivate_user_response do
    types [:deactivate_user_success, :deactivate_user_failure]

    resolve_type fn
      %{message: _}, _ -> :deactivate_user_success
      _, _ -> :deactivate_user_failure
    end
  end

  union :create_movement_response do
    types [:movement, :movement_not_created]

    resolve_type fn
      %{error: _}, _ -> :movement_not_created
      _, _ -> :movement
    end
  end

  union :delete_movement_response do
    types [:delete_movement_success, :delete_movement_failure]

    resolve_type fn
      %{error: _}, _ -> :delete_movement_failure
      _, _ -> :delete_movement_success
    end
  end

  enum :login_error do
    value :already_logged_in
    value :wrong_credential
    value :unknown
  end

  enum :logout_error do
    value :token_not_stored
    value :unknown
  end

  enum :deactivate_user_error do
    value :unknown
  end

  enum :movement_created_error do
    value :unknown
  end

  enum :user_status do
    value :active
    value :not_active
  end

  enum :user_registration_type do
    value :default
    value :google
  end

  enum :movements_order_by do
    value :occurred_at
    value :value
    value :title
  end

  enum :movements_order_type do
    value :asc
    value :desc
  end
end
