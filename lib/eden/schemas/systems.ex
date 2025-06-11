defmodule Eden.Schemas.System do
  use Ecto.Schema
  import Ecto.Changeset

  schema "systems" do
    field :name, :string
    field :system_address, :integer
    field :position_x, :float
    field :position_y, :float
    field :position_z, :float

    timestamps()
  end

  def changeset(system, params \\ %{}) do
    params =
      params
      |> get_positions()
      |> get_system_address()
      |> get_system_name()

    changeset = system
    |> cast(params, [
      :name,
      :system_address,
      :position_x,
      :position_y,
      :position_z
    ])
    |> validate_required([
      :name,
      :system_address,
      :position_x,
      :position_y,
      :position_z
    ])
    |> unique_constraint([:system_address])

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset}
    end
  end

  defp get_system_name(params) do
    case Map.get(params, "StarSystem") || Map.get(params, "SystemName") ||
           Map.get(params, "System") do
      system_name when is_binary(system_name) ->
        params
        |> Map.put("name", system_name)

      _ ->
        params
    end
  end

  defp get_system_address(params) do
    case Map.get(params, "SystemAddress") do
      system_address when is_integer(system_address) ->
        params
        |> Map.put("system_address", system_address)

      _ ->
        params
    end
  end

  defp get_positions(params) do
    case Map.get(params, "StarPos") do
      [x, y, z] ->
        params
        |> Map.put("position_x", x)
        |> Map.put("position_y", y)
        |> Map.put("position_z", z)

      _ ->
        params
    end
  end
end
