# Momly

Momly is a lightweight link shortener built with [Ruby on Rails](https://rubyonrails.org/). It lets you generate clean short URLs, manage them from a simple interface and integrate via a small JSON API.

## Features

- Shorten any URL with a six character code
- Optional account system using Devise and Google OAuth
- Keep track of click counts and last accessed time
- Detailed click analytics with IP, referrer and user agent
- Stores page title and description for each link
- Guest mode for quick use without sign up
- Links are validated with Google Safe Browsing
- REST API secured with personal API tokens
- Rate limiting for guest requests and sign‑ups via Rack::Attack
- Dashboard to view aggregated click metrics

## Requirements

- Ruby 3.2.3
- PostgreSQL
- Redis (for the Docker setup)

## Getting started

### Local setup

```bash
bin/setup
bin/rails server
```

The app will be available at `http://localhost:3000`.

### Docker

A sample compose file is provided. Copy it and start the services:

```bash
cp docker-compose.yml.sample docker-compose.yml
# edit environment variables as needed
docker compose up
```

This exposes the app on port `3001`.

Start the Sidekiq worker in another terminal:

```bash
docker compose run --rm momly_backend /bin/sh .dockerdev/commander/sidekiq.sh
```

### Environment variables

The app reads `MOMLY_DOMAINS` to determine which domains should not be
shortened. Provide a comma‑separated list of domains. The default is
`momly.me,www.momly.me`.

### API usage

Authenticate using the `api_token` of your user and POST to `/api/v1/short_links`:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -d "original_url=https://example.com" \
     http://localhost:3000/api/v1/short_links
```

The response includes the generated `short_url` and `short_code`.

Additional endpoints are available:

```bash
# List all links
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:3000/api/v1/short_links

# Retrieve a single link
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:3000/api/v1/short_links/1

# Update a link
curl -X PATCH -H "Authorization: Bearer YOUR_TOKEN" \
     -d "original_url=https://new.example.com" \
     http://localhost:3000/api/v1/short_links/1

# Delete a link
curl -X DELETE -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:3000/api/v1/short_links/1
```

`index` and `show` return JSON data describing the short link(s). `update` returns the updated record while `destroy` responds with a `204 No Content` status.


To view analytics for a link, send a GET request to `/api/v1/short_links/:id/stats`.


## Scheduled tasks

Expired guest links are cleaned up daily using the `whenever` gem. The
cron job enqueues `CleanupExpiredGuestLinksJob` every day at 2&nbsp;AM.
Old click analytics are removed with `CleanupOldShortLinkClicksJob` at
3&nbsp;AM. The retention period defaults to 90&nbsp;days and can be adjusted
using the `SHORT_LINK_CLICK_RETENTION_DAYS` environment variable.
After deploying, refresh the crontab with:

```bash
bin/rake schedule:update_crontab
```

## Privacy

Each redirect stores the visitor IP address, referrer and user agent for
analytics purposes. This data is used only to generate aggregated statistics
and is never shared with third parties. Delete your short link if you no longer
want this information collected.

## Tests

Run all tests with:

```bash
bin/rails test
```

## License

All rights reserved.
