
defmodule PainWeb.Components.ServiceMap do
  use Surface.Component

  prop services, :map

  def render(assigns) do
    num = assigns[:services] |> map_size
    ~F"""
    <style>
      section { display: flex; justify-content: end; }
    </style>

    <section class="service-map" >
      <svg xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"
        version="1.1" style="-webkit-print-color-adjust:exact" fill="none"
        viewBox={"0 0 600 #{40 * (num + 1)}"} width="600" height={40 * (num + 1)}
      >
        {#for {n, service} <- @services}
          <g>
            <text x={580 - 48 * num} y={40 * n} text-anchor="end"
            style="fill:#000000;" dominant-baseline="ideographic" >
              {n}: {service}</text>
            <path rx="0" ry="0" style="stroke-width:2;stroke:#000000"
              d={"
              M #{600 - 48 * num} , #{40 * n - 6}
              L #{624 - 48 * n}   , #{40 * n - 6}
              L #{624 - 48 * n}   , #{40 * (num + 1)}
              "} />
          </g>
        {/for}
      </svg>
    </section>
    """
  end
end
