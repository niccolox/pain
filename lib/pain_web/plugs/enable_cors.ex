# lib/my_app_web/plugs/allow_iframe.ex
defmodule PainWeb.Plugs.EnableCors do
  import Plug.Conn

  def init(_), do: %{}
  def call(conn, _opts) do
    conn |> put_resp_header(
      "content-security-policy",
      "frame-ancestors 'self' https://*painawayofphilly.com https://*squarespace.com;"
    ) |> delete_resp_header("x-frame-options")
  end
end
