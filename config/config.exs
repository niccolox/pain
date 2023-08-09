# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :pain,
  ecto_repos: [Pain.Repo]

# Configures the endpoint
config :pain, PainWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: PainWeb.ErrorHTML, json: PainWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Pain.PubSub,
  live_view: [signing_salt: "c23vOG95"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :pain, Pain.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  catalogue: [
    args: ~w(../deps/surface_catalogue/assets/js/app.js --bundle --target=es2016 --minify --outdir=../priv/static/assets/catalogue),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :surface, components: [
  {Surface.Components.Form.Field, [default_class: "field"]},
  {Surface.Components.Form.Label, [default_class: "label"]},
  {SurfaceBulma.Collapsible, propagate_context_to_slots: true},
  {SurfaceBulma.Dropdown, propagate_context_to_slots: true},
  {SurfaceBulma.Navbar, propagate_context_to_slots: true},
  {SurfaceBulma.Navbar.Brand, propagate_context_to_slots: true},
  {SurfaceBulma.Navbar.Dropdown, propagate_context_to_slots: true},
  {SurfaceBulma.Form, propagate_context_to_slots: true},
  {SurfaceBulma.Form.Checkbox, propagate_context_to_slots: true},
  {SurfaceBulma.Form.Input, propagate_context_to_slots: true},
  {SurfaceBulma.Form.TextInput, propagate_context_to_slots: true},
  {SurfaceBulma.Form.PasswordInput, propagate_context_to_slots: true},
  {SurfaceBulma.Form.InputWrapper, propagate_context_to_slots: true},
  {SurfaceBulma.Form.InputWrapperTest.Slot, propagate_context_to_slots: true},
  {SurfaceBulma.Form.InputWrapper, :render_left_addon, propagate_context_to_slots: true},
  {SurfaceBulma.Form.InputWrapper, :render_right_addon, propagate_context_to_slots: true},
  {SurfaceBulma.Form.FileInput, propagate_context_to_slots: true},
  {SurfaceBulma.Form.Select, propagate_context_to_slots: true},
  {SurfaceBulma.Panel, propagate_context_to_slots: true},
  {SurfaceBulma.Panel.Tab, propagate_context_to_slots: true},
  {SurfaceBulma.Panel.Tab.TabItem, propagate_context_to_slots: true}
]
