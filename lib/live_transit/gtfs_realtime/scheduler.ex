defmodule GtfsRealtime.Scheduler do
  use GenServer

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, init_state, name: :scheduler)
  end

  def init(state) do
    IO.inspect state, label: "init state"
    schedule_ingestion(state.interval)
    {:ok, Map.merge(state, %{last_ingested_at: nil, last_failed_at: nil})}
  end

  ##
  # public interface
  ##
  def inspect do
    GenServer.call(:scheduler, :inspect)
  end

  ##
  # GenServer handlers
  ##
  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:ingest, state) do
    url = Application.get_env(:live_transit, GtfsRealtime)[:url]
    attempted_at = DateTime.to_unix(DateTime.utc_now())

    case GtfsRealtime.Ingestor.ingest(url, state.last_ingested_at) do
      {:ok, serialized_feed} ->
        LiveTransitWeb.Endpoint.broadcast! "gtfsr:updates", "new_update", %{body: serialized_feed}
        schedule_ingestion(state.interval)
        {:noreply, %{
            state |
            last_ingested_at: serialized_feed.timestamp
          }
        }
      {:error, message} ->
        IO.inspect message, label: url
        schedule_ingestion(state.interval)
        {:noreply, %{
            state |
            last_failed_at: attempted_at
          }
        }
    end
  end

  ###
  # private functions
  ###
  defp schedule_ingestion(interval \\ 30*1000) do
    Process.send_after(self(), :ingest, interval)
  end

end
