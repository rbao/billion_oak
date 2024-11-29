defmodule BillionOakTest do
  use BillionOak.DataCase
  import Mox
  import BillionOak.Factory
  alias BillionOak.Request

  def anyone(attrs) do
    attrs = Enum.into(attrs, %{})
    Map.merge(%Request{}, attrs)
  end

  def anonymous(client, attrs) do
    anyone(attrs)
    |> Map.put(:client_id, client.id)
  end

  def user(user, client, attrs \\ %{}) do
    anyone(attrs)
    |> Map.put(:client_id, client.id)
    |> Map.put(:requester_id, user.id)
  end

  def sysops(attrs) do
    anyone(attrs)
    |> Map.put(:_role_, :sysops)
  end

  test "anyone can verify client" do
    client = insert(:client)
    data = %{secret: client.secret}
    identifier = %{id: client.id}
    req = anyone(%{identifier: identifier, data: data})

    result = BillionOak.verify_client(req)

    assert {:ok, %{data: client}} = result
    assert client.id == client.id
  end

  test "anonymous user can become guest" do
    client = insert(:client)
    data = %{wx_app_openid: "openid"}
    req = anonymous(client, %{data: data})

    result = BillionOak.get_or_create_user(req)

    assert {:ok, %{data: user}} = result
    assert user.role == :guest
    assert user.wx_app_openid == "openid"
  end

  describe "guest" do
    test "can sign up to become a member" do
      client = insert(:client)

      guest =
        insert(:user,
          role: :guest,
          company_account_id: nil,
          organization_id: client.organization_id
        )

      company_account = insert(:company_account, organization_id: client.organization_id)

      invitation_code =
        insert(:invitation_code,
          organization_id: client.organization_id,
          invitee_company_account_rid: company_account.rid
        )

      data = %{
        company_account_rid: company_account.rid,
        invitation_code: invitation_code.value,
        first_name: "John",
        last_name: "Doe"
      }

      req = user(guest, client, %{data: data})

      result = BillionOak.sign_up(req)

      assert {:ok, %{data: member}} = result
      assert member.role == :member
      assert member.company_account_id == company_account.id
      assert member.first_name == data.first_name
      assert member.last_name == data.last_name
    end

    test "can get published audio" do
      client = insert(:client)
      guest = insert(:user, role: :guest, organization_id: client.organization_id)
      audio = insert(:audio, status: :published, organization_id: client.organization_id)
      req = user(guest, client, %{identifier: %{id: audio.id}})

      result = BillionOak.get_audio(req)

      assert {:ok, %{data: audio}} = result
      assert audio.id == audio.id
    end

    test "can get sharer" do
      client = insert(:client)
      sharer = insert(:user, role: :member, organization_id: client.organization_id)
      guest = insert(:user, role: :guest, organization_id: client.organization_id)
      req = user(guest, client, %{identifier: %{id: sharer.share_id}})

      result = BillionOak.get_sharer(req)

      assert {:ok, %{data: sharer}} = result
      assert sharer.id == sharer.id
    end

    test "can list files base on ids" do
      client = insert(:client)
      file = insert(:file, organization_id: client.organization_id)
      guest = insert(:user, role: :guest, organization_id: client.organization_id)
      filter = [%{id: [file.id]}]
      req = user(guest, client, %{filter: filter})

      expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
        {:ok, "url"}
      end)

      result = BillionOak.list_files(req)

      assert {:ok, %{data: [file]}} = result
      assert file.id == file.id
    end
  end

  describe "member" do
    test "can list published audios" do
      client = insert(:client)
      member = insert(:user, role: :member, organization_id: client.organization_id)
      insert_list(3, :audio, status: :published, organization_id: client.organization_id)
      insert_list(3, :audio, status: :draft, organization_id: client.organization_id)
      req = user(member, client)

      result = BillionOak.list_audios(req)

      assert {:ok, %{data: audios}} = result
      assert length(audios) == 3
    end

    test "can get their own user detail" do
      client = insert(:client)
      member = insert(:user, role: :member, organization_id: client.organization_id)
      identifier = %{id: member.id}
      req = user(member, client, %{identifier: identifier})

      result = BillionOak.get_user(req)

      assert {:ok, %{data: user}} = result
      assert user.id == member.id
    end

    test "can update their user detail" do
      client = insert(:client)
      member = insert(:user, role: :member, organization_id: client.organization_id)
      req = user(member, client, %{data: %{first_name: "Updated"}})

      result = BillionOak.update_current_user(req)

      assert {:ok, %{data: user}} = result
      assert user.first_name == "Updated"
    end

    test "can get their own company account" do
      client = insert(:client)
      company_account = insert(:company_account, organization_id: client.organization_id)

      member =
        insert(:user,
          role: :member,
          organization_id: client.organization_id,
          company_account_id: company_account.id
        )

      filter = [%{id: [company_account.id]}]
      req = user(member, client, %{filter: filter})

      result = BillionOak.list_company_accounts(req)

      assert {:ok, %{data: [member_company_account]}} = result
      assert member_company_account.id == company_account.id
    end
  end

  describe "admin" do
    test "can reserve a file location" do
      client = insert(:client)
      admin = insert(:user, role: :admin, organization_id: client.organization_id)
      data = %{name: "test.txt", content_type: "text/plain"}
      req = user(admin, client, %{data: data})

      expect(BillionOak.Filestore.ClientMock, :presigned_post, fn key, custom_conditions ->
        BillionOak.Filestore.S3Client.presigned_post(key, custom_conditions)
      end)

      result = BillionOak.reserve_file_location(req)

      assert {:ok, %{data: location}} = result
      assert location.id
      assert location.name == data.name
      assert location.form_fields
      assert location.form_url
    end

    test "can register a file" do
      client = insert(:client)
      admin = insert(:user, role: :admin, organization_id: client.organization_id)
      location = insert(:file_location, owner_id: admin.id, organization_id: client.organization_id)
      data = %{location_id: location.id}
      req = user(admin, client, %{data: data})

      expect(BillionOak.Filestore.ClientMock, :head_object, fn _ ->
        {:ok, %{"Content-Type" => "text/plain", "Content-Length" => "100"}}
      end)

      expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
        {:ok, "url"}
      end)

      result = BillionOak.register_file(req)

      assert {:ok, %{data: file}} = result
      assert file.id
      assert file.name == location.name
    end

    test "can create an audio" do
      client = insert(:client)
      admin = insert(:user, role: :admin, organization_id: client.organization_id)
      file = insert(:file, organization_id: client.organization_id)
      data = params_for(:audio, primary_file_id: file.id)
      req = user(admin, client, %{data: data})

      expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
        {:ok, "url"}
      end)

      expect(BillionOak.Content.FFmpegMock, :media_metadata, fn _ ->
        %{duration_seconds: 100, bit_rate: 100}
      end)

      result = BillionOak.create_audio(req)

      assert {:ok, %{data: audio}} = result
      assert audio.id
      assert audio.primary_file_id == file.id
      assert audio.duration_seconds == 100
      assert audio.bit_rate == 100
    end

    test "can create an invitation code" do
      client = insert(:client)
      company_account = insert(:company_account, organization_id: client.organization_id)
      admin = insert(:user, role: :admin, organization_id: client.organization_id)

      data = %{
        organization_id: company_account.organization_id,
        invitee_company_account_rid: company_account.rid
      }

      req = user(admin, client, %{data: data})

      result = BillionOak.create_invitation_code(req)

      assert {:ok, %{data: code}} = result
      assert String.length(code.value) == 6
    end
  end

  describe "system operator" do
    test "can create a company" do
      data = params_for(:company)
      req = sysops(%{data: data})

      result = BillionOak.create_company(req)

      assert {:ok, %{data: company}} = result
      assert company.handle == data.handle
    end

    test "can create an organization" do
      data = params_for(:organization)
      req = sysops(%{data: data})

      result = BillionOak.create_organization(req)

      assert {:ok, %{data: organization}} = result
      assert organization.handle == data.handle
    end

    test "can create a client" do
      data = params_for(:client)
      req = sysops(%{data: data})

      result = BillionOak.create_client(req)

      assert {:ok, %{data: client}} = result
      assert client.publishable_key
    end

    test "can get an organization's detail by handle" do
      req = sysops(%{identifier: %{handle: "happyteam"}})

      result = BillionOak.get_organization(req)

      assert {:ok, %{data: organization}} = result
      assert organization.handle == "happyteam"
    end

    test "can ingest external data" do
      identifier = %{handle: "happyteam"}
      req = sysops(%{identifier: identifier})

      expect(BillionOak.Filestore.ClientMock, :list_objects, fn _, _ ->
        {:ok, [%{key: "object_key"}]}
      end)

      expect(BillionOak.Filestore.ClientMock, :stream_object, fn "object_key" ->
        {:ok, File.stream!("test/support/fixtures/mannatech.mtku")}
      end)

      result = BillionOak.ingest_external_data(req)

      assert {:ok, %{data: data}} = result
      assert [{"object_key", {:ok, 20}}] = data
    end
  end
end
