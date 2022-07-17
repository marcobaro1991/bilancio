defmodule Bilancio.Repo.Migrations.AddCategoriesTable do
  use Ecto.Migration

  def up do
    create table(:categories) do
      add(:title, :string, null: false)
      add(:user_id, references("users"), null: true)
      add(:color, :string, null: true)
      add(:identifier, :uuid, null: false)
      timestamps(default: fragment("NOW()"))
    end
  end

  def down do
    drop(table(:categories))
  end
end
