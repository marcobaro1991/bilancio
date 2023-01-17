defmodule Bilancio.Repo.Migrations.AddCategoryIdToMovementsTable do
  use Ecto.Migration

  def up do
    alter table(:movements) do
      add(:category_id, references("categories"))
    end
  end

  def down do
    alter table(:movements) do
      remove :category_id
    end
  end
end
