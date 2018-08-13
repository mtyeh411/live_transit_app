defmodule LiveTransitWeb.GtfsRealtimeChannel do
  use Phoenix.Channel

  def join("gtfsr:updates", _message, socket) do
    {:ok, socket}
  end

  def handle_in("new_update", %{"body" => body}, socket) do
    broadcast! socket, "new_update", %{body: body}
    {:noreply, socket}
  end
end
