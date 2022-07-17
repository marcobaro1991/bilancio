defmodule Bilancio.Repo.Migrations.AddMovements do
  use Ecto.Migration

  def up do
    create table(:movements) do
      add(:user_id, references("users"))
      add(:title, :string, null: false)
      add(:identifier, :uuid, null: false)
      add(:description, :text, null: true)
      add(:value, :float, null: false)
      add(:occurred_at, :date, null: false)

      timestamps(default: fragment("NOW()"))
    end
  end

  def down do
    drop(table(:movements))
  end
end
