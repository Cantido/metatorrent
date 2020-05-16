defmodule Metatorrent.SingleFileInfo do
  alias Metatorrent.Metainfo

  @moduledoc """
  A metadata file's `:info` block describing a single downloadable file.
  """

  @enforce_keys [:length, :name, :piece_length, :pieces]
  defstruct [:length, :md5sum, :name, :piece_length, :pieces]

  def new(fields) do
    struct(__MODULE__, update_info(fields))
  end

  def bytes_count(info) do
    info.length
  end

  defp update_info(info) when is_map(info) do
    info
    |> rename_keys(info_tokens())
    |> Map.update!(:pieces, &Metainfo.update_pieces/1)
  end

  defp info_tokens do
    %{
      "length" => :length,
      "name" => :name,
      "piece length" => :piece_length,
      "pieces" => :pieces
    }
  end

  def rename_keys(map, names) do
    for {key, val} <- map, into: %{}, do: {Map.get(names, key, key), val}
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(info, opts) do
      concat([
        "#Metatorrent.SingleFileInfo<[",
        to_doc(info.name, opts),
        "]>"
      ])
    end
  end
end
