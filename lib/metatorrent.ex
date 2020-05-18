defmodule Metatorrent do
  def decode(bin) do
    Metatorrent.Metainfo.decode(bin)
  end
end
