defmodule PainWeb.Components.Page do
  use Surface.LiveComponent

  slot default, required: true
  data open, :boolean, default: false

  def handle_event("open", _params, socket) do
    {:noreply, socket |> assign(:open, !socket.params[:open]) }
  end

  def render(assigns) do
    ~F"""
    <style>
      main { max-width: 60rem; margin: 0 auto; padding: 2rem 1rem; }
      #screen { height: 100vh; width: 100vw; background: #bdd1d2;
      display: grid; grid-template-rows: auto 1fr; grid-gap: 2rem; }

      #page { height: auto; overflow-y: scroll;
        display: flex; flex-direction: column; align-items: center; }

      #end { width: 100vw; background: #0a2923; color: #d0d0d0;
        position: fixed; bottom: 0; left: 0; right: 0; z-index: 99;
        display: flex; flex-direction: column; }

      #end main { padding: 0; }

      .line { padding: 1rem 0;
        display: flex; flex-direction: row; justify-content: space-between; }
      @media(max-width: 1080px) { .line { flex-direction: column; } }

      a { text-decoration: underline; }
    </style>

    <div id="screen">
      <div id="page">
        <main><#slot/></main>
      </div>

      <div id="end">
        <main class={"collapse", "collapse-arrow", "border-neutral"} >
        <input type="checkbox" /> 
        <div class="collapse-title text-xl font-medium">Menu</div>
        <div class="collapse-content"> 
          <div class="line">
            <div class="address">
              <span>936 Arch st.</span>
              <span>2nd floor,</span>
              <span>Philadelphia,</span>
              <span>US</span>
            </div>
            <a href="tel:+12676904138">(267) 690-4138</a>
            <a href="mailto:painawayphilly@gmail.com">Painawayphilly@gmail.com</a>
          </div>

          <div class="line">
            <a href="https://painawayofphilly.com/">Home</a>
            <a href="https://painawayofphilly.com/our-story">About</a>
            <a href="https://painawayofphilly.com/contact">Connect</a>
            <a href="https://www.instagram.com/painawayofphilly/">Instagram</a>
            <a href="https://www.facebook.com/Pain-away-of-Philly-100684451517158/?modal=admin_todo_tour">Facebook</a>
            <a href="https://www.painawayofphilly.com/book-now">Book (Original)</a>
          </div>
        </div>
        </main>
      </div>
    </div>
    """
  end
end
