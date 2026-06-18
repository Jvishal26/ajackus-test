# Billetto Rails Test

A Rails application that fetches events from the Billetto API, displays them with pagination, and lets users vote on them using Rails Event Store.

## Setup

**Requirements:** Ruby 3.x(installed 4), PostgreSQL, Redis

```bash
touch .env
# Add BILLETTO_CLIENT_ID, BILLETTO_CLIENT_SECRET, CLERK_SECRET_KEY, CLERK_PUBLISHABLE_KEY

bundle install
rails db:create db:migrate
```

## Running

```bash
rails server
bundle exec sidekiq  # background jobs
```

To sync events from Billetto:
```bash
rails runner "SyncBillettoEventsJob.perform_now"
# or let the cron schedule handle it (see config/initializers/sidekiq_cron.rb)
```

## Tests

```bash
bundle exec rspec
```

## What's done

### Billetto API Integration

`Billetto::EventsService` fetches public events via the Billetto API (paginated). Events are upserted into the `events` table via `Billetto::EventMapper`. The sync runs as a Sidekiq background job (`SyncBillettoEventsJob`) on a cron schedule.

### Event listing with pagination

The index page displays all events ordered by start date, 20 per page (Kaminari). Each event shows title, date, location, description snippet, image, and a link to Billetto.

### Voting — Event-Driven with Rails Event Store

Voting is implemented using a domain module (`app/domain/voting/`) following an event-driven pattern:

- **Commands** (`UpvoteEvent`, `DownvoteEvent`) are self-executing and enforce idempotency by reading the event stream before publishing — a user can only vote once per event.
- **Domain facts** (`EventUpvoted`, `EventDownvoted`) are published to a per-event stream (`Voting$<billetto_event_id>`) and linked to a per-user stream (`VotingByUser$<user_id>`).
- **Read model** (`Voting::ReadModels::VoteCounts`) subscribes to these facts synchronously and maintains a `vote_counts` table for fast display.
- Votes are tracked by session (`session[:user_id]`), so a browser session counts as a single voter.

All commands go through `CommandBus` which wraps execution in a database transaction.

### Tests

Request specs cover the events listing, pagination, and the vote submission flow. Run with `bundle exec rspec`.

## Pending

### Clerk Authentication

Clerk.com authentication has not been integrated yet. The assignment requires sign-up/sign-in via Clerk SDK with voting restricted to authenticated users. This is the remaining task.

### Testing

some cases are not covered, negative tests are also pending

### pipeline fix

pipeline fix is also pending

