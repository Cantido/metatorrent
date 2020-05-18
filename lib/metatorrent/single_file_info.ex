defmodule Metatorrent.SingleFileInfo do
  @moduledoc """
  A metadata file's `:info` block describing a single downloadable file.

  ## Keys

  - `:length` - The length of the downloadable file.
  - `:name` - The name of the downloadable file.
  - `:piece_length` - The nominal length of each piece.
     Note that the length of the final piece of the file will likely be shorter than this.
  - `:pieces` - A list of twenty-byte SHA-1 hashes of each piece.
  """

  @enforce_keys [:length, :name, :piece_length, :pieces]
  defstruct [:length, :md5sum, :name, :piece_length, :pieces]

  @doc false
  def new(fields) do
    struct(__MODULE__, update_info(fields))
  end

  @doc false
  def bytes_count(info) do
    info.length
  end

  defp update_info(info) when is_map(info) do
    info
    |> Metatorrent.rename_keys(info_tokens())
    |> Map.update!(:pieces, &Metatorrent.update_pieces/1)
  end

  defp info_tokens do
    %{
      "length" => :length,
      "name" => :name,
      "piece length" => :piece_length,
      "pieces" => :pieces
    }
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
