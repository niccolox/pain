# Pain

Booking application replacing Acuity Scheduler, for <painawayofphilly.com>.

## Scheduling Credentials

You'll need a couple environment variables so our app can book inside your acuity calendars.
Locally, these can go inside a file called `.env`:

```bash
# .env
SCHEDULE_USER="12345678"
SCHEDULE_KEY="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
```

## Launch

Deploy your app:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

You should see a booking page on [`localhost:4000`](http://localhost:4000/book).
Deploy this app using [Dokku](https://dokku.com).

## Learn more

  * A more proper-Elixir deployment is described in [deployment guides](https://hexdocs.pm/phoenix/deployment.html).
  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
