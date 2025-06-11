defmodule Eden.Schemas.SystemTest do
  use Eden.DataCase, async: true

  alias Eden.Schemas
  alias Eden.Schemas.System

  describe "System schema" do
    test "changeset with valid attributes creates a valid changeset" do
      params = %{
        name: "Sol",
        system_address: 123_456_789,
        position_x: 0.0,
        position_y: 0.0,
        position_z: 0.0
      }

      assert {:ok, _changeset} =
               Schemas.System.changeset(%System{}, params)
    end

    test "changeset without name returns errors" do
      params = %{
        system_address: 123_456_789,
        position_x: 0.0,
        position_y: 0.0,
        position_z: 0.0
      }

      assert {:error, changeset} =
               Schemas.System.changeset(%System{}, params)

      assert changeset.errors[:name] == {"can't be blank", [{:validation, :required}]}
    end

    test "changeset without system_address returns errors" do
      params = %{
        name: "Sol",
        position_x: 0.0,
        position_y: 0.0,
        position_z: 0.0
      }

      assert {:error, changeset} =
               Schemas.System.changeset(%System{}, params)

      assert changeset.errors[:system_address] == {"can't be blank", [{:validation, :required}]}
    end

    test "changeset with invalid attributes returns errors" do
      params = %{
        name: "",
        system_address: 123_456_789,
        position_x: nil,
        position_y: nil,
        position_z: nil
      }

      assert {:error, changeset} =
               Schemas.System.changeset(%System{}, params)

      assert changeset.errors[:name] == {"can't be blank", [{:validation, :required}]}
      assert changeset.errors[:position_x] == {"can't be blank", [{:validation, :required}]}
      assert changeset.errors[:position_y] == {"can't be blank", [{:validation, :required}]}
      assert changeset.errors[:position_z] == {"can't be blank", [{:validation, :required}]}
    end

    test "changeset with duplicate system_address returns unique constraint error" do
      {:ok, _system} =
        Eden.Repo.insert(%System{
          name: "Sol",
          system_address: 123_456_789,
          position_x: 0.0,
          position_y: 0.0,
          position_z: 0.0
        })

      params = %{
        name: "Sirius",
        system_address: 123_456_789,
        position_x: 1.0,
        position_y: 1.0,
        position_z: 1.0
      }

      assert {:ok, changeset} =
               Schemas.System.changeset(%System{}, params)

      assert {:error, changeset} = Eden.Repo.insert(changeset)

      assert changeset.errors[:system_address] ==
               {"has already been taken",
                [
                  {:constraint, :unique},
                  {:constraint_name, "systems_system_address_index"}
                ]}
    end

    test "changeset with raw input data creates a valid changeset" do
      raw_params = %{
        "StarSystem" => "Sol",
        "SystemAddress" => 123_456_789,
        "StarPos" => [0.0, 0.0, 0.0]
      }

      assert {:ok, _changeset} =
               Schemas.System.changeset(%System{}, raw_params)
    end
  end
end
