defmodule Metatorrent do
  alias Metatorrent.MultiFileInfo
  alias Metatorrent.SingleFileInfo


  def decode(bin) do
    Metatorrent.Metainfo.decode(bin)
  end
end
