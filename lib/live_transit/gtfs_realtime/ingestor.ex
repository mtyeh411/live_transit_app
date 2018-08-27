defmodule GtfsRealtime.Ingestor do

  def ingest(url, last_ingested_at \\ -1) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect url, label: "Successfully fetched feed"
        GtfsRealtime.FeedMessage.decode(body)
        |> processable?(last_ingested_at || -1)
        |> process_entity
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Feed not found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch feed (#{reason})"}
    end
  end

  defp processable?(feed, last_ingested_at) do
    IO.inspect last_ingested_at, label: 'previous feed'
    IO.inspect feed.header.timestamp, label: 'current feed'
    if feed.header.timestamp > last_ingested_at do
      {:ok, feed}
    else
      {:error, 'Current feed is older than previous feed.'}
    end
  end

  #defp process_entity({:ok, %GtfsRealtime.FeedMessage{entity: entity}}) when is_list(entity) and Enum.any?(entity) do
  defp process_entity({:error, message}) do
    {:error, message}
  end
  defp process_entity({:ok, feed}) do
    updates = Enum.map(feed.entity, &serialize_entity/1)
             |> Enum.group_by(fn e -> e.update_type end)

    {:ok, %{
        timestamp: feed.header.timestamp,
        updates: updates
      }
    }
  end

  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: false, trip_update: trip_update, vehicle: nil}) do
    stop_time_update = Enum.at(trip_update.stop_time_update, 0)
    %{
      update_type: "trip",
      trip_id: trip_update.trip.trip_id,
      delay: stop_time_update.arrival.delay,
      uncertainty: stop_time_update.arrival.uncertainty
    }
  end
  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: false, trip_update: nil, vehicle: vehicle_update, id: entity_id}) do
    # NOTE: trip headsign & route short name can be looked up from GTFS by trip_id
    %{
      update_type: "vehicle",
      type: "Feature",
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
    }
  end
  defp serialize_entity(%GtfsRealtime.FeedEntity{is_deleted: true}) do
    # TODO
  end
end
