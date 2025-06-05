defmodule Eden.Repo.Migrations.AddSystemsTable do
  use Ecto.Migration

  def change do
    create table(:systems) do
      add :name, :string, null: false
      add :system_address, :bigint, null: false
      add :position_x, :float, null: false
      add :position_y, :float, null: false
      add :position_z, :float, null: false

      timestamps()
    end

    create unique_index(:systems, [:system_address])
    create index(:systems, [:name])
  end
end
