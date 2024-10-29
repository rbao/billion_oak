defmodule BillionOak.FilestoreTest do
  use BillionOak.DataCase

  import Mox
  import BillionOak.Factory

  alias BillionOak.Filestore
  alias BillionOak.Filestore.FileLocation

  test "all file locations can be retrieved at once" do
    insert(:file_location)
    assert {:ok, file_locations} = Filestore.list_locations()
    assert length(file_locations) == 1
  end

  describe "retriving a file location" do
    test "returns the file location with the given id if exists" do
      file_location = insert(:file_location)
      assert {:ok, %FileLocation{}} = Filestore.get_location(file_location.id)
    end

    test "returns an error if no file location is found with the given id" do
      assert {:error, :not_found} = Filestore.get_location("123")
    end
  end

  describe "reserving a file location" do
    test "returns a file location if the given input is valid" do
      input = params_for(:file_location)

      expect(BillionOak.Filestore.ClientMock, :presigned_post, fn key, custom_conditions ->
        BillionOak.Filestore.S3Client.presigned_post(key, custom_conditions)
      end)

      assert {:ok, %FileLocation{}} = Filestore.reserve_location(input)
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Filestore.reserve_location(%{})
    end
  end

  describe "updating a file location" do
    test "returns the updated file location if the given input is valid" do
      file_location = insert(:file_location)
      input = %{name: "some updated name"}

      expect(BillionOak.Filestore.ClientMock, :presigned_post, fn key, custom_conditions ->
        BillionOak.Filestore.S3Client.presigned_post(key, custom_conditions)
      end)

      assert {:ok, %FileLocation{} = file_location} =
               Filestore.update_location(file_location, input)

      assert file_location.name == input.name
    end

    test "returns an error if the given input is invalid" do
      file_location = insert(:file_location)
      assert {:error, %Ecto.Changeset{}} = Filestore.update_location(file_location, %{name: nil})
    end
  end

  test "a file location can be deleted" do
    file_location = insert(:file_location)
    assert {:ok, %FileLocation{}} = Filestore.delete_location(file_location)
  end
end
