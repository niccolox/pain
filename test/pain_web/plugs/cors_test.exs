# test/my_app_web/plugs/allow_iframe_test.exs
defmodule PainWeb.Plugs.EnableCorsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias PainWeb.Plugs.EnableCors

  test "updates Content-Security-Policy headers" do
    conn = conn(:get, "/hello") |> EnableCors.call(%{})
    assert(
      conn.resp_headers
      |> Enum.find(fn {header, _} -> header == "content-security-policy" end)
      == { "content-security-policy", "frame-ancestors 'self' https://*painawayofphilly.com https://*squarespace.com;" }
    )
  end
end
