defmodule Metatorrent.MultiFileInfo do
  @moduledoc """
  A metadata file's `:info` block describing mutliple downloadable files.

  ## Keys

  - `:length` - The cumulative size of all files in the torrent.
     This key is added by Metatorrent, and is the sum of all file lengths.
  - `:name` - The name of the torrent.
  - `:piece_length` - The nominal length of each piece.
  - `:files` - A list of maps describing each downloadable file in this torrent.
    - `:length` - The length of this file
    - `:path` - A list of directory names, with the final entry being the file's name
    - `:md5sum` - The MD5 hash of the file (not usually present).
  """

  @enforce_keys [:files, :name, :piece_length, :pieces]
  defstruct [:files, :name, :piece_length, :pieces, :length]

  @doc false
  def new(fields) do
    struct(__MODULE__, update_info(fields))
  end

  @doc false
  def decode_md5sum(encoded) when byte_size(encoded) == 32 do
    Base.decode16!(encoded, case: :mixed)
  end

  @doc false
  def bytes_count(info) do
    Enum.count(info.pieces) * info.piece_length
  end

  defp update_info(info) when is_map(info) do
    info
    |> Metatorrent.rename_keys(info_tokens())
    |> Map.update!(:pieces, &Metatorrent.update_pieces/1)
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
    |> Metatorrent.rename_keys(file_tokens())
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
end
