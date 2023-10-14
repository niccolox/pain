# lib/my_app_web/plugs/allow_iframe.ex
defmodule PainWeb.Plugs.EnableCors do
  import Plug.Conn

  def init(_), do: %{}
  def call(conn, _opts) do
    conn
    |> put_resp_header(
      "content-security-policy",
      "frame-ancestors 'self' https://assemble.codes https://www.painawayofphilly.com https://painawayofphilly.com https://*.squarespace.com;"
    )
    |> put_resp_header(
      "Access-Control-Allow-Origin",
      "https://assemble.codes https://www.painawayofphilly.com https://painawayofphilly.com https://*.squarespace.com"
    )
    |> delete_resp_header("x-frame-options")
  end
end
