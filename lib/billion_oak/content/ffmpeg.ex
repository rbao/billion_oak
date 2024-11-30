defmodule BillionOak.Content.IFFmpeg do
  @callback media_metadata(binary()) :: integer() | nil
end

defmodule BillionOak.Content.FFmpeg do
  alias BillionOak.Content.{IFFmpeg, DefaultFFmpeg}

  @behaviour IFFmpeg
  @ffmpeg Application.compile_env(:billion_oak, __MODULE__, DefaultFFmpeg)

  defdelegate media_metadata(url), to: @ffmpeg
end

defmodule BillionOak.Content.DefaultFFmpeg do
  require Logger
  alias BillionOak.Content.IFFmpeg
  @behaviour IFFmpeg

  def probe(url) do
    args = ["-output_format", "json", "-show_format", "-loglevel", "panic", url]

    case System.cmd("ffprobe", args) do
      {result, 0} ->
        json_output = Jason.decode!(result)
        {:ok, Map.get(json_output, "format", %{})}

      {result, code} ->
        Logger.warning("FFprobe failed with #{result} and code #{code}")
        {:error, {result, code}}
    end
  end

  @impl IFFmpeg
  def media_metadata(url) do
    case probe(url) do
      {:ok, metadata} ->
        metadata
        |> Map.take(["duration", "bit_rate"])
        |> Enum.reduce(%{}, fn
          {_, nil}, acc ->
            acc

          {"duration", duration}, acc ->
            duration_seconds = duration |> String.to_float() |> ceil()
            Map.put(acc, :duration_seconds, duration_seconds)

          {"bit_rate", bit_rate}, acc ->
            Map.put(acc, :bit_rate, String.to_integer(bit_rate))
        end)

      _ ->
        nil
    end
  end
end
