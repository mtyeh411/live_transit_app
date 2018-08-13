defmodule GtfsRealtime.Scheduler do
  use GenServer

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, Map.put(init_state, :attempts, []), name: :scheduler)
  end

  def init(state) do
    IO.inspect state, label: "init state"
    schedule_ingestion(state.interval)
    {:ok, state}
  end

  ##
  # public interface
  ##
  def inspect do
    GenServer.call(:scheduler, :inspect)
  end

  def ingest do
    GenServer.cast(:scheduler, :ingest)
  end

  ##
  # GenServer handlers
  ##
  def handle_call(:inspect, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:ingest, state) do
    {:noreply, %{state | attempts: track_attempt(state.attempts)}}
  end

  def handle_info(:schedule_ingestion, state) do
    GtfsRealtime.Worker.execute
    # TODO set state.last_ingested_at from feed.header.timestamp
    timestamp = DateTime.utc_now
    schedule_ingestion(state.interval)
    {:noreply, %{state | attempts: track_attempt(state.attempts, timestamp)}}
  end

  ###
  # private functions
  ###
  defp schedule_ingestion(interval \\ 30*1000) do
    Process.send_after(self(), :schedule_ingestion, interval)
  end

  defp track_attempt(attempts, timestamp \\ DateTime.utc_now) do
    [timestamp | attempts]
  end

end
