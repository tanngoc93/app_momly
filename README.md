# Momly

Momly is a lightweight link shortener built with [Ruby on Rails](https://rubyonrails.org/). It lets you generate clean short URLs, manage them from a simple interface and integrate via a small JSON API.

## Features

- Shorten any URL with a six character code
- Optional account system using Devise and Google OAuth
- Keep track of click counts and last accessed time
- Guest mode for quick use without sign up
- Links are validated with Google Safe Browsing
- REST API secured with personal API tokens
- Rate limiting for guest requests and sign‑ups via Rack::Attack

## Requirements

- Ruby 3.1.2
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

### API usage

Authenticate using the `api_token` of your user and POST to `/api/v1/short_links`:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     -d "original_url=https://example.com" \
     http://localhost:3000/api/v1/short_links
```

The response includes the generated `short_url` and `short_code`.

## Scheduled tasks

Expired guest links are cleaned up daily using the `whenever` gem. The
cron job enqueues `CleanupExpiredGuestLinksJob` every day at 2&nbsp;AM.
After deploying, refresh the crontab with:

```bash
bin/rake schedule:update_crontab
```

## Tests

Run all tests with:

```bash
bin/rails test
```

## License

All rights reserved.
