defmodule GtfsRealtime.Worker do

  def execute() do
    # TODO add last_ingested_at from Scheduler
    case GtfsRealtime.Ingestor.ingest(Application.get_env(:live_transit, GtfsRealtime)[:url]) do
      {:ok, serialized_feed} ->
        LiveTransitWeb.Endpoint.broadcast! "gtfsr:updates", "new_update", %{body: serialized_feed}
    end
  end

end
