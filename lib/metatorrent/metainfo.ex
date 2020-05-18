defmodule Metatorrent.Metainfo do

  @moduledoc """
  A BitTorrent Metainfo file.

  ## Keys

    - `:announce` - The main announce URL.
    - `:announce_list` - Additional announce URLs.
       Note that this list can contain nested lists in order to describe tracker priority.
       See http://www.bittorrent.org/beps/bep_0012.html for more information.
    - `:nodes` - DHT nodes to fetch additional metadata and peers for this torrent.
       See http://www.bittorrent.org/beps/bep_0005.html#torrent-file-extensions for more information.
    - `:comment` - The comment that the torrent creator added to the metainfo file.
    - `:created_by` - The software that assembled this metainfo file.
    - `:creation_date` - The timestamp that this metainfo file was created.
    - `:info` - Describes the files this metainfo file can be used to download. See `Metatorrent.SingleFileInfo` and `Metatorrent.MultiFileInfo`.
    - `:info_hash` - The SHA-1 hash of the bencoded `:info` block, used to identify this torrent.
       This key is added by Metatorrent because it must be derived from the `:info` block and so is not directly present in the metainfo file.


  For more information about the metainfo file format, see http://www.bittorrent.org/beps/bep_0003.html#metainfo-files.
  """

  @enforce_keys [:info_hash, :announce, :created_by, :info]
  defstruct [:info_hash, :announce, :announce_list, :comment, :created_by, :creation_date, :info]

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
