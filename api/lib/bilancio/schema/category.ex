defmodule Bilancio.Schema.Category do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Query

  @type t() :: %__MODULE__{}

  schema "categories" do
    field :title, :string
    field :color, :string
    field :user_id, :integer
    field :identifier, :string

    timestamps()
  end

  def get_by_id(query, id) do
    from u in query,
      where: u.id == ^id
  end

  def get_all_by_user_id(query, nil) do
    from u in query,
      where: is_nil(u.user_id)
  end

  def get_all_by_user_id(query, user_id) do
    from u in query, where: u.user_id == ^user_id, or_where: is_nil(u.user_id)
  end
end
