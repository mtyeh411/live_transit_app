defmodule LiveTransit.RealTimeFeed.ScheduledScraper do
  use GenServer

  def start_link(init_state) do
    GenServer.start_link(__MODULE__, Map.put(init_state, :attempts, []), name: :scraper)
  end

  def init(state) do
    schedule_next_scrape(state.interval)
    {:ok, state}
  end

  ##
  # public interface
  ##
  def get_state do
    GenServer.call(:scraper, :get_state)
  end

  def scrape do
    GenServer.cast(:scraper, :scrape)
  end

  ##
  # GenServer handlers
  ##
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:scrape, state) do
    {:noreply, %{state | attempts: track_attempt(state.attempts)}}
  end

  def handle_info(:schedule_scrape, state) do
    # TODO do the thang
    timestamp = DateTime.utc_now
    schedule_next_scrape(state.interval)
    {:noreply, %{state | attempts: track_attempt(state.attempts, timestamp)}}
  end

  ###
  # private functions
  ###
  defp schedule_next_scrape(interval \\ 30*1000) do
    Process.send_after(self(), :schedule_scrape, interval)
  end

  defp track_attempt(attempts, timestamp \\ DateTime.utc_now) do
    [timestamp | attempts]
  end

end
