defmodule Metatorrent do
  alias Metatorrent.MultiFileInfo
  alias Metatorrent.SingleFileInfo

  @moduledoc """
  Decodes BitTorrent metainfo files.

  The `Metatorrent` module can be used to decode a binary read from a file ending in `.torrent`.

      iex> {:ok, metainfo} = Metatorrent.decode(File.read! "test/linuxmint-18.3-cinnamon-64bit.iso.torrent")
      ...> metainfo
      #Metatorrent.Metainfo<["linuxmint-18.3-cinnamon-64bit.iso" d2e53fb603652d991991b6ad2357a7a2845a5319]>

   Metatorrent also sticks some additional useful information into the map,
   like `:info_hash`, and the total `:length` for multi-file torrents.
   The data structure looks like this:

      %Metatorrent.Metainfo{
        announce: "https://torrents.linuxmint.com/announce.php",
        announce_list: nil,
        comment: nil,
        created_by: "Transmission/2.84 (14307)",
        creation_date: 1511774851,
        info: %Metatorrent.SingleFileInfo{
          length: 1899528192,
          md5sum: nil,
          name: "linuxmint-18.3-cinnamon-64bit.iso",
          piece_length: 1048576,
          pieces: [
            <<167, 53, 69, 58, 13, 103, 134, 251, 174, 104, 105, 210, 94, 112, 197, 52,
        205, 246, 155, 130>>,
            ...
          ]
        },
        info_hash: <<210, 229, 63, 182, 3, 101, 45, 153, 25, 145, 182, 173, 35, 87,
          167, 162, 132, 90, 83, 25>>
      }

  """


  @doc """
  Decodes a metadata binary into an Elixir data structure.

  ## Examples

      iex> {:ok, metainfo} = Metatorrent.decode(File.read! "test/linuxmint-18.3-cinnamon-64bit.iso.torrent")
      ...> metainfo
      #Metatorrent.Metainfo<["linuxmint-18.3-cinnamon-64bit.iso" d2e53fb603652d991991b6ad2357a7a2845a5319]>
  """
  def decode(bin) do
    with {:ok, decoded} <- ExBencode.decode(bin),
         {:ok, info} <- ExBencode.encode(decoded["info"]),
         :ok <- check_info_block(info, bin),
         {:ok, creation_date} <- DateTime.from_unix(decoded["creation date"])  do
      info_hash = :crypto.hash(:sha, info)

      result =
        decoded
        |> Map.put(:info_hash, info_hash)
        |> rename_keys(key_tokens())
        |> Map.put(:creation_date, creation_date)
        |> Map.update!(:info, &update_info/1)
        |> Map.update(:announce_list, [], &update_announce_list/1)
        |> Map.update(:nodes, [], &update_nodes/1)

      meta = struct(Metatorrent.Metainfo, result)
      {:ok, meta}
    else
      err -> err
    end
  end

  @doc false
  def bytes_count(meta) do
    if Map.has_key?(meta.info, :files) do
      MultiFileInfo.bytes_count(meta.info)
    else
      SingleFileInfo.bytes_count(meta.info)
    end
  end

  defp check_info_block(ours, bin)
       when is_binary(ours) and is_binary(bin) and byte_size(ours) < byte_size(bin) do
    case :binary.match(bin, ours) do
      :nomatch -> {:error, :malformed_info_dict}
      {_start, _length} -> :ok
    end
  end

  defp update_info(info) do
    if Map.has_key?(info, "files") do
      MultiFileInfo.new(info)
    else
      SingleFileInfo.new(info)
    end
  end

  defp update_announce_list(nil) do
    []
  end

  defp update_announce_list(announce_list) do
    announce_list
  end

  defp update_nodes(nodes) when is_list(nodes) do
    Enum.each(nodes, fn [host, port] ->
      {host, port}
    end)
  end

  defp key_tokens do
    %{
      "announce" => :announce,
      "announce-list" => :announce_list,
      "created by" => :created_by,
      "creation date" => :creation_date,
      "encoding" => :encoding,
      "info" => :info,
      "nodes" => :nodes
    }
  end

  @doc false
  def update_pieces(pieces) when is_binary(pieces) do
    binary_chunk(pieces)
  end

  defp binary_chunk(<<>>) do
    [<<>>]
  end

  defp binary_chunk(<<bin::binary-size(20)>>) do
    [bin]
  end

  defp binary_chunk(<<head::binary-size(20), rest::binary>>) when rem(byte_size(rest), 20) == 0 do
    [head | binary_chunk(rest)]
  end

  @doc false
  def rename_keys(map, names) do
    for {key, val} <- map, into: %{}, do: {Map.get(names, key, key), val}
  end
end
