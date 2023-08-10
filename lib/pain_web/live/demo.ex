defmodule PainWeb.Demo do
  use PainWeb, :surface_live_view

  alias PainWeb.Components.Card

  def render(assigns) do
    ~F"""
    <style>
      section { margin: 1rem 0 1rem; }
      section p { margin-bottom: 1rem; }
      #number-people { display: flex; flex-direction: column; }
      #number-people .join { align-self: center; }
      #class .join-item { @apply border-2; }
    </style>

    <div class="flex justify-center mt-12">
      <Card max_width="lg" rounded>
        <:header>
          Book an appointment
        </:header>

        <section id="number-people">
          <p>How many people are you booking for?</p>
          <div class="join">
            <button class="btn join-item">Only me</button>
            <button class="btn join-item">+1</button>
            <button class="btn join-item">+2</button>
            <button class="btn join-item">+3</button>
          </div>
        </section>

        <section id="class" class="join join-vertical">
          <p>
            Please choose a category:
          </p>
          <div class="collapse collapse-arrow join-item border-neutral">
            <input type="radio" name="my-accordion-1" />
            <div class="collapse-title text-xl font-medium">
              Body and Foot Massage
            </div>
            <div class="collapse-content">
              <p>hello</p>
            </div>
          </div>
          <div class="collapse collapse-arrow join-item border-neutral">
            <input type="radio" name="my-accordion-1" />
            <div class="collapse-title text-xl font-medium">
              Cupping
            </div>
            <div class="collapse-content">
              <p>hello</p>
            </div>
          </div>
          <div class="collapse collapse-arrow join-item border-neutral">
            <input type="radio" name="my-accordion-1" />
            <div class="collapse-title text-xl font-medium">
              Other Traditional Medical Therapy Methods
            </div>
            <div class="collapse-content">
              <p>hello</p>
            </div>
          </div>
        </section>
      </Card>
    </div>
    """
  end
end
