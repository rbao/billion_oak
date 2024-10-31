defmodule BillionOak.Content.IFFmpeg do
  @callback duration_seconds(binary()) :: integer() | nil
end

defmodule BillionOak.Content.FFmpeg do
  alias BillionOak.Content.{IFFmpeg, DefaultFFmpeg}

  @behaviour IFFmpeg
  @ffmpeg Application.compile_env(:billion_oak, __MODULE__, DefaultFFmpeg)

  defdelegate duration_seconds(url), to: @ffmpeg
end

defmodule BillionOak.Content.DefaultFFmpeg do
  alias BillionOak.Content.IFFmpeg
  @behaviour IFFmpeg

  defp probe(url) do
    args = ["-output_format", "json", "-show_format", "-loglevel", "panic", url]

    case System.cmd("ffprobe", args) do
      {result, 0} ->
        json_output = Jason.decode!(result)
        {:ok, Map.get(json_output, "format", %{})}

      {result, code} ->
        {:error, {result, code}}
    end
  end

  @impl IFFmpeg
  def duration_seconds(url) do
    case probe(url) do
      {:ok, %{"duration" => duration}} ->
        duration
        |> String.to_float()
        |> ceil()

      _ ->
        nil
    end
  end
end
