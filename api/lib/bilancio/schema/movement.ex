defmodule Bilancio.Schema.Movement do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  @type t() :: %__MODULE__{}

  schema "movements" do
    field :user_id, :integer
    field :category_id, :integer
    field :title, :string
    field :identifier, :string
    field :description, :string
    field :value, :float
    field :occurred_at, :date

    timestamps()
  end

  def get_by_user_id(query, user_id, nil) do
    from u in query,
      where: u.user_id == ^user_id
  end

  def get_by_user_id(query, user_id, order) do
    order_by =
      case order do
        %{type: :desc} -> [desc: Map.get(order, :by)]
        _ -> [asc: Map.get(order, :by)]
      end

    from u in query,
      where: u.user_id == ^user_id,
      order_by: ^order_by
  end

  def get_by_identifier_and_user_id(query, identifier, user_id) do
    from u in query,
      where: u.identifier == ^identifier and u.user_id == ^user_id,
      limit: 1
  end
end
