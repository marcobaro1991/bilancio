defmodule BilancioWeb.PageController do
  use BilancioWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
