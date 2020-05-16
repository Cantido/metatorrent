defmodule Metatorrent.Metainfo do
  alias Metatorrent.MultiFileInfo
  alias Metatorrent.SingleFileInfo

  @moduledoc """
  Functions for working with a BitTorrent metadata file, AKA a torrent file.
  """

  @enforce_keys [:info_hash, :announce, :created_by, :info]
  defstruct [:info_hash, :announce, :announce_list, :comment, :created_by, :creation_date, :info]

  @doc """
  Decode a metadata binary into an Elixir data structure.
  """
  def decode(bin) do
    with {:ok, decoded} <- ExBencode.decode(bin),
         {:ok, info} <- ExBencode.encode(decoded["info"]),
         :ok <- check_info_block(info, bin) do
      info_hash = :crypto.hash(:sha, info)

      result =
        decoded
        |> Map.put(:info_hash, info_hash)
        |> rename_keys(key_tokens())
        |> Map.update!(:info, &update_info/1)
        |> Map.update(:nodes, [], &update_nodes/1)

      meta = struct(__MODULE__, result)
      {:ok, meta}
    else
      err -> err
    end
  end

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

  def rename_keys(map, names) do
    for {key, val} <- map, into: %{}, do: {Map.get(names, key, key), val}
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(meta, opts) do
      concat([
        "#Metatorrent.Metainfo<[",
        to_doc(meta.info.name, opts),
        break(),
        Base.encode16(meta.info_hash, case: :lower),
        "]>"
      ])
    end
  end
end
