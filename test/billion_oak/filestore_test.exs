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

    expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
      {:ok, "url"}
    end)

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

      input = %{
        location_id: location.id,
        owner_id: location.owner_id,
        organization_id: location.organization_id
      }

      expect(BillionOak.Filestore.ClientMock, :head_object, fn _ ->
        {:ok,
         [
           {"Content-Type", "binary/octet-stream"},
           {"Content-Length", "72516"}
         ]}
      end)

      expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
        {:ok, "url"}
      end)

      assert {:ok, %File{} = file} = Filestore.register_file(input)
      assert file.id == location.id
      assert file.name == location.name
      assert file.organization_id == location.organization_id
      assert file.owner_id == location.owner_id
      assert file.content_type == "binary/octet-stream"
      assert file.size_bytes == 72516
      assert file.url == "url"
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Filestore.register_file(%{})
    end
  end

  describe "updating a file" do
    test "returns the updated file if the given input is valid" do
      file = insert(:file)
      input = %{status: :deleted}

      assert {:ok, %File{} = file} = Filestore.update_file(file, input)
      assert file.status == :deleted
    end

    test "returns an error if the given input is invalid" do
      file = insert(:file)
      assert {:error, %Ecto.Changeset{}} = Filestore.update_file(file, %{status: nil})
    end
  end

  test "a file can be deleted" do
    file = insert(:file)
    assert {:ok, %File{}} = Filestore.delete_file(file)
  end
end
