
defmodule PainWeb.Components.ServiceMap do
  use Surface.Component

  prop services, :map

  def render(assigns) do
    num = assigns[:services] |> map_size
    ~F"""
    <style>
      section { display: flex; justify-content: end; }
      svg text { fill:#000000; }
      svg path { stroke-width:2; stroke:#000000; }
      .backup { display: none; }
      .backup .service { text-align: right; }
      .backup .column {
        display: inline-block;
        width: 48px;
        text-align: center;
        padding-top: 1rem;
      }
      @media(max-width: 400px) {
        svg { display: none; }
        .backup {
          padding-top: 1rem;
          display: flex;
          flex-direction: column;
          align-content: end;
        }
      }

      g.num-1 text {fill: green;  } g.num-1 path {stroke: green;  }
      g.num-2 text {fill: blue;   } g.num-2 path {stroke: blue;   }
      g.num-3 text {fill: purple; } g.num-3 path {stroke: purple; }
      g.num-4 text {fill: red;    } g.num-4 path {stroke: red;    }
    </style>

    <section class="service-map" >
      <svg xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg"
        version="1.1" style="-webkit-print-color-adjust:exact" fill="none"
        viewBox={"0 0 360 #{40 * (num + 1)}"} width="360" height={40 * (num + 1)}
      > {#for {n, service} <- @services}
      <g class={"num-#{n}"}>
        <text x={360 - 48 * num} y={40 * n} text-anchor="end"
         dominant-baseline="ideographic" >
          {n}: {Squish.pare(service, size: 20)}</text>
        <path rx="0" ry="0"
          d={"
          M #{372 - 48 * num}       , #{40 * n - 6}
          L #{384 - 48 * (num-n+1)} , #{40 * n - 6}
          L #{384 - 48 * (num-n+1)} , #{40 * (num+1)}
          "} />
        </g> {/for}
      </svg>

      <div class="backup">
        {#for {n, service} <- @services}
          <span class="service">{n}: {Squish.pare(service, size: 20)}</span>
        {/for}
        <div class="columns">
          {#for {n,_} <- @services}<span class="column">({n})</span>{/for}
        </div>
      </div>
    </section>
    """
  end
end
