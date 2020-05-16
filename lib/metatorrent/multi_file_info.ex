defmodule Metatorrent.MultiFileInfo do
  alias Metatorrent.Metainfo

  @moduledoc """
  A metadata file's `:info` block describing mutliple downloadable files.
  """

  @enforce_keys [:files, :name, :piece_length, :pieces]
  defstruct [:files, :name, :piece_length, :pieces, :length]

  def new(fields) do
    struct(__MODULE__, update_info(fields))
  end

  def decode_md5sum(encoded) when byte_size(encoded) == 32 do
    Base.decode16!(encoded, case: :mixed)
  end

  def bytes_count(info) do
    Enum.count(info.pieces) * info.piece_length
  end

  defp update_info(info) when is_map(info) do
    info
    |> rename_keys(info_tokens())
    |> Map.update!(:pieces, &Metainfo.update_pieces/1)
    |> Map.update!(:files, &update_files/1)
    |> put_total_length()
  end

  defp put_total_length(info) do
    Map.put(info, :length, total_length(info))
  end

  defp total_length(info) do
    info.files
    |> Enum.map(& &1.length)
    |> Enum.sum()
  end

  defp update_files(files) do
    Enum.map(files, &update_file/1)
  end

  defp update_file(file) do
    file
    |> rename_keys(file_tokens())
    |> Map.update(:md5sum, nil, &decode_md5sum/1)
  end

  defp info_tokens do
    %{
      "files" => :files,
      "name" => :name,
      "piece length" => :piece_length,
      "pieces" => :pieces
    }
  end

  defp file_tokens do
    %{
      "length" => :length,
      "path" => :path,
      "md5sum" => :md5sum
    }
  end

  def rename_keys(map, names) do
    for {key, val} <- map, into: %{}, do: {Map.get(names, key, key), val}
  end
end
