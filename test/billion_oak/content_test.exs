defmodule BillionOak.ContentTest do
  use BillionOak.DataCase
  import BillionOak.Factory
  import Mox

  alias BillionOak.Content
  alias BillionOak.Content.Audio

  test "all audios can be retrieved at once" do
    insert(:audio)
    assert {:ok, audios} = Content.list_audios()
    assert length(audios) == 1
  end

  describe "retrieving an audio" do
    test "returns the audio with the given id if exists" do
      audio = insert(:audio)
      assert {:ok, %Audio{}} = Content.get_audio(audio.id)
    end

    test "returns an error if no audio is found with the given id" do
      assert {:error, :not_found} = Content.get_audio("some id")
    end
  end

  describe "creating an audio" do
    test "returns the created audio if the given input is valid" do
      file = insert(:file)
      input = params_for(:audio, primary_file_id: file.id, organization_id: file.organization_id)

      expect(BillionOak.Filestore.ClientMock, :presigned_url, fn _ ->
        {:ok, "url"}
      end)

      expect(BillionOak.Content.FFmpegMock, :media_metadata, fn _ ->
        %{duration_seconds: 100, bit_rate: 100}
      end)

      assert {:ok, %Audio{}} = Content.create_audio(input)
    end

    test "returns an error if the given input is invalid" do
      assert {:error, %Ecto.Changeset{}} = Content.create_audio(%{})
    end
  end

  describe "updating an audio" do
    test "returns the updated audio if the given input is valid" do
      audio = insert(:audio)
      input = %{title: "some updated title"}
      assert {:ok, %Audio{} = audio} = Content.update_audio(audio, input)
      assert audio.title == input.title
    end

    test "returns an error if the given input is invalid" do
      audio = insert(:audio)
      assert {:error, %Ecto.Changeset{}} = Content.update_audio(audio, %{title: nil})
    end
  end

  test "deleting an audio" do
    audio = insert(:audio)

    assert {:ok, %Audio{}} = Content.delete_audio(audio)
    assert {:error, :not_found} = Content.get_audio(audio.id)
  end
end
