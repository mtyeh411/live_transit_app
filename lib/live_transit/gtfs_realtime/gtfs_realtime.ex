defmodule GtfsRealtime do
  use Protobuf, from: Path.expand("./gtfs_realtime.proto", __DIR__)
end
