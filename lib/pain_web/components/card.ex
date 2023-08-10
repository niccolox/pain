defmodule PainWeb.Components.Card do
  @moduledoc """
  A sample component generated by `mix surface.init`.
  """
  use Surface.Component

  @doc "The header slot"
  slot header

  @doc "The footer slot"
  slot footer

  @doc "The main content slot"
  slot default

  @doc "The background color"
  prop rounded, :boolean, default: false

  @doc """
  The max width.
  sm: `max-w-sm`, md: `max-w-md`, lg: `max-w-lg`
  """
  prop max_width, :string, values: ["sm", "md", "lg"]

  def render(assigns) do
    ~F"""
    <style>
      .card { @apply overflow-hidden shadow-md; }
      .content { @apply px-6 py-4 text-gray-700 text-base; }
      .header { @apply p-6 font-semibold text-2xl text-brand w-full bg-gray-200; }
      .footer { @apply px-6 py-4; }
    </style>

    <div class={"card", "max-w-#{@max_width}", "rounded-2xl": @rounded}>
      <div class="header">
        <#slot {@header}/>
      </div>
      <div class="content">
        <#slot/>
      </div>
      <div class="footer">
        <#slot {@footer}/>
      </div>
    </div>
    """
  end
end
