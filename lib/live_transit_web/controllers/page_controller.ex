defmodule LiveTransitWeb.PageController do
  use LiveTransitWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
