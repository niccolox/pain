defmodule PainWeb.Components.CardTest do
  use PainWeb.ConnCase, async: true
  use Surface.LiveViewTest

  catalogue_test PainWeb.Card
end
