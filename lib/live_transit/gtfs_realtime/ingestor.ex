defmodule GtfsRealtime.Ingestor do

  def ingest(url, last_ingested_at \\ DateTime.to_unix(DateTime.utc_now())-60) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect url, label: "Successfully fetched feed"
        GtfsRealtime.FeedMessage.decode(body)
        |> processable?(last_ingested_at)
        |> process_entity
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.inspect url, label: "Feed not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason, label: "Failed to fetch feed"
    end
  end

  defp processable?(feed, last_ingested_at) do
    if feed.header.timestamp > last_ingested_at do
      {:ok, feed}
    else
      {:error, 'Current feed is older than previous feed.'}
    end
  end

  #defp process_entity({:ok, %GtfsRealtime.FeedMessage{entity: entity}}) when is_list(entity) and Enum.any?(entity) do
  defp process_entity({:error, message}) do
    IO.puts "Error: #{message}"
  end
  defp process_entity({:ok, feed}) do
    {:ok, Enum.map(feed.entity, &serialize_entity/1) }
  end

  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: false, trip_update: trip_update, vehicle: nil}) do
    stop_time_update = Enum.at(trip_update.stop_time_update, 0)
    Poison.encode!(%{trip_id: trip_update.trip.trip_id,
                    delay: stop_time_update.arrival.delay,
                    uncertainty: stop_time_update.arrival.uncertainty
                  })
  end

  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: false, trip_update: nil, vehicle: vehicle_update, id: entity_id}) do
    # NOTE: trip headsign & route short name can be looked up from GTFS by trip_id
    Poison.encode!(%{type: "Feature",
                     properties: %{
                       id: entity_id,
                       timestamp: vehicle_update.timestamp,
                       trip_id: vehicle_update.trip.trip_id,
                       stop_id: vehicle_update.stop_id,
                       vehicle_id: vehicle_update.vehicle.id,
                       bearing: vehicle_update.position.bearing,
                     },
                     geometry: %{
                       type: "Point",
                       coordinates: [vehicle_update.position.longitude, vehicle_update.position.latitude]
                     }
                   })
  end

  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: true}) do
    # TODO
  end
end
