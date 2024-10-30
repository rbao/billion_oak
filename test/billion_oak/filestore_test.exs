defmodule BillionOak.FilestoreTest do
  use BillionOak.DataCase

  import Mox
  import BillionOak.Factory

  alias BillionOak.Filestore
  alias BillionOak.Filestore.{File, FileLocation}

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

  test "all files can be retrieved at once" do
    insert(:file)
    assert {:ok, files} = Filestore.list_files()
    assert length(files) == 1
  end

  describe "retrieving a file" do
    test "returns the file with the given id if exists" do
      file = insert(:file)
      assert {:ok, %File{}} = Filestore.get_file(file.id)
    end

    test "returns an error if no file is found with the given id" do
      assert {:error, :not_found} = Filestore.get_file("123")
    end
  end

  describe "registering a file" do
    test "returns the registered file if the given input is valid" do
      location = insert(:file_location)
      input = params_for(:file, location_id: location.id)
      expect(BillionOak.Filestore.ClientMock, :head_object, fn _ ->
        {:ok, [
          {"Content-Type", "binary/octet-stream"},
          {"Content-Length", "72516"}
        ]}
      end)

      assert {:ok, %File{} = file} = Filestore.register_file(input)
      assert file.id == location.id
      assert file.name == location.name
      assert file.organization_id == location.organization_id
      assert file.owner_id == location.owner_id
      assert file.content_type == "binary/octet-stream"
      assert file.size_bytes == 72516
    end
  end

  # describe "files" do
  #   alias BillionOak.Filestore.File

  #   import BillionOak.FilestoreFixtures

  #   @invalid_attrs %{name: nil, status: nil, organization_id: nil, owner_id: nil, content_type: nil, size_bytes: nil}

  #   test "list_files/0 returns all files" do
  #     file = file_fixture()
  #     assert Filestore.list_files() == [file]
  #   end

  #   test "get_file!/1 returns the file with given id" do
  #     file = file_fixture()
  #     assert Filestore.get_file!(file.id) == file
  #   end

  #   test "create_file/1 with valid data creates a file" do
  #     valid_attrs = %{name: "some name", status: "some status", organization_id: "some organization_id", owner_id: "some owner_id", content_type: "some content_type", size_bytes: "some size_bytes"}

  #     assert {:ok, %File{} = file} = Filestore.create_file(valid_attrs)
  #     assert file.name == "some name"
  #     assert file.status == "some status"
  #     assert file.organization_id == "some organization_id"
  #     assert file.owner_id == "some owner_id"
  #     assert file.content_type == "some content_type"
  #     assert file.size_bytes == "some size_bytes"
  #   end

  #   test "create_file/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Filestore.create_file(@invalid_attrs)
  #   end

  #   test "update_file/2 with valid data updates the file" do
  #     file = file_fixture()
  #     update_attrs = %{name: "some updated name", status: "some updated status", organization_id: "some updated organization_id", owner_id: "some updated owner_id", content_type: "some updated content_type", size_bytes: "some updated size_bytes"}

  #     assert {:ok, %File{} = file} = Filestore.update_file(file, update_attrs)
  #     assert file.name == "some updated name"
  #     assert file.status == "some updated status"
  #     assert file.organization_id == "some updated organization_id"
  #     assert file.owner_id == "some updated owner_id"
  #     assert file.content_type == "some updated content_type"
  #     assert file.size_bytes == "some updated size_bytes"
  #   end

  #   test "update_file/2 with invalid data returns error changeset" do
  #     file = file_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Filestore.update_file(file, @invalid_attrs)
  #     assert file == Filestore.get_file!(file.id)
  #   end

  #   test "delete_file/1 deletes the file" do
  #     file = file_fixture()
  #     assert {:ok, %File{}} = Filestore.delete_file(file)
  #     assert_raise Ecto.NoResultsError, fn -> Filestore.get_file!(file.id) end
  #   end

  #   test "change_file/1 returns a file changeset" do
  #     file = file_fixture()
  #     assert %Ecto.Changeset{} = Filestore.change_file(file)
  #   end
  # end
end
