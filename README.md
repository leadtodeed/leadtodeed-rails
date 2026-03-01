# Leadtodeed Rails

Rails engine providing WebRTC click-to-call phone widget integration via the [Leadtodeed](https://leadtodeed.ai) backend.

Adds a drop-in widget to any Rails app that lets authenticated users make and receive phone calls directly from the browser. Incoming-call popups, click-to-call on `tel:` links, and JWT-based auth are included out of the box.

## Requirements

- Ruby >= 3.2
- Rails >= 7.0
- [importmap-rails](https://github.com/rails/importmap-rails)
- [Stimulus](https://stimulus.hotwired.dev/) (bundled with Rails 7+ via Hotwire)
- An authentication system that provides `current_user` and `authenticate_user!` (e.g. [Devise](https://github.com/heartcombo/devise))

## Installation

Add the gem to your Gemfile:

```ruby
gem "leadtodeed-rails"
```

Then run:

```bash
bundle install
```

## Configuration

### Environment variables

| Variable | Required | Description |
|---|---|---|
| `LEADTODEED_JWT_SECRET` | Yes | Secret key used to sign JWT tokens (HS256) |
| `LEADTODEED_BACKEND_URL` | Yes | URL of your Leadtodeed backend instance |
| `LEADTODEED_PRIMARY_COLOR` | No | Widget accent color as hex (default `#8B5CF6`) |

### Mount the engine

Add the engine routes to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount Leadtodeed::Rails::Engine => "/api/leadtodeed"

  # ... your other routes
end
```

This exposes a single endpoint:

```
POST /api/leadtodeed/token
```

Authenticated users receive a short-lived JWT (8 hours) containing their `email`, `user_id`, and `name`. The widget uses this token to connect to the Leadtodeed backend.

### User model

The engine expects `current_user` to respond to:

- `email` - user's email address
- `id` - user's primary key
- `name` - user's display name

## Usage

### Render the widget

Add the widget partial to your application layout (e.g. `app/views/layouts/application.html.slim`):

```slim
body
  = render "leadtodeed/widget"
```

Or in ERB:

```erb
<%= render "leadtodeed/widget" %>
```

The widget only renders for signed-in users. It injects:
- Meta tags for backend URL and primary color
- The JavaScript module that initializes the phone client
- A Stimulus controller wrapper for incoming-call popups

### Click-to-call

Any standard `tel:` link within the widget controller scope is automatically intercepted and routed through the WebRTC widget:

```html
<a href="tel:+15551234567">Call +1 (555) 123-4567</a>
```

### Custom primary color

Override the default purple accent per-view:

```erb
<%= leadtodeed_widget_tag(primary_color: "#FF6B35") %>
```

Or set `LEADTODEED_PRIMARY_COLOR` globally via environment variable.

### JavaScript API

The widget exposes a global API for programmatic calls:

```javascript
// Call a number
window.leadtodeedCall("+15551234567")

// Access the phone instance directly
window.leadtodeedPhone.call("+15551234567")
window.leadtodeedPhone.answer()
window.leadtodeedPhone.reject()
```

### Caller info link

You can enrich the incoming-call popup with a clickable link (e.g. to a CRM record) by defining a `window.leadtodeedOnCall` callback. When an incoming call arrives, the widget calls it with the caller's phone number and a `done` callback. Call `done({ link, text })` to display a link in the popup, or `done(null)` to skip.

```javascript
window.leadtodeedOnCall = async (phone, done) => {
  try {
    const resp = await fetch(`/your/search/endpoint?phone=${encodeURIComponent(phone)}`, {
      credentials: "same-origin",
      headers: { Accept: "application/json" },
    })
    if (!resp.ok) return done(null)
    const data = await resp.json()
    done({ link: data.link, text: data.display_name })
  } catch (e) {
    done(null)
  }
}
```

The search endpoint should accept a phone number and return JSON with at least a `link` (URL path) and whatever fields you need to build the `text` label. For example, in a Rails app:

```ruby
# config/routes.rb
resources :clients, only: [] do
  get :search, on: :collection
end

# app/controllers/clients_controller.rb
def search
  client = Client.find_by!(phone: params[:phone])
  render json: { display_name: client.name, link: client_path(client) }
end
```

Then override the default widget partial to include the callback:

```slim
= leadtodeed_widget_tag
- if user_signed_in?
  div data-controller="leadtodeed leadtodeed-call" style="display:contents"

  javascript:
    window.leadtodeedOnCall = async (phone, done) => {
      try {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
        const resp = await fetch(`/clients/search?phone=${encodeURIComponent(phone)}`, {
          credentials: 'same-origin',
          headers: { 'X-CSRF-Token': csrfToken, 'Accept': 'application/json' }
        })
        if (!resp.ok) return done(null)
        const data = await resp.json()
        done({ link: data.link, text: data.display_name })
      } catch(e) { done(null) }
    }
```

### Events

The widget dispatches custom DOM events:

| Event | Detail | Description |
|---|---|---|
| `leadtodeed:incoming-call` | `{ callerName, callerNumber }` | Fired when an incoming call arrives |
| `leadtodeed:call-ended` | — | Fired when a call ends |

```javascript
window.addEventListener("leadtodeed:incoming-call", (event) => {
  console.log("Call from:", event.detail.callerName)
})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then:

```bash
bundle exec rake        # runs specs + RuboCop
bundle exec rspec       # specs only
bundle exec rubocop     # lint only
```

The test suite uses a minimal dummy Rails app in `spec/dummy/` to boot the engine in isolation.

The `spec/requests/` directory contains integration specs designed to run from a host Rails app context (not standalone).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
