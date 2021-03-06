# Metatorrent

[![Travis (.com)](https://img.shields.io/travis/cantido/metatorrent)](https://travis-ci.com/github/Cantido/metatorrent)
[![Hex.pm](https://img.shields.io/hexpm/v/metatorrent)](https://hex.pm/packages/metatorrent)
![Hex.pm](https://img.shields.io/hexpm/l/metatorrent)

A BitTorrent metainfo decoder.

Metatorrent decodes metainfo files (also known as .torrent files),
and sticks some additional useful information into the map,
like the info hash, and the total length for multi-file torrents.

For example, here's the [linuxmint-18.3-cinnamon-64bit.iso](https://linuxmint.com/edition.php?id=246) metainfo file, decoded:

```elixir
iex> Metatorrent.decode(File.read! "linuxmint-18.3-cinnamon-64bit.iso.torrent")
%Metatorrent.Metainfo{
  announce: "https://torrents.linuxmint.com/announce.php",
  announce_list: [],
  nodes: [],
  comment: nil,
  created_by: "Transmission/2.84 (14307)",
  creation_date: ~U[2017-11-27 09:27:31Z],
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
```

### Supported BEPs

This library was built for [Effusion](https://github.com/cantido/effusion)
and so only supports the BEPs that Effusion supports.
[Full list of BEPs](http://www.bittorrent.org/beps/bep_0000.html).

| BEP | description |
| --- | --- |
| 0003 | The BitTorrent Protocol Specification |
| 0005 | DHT Protocol |
| 0012 | Multitracker Metadata Extension |

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `metatorrent` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:metatorrent, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/metatorrent](https://hexdocs.pm/metatorrent).

## License

Copyright © 2020 Rosa Richter

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
