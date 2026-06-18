# Billetto Rails Test

A Rails application that fetches events from the Billetto API, displays them, and lets authenticated users vote on them using Rails Event Store.

## Setup

**Requirements:** Ruby 4.0.3, PostgreSQL, Redis

```bash
cp .env.example .env
# Fill in BILLETTO_CLIENT_ID, BILLETTO_CLIENT_SECRET, CLERK_SECRET_KEY, CLERK_PUBLISHABLE_KEY

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

## Architecture

### Billetto API Integration

`Billetto::EventsService` fetches public events via the Billetto API (paginated). Events are upserted into the `events` table via `Billetto::EventMapper`. The sync runs as a Sidekiq background job.

### Voting — Event-Driven with Rails Event Store

Voting is implemented using a domain module (`app/domain/voting/`) following an event-driven pattern:

- **Commands** (`UpvoteEvent`, `DownvoteEvent`) are self-executing and validate that a user hasn't already voted on an event before publishing a domain fact to the event store.
- **Domain facts** (`EventUpvoted`, `EventDownvoted`) are published to a per-event stream (`Voting$<billetto_event_id>`) and linked to a per-user stream (`VotingByUser$<user_id>`).
- **Read model** (`Voting::ReadModels::VoteCounts`) subscribes to these facts synchronously and maintains a `vote_counts` table for fast display. In production this should be moved to an async Sidekiq worker.

All commands go through `CommandBus` which wraps execution in a database transaction.

### Authentication

User authentication is handled by [Clerk](https://clerk.com/). The `Authenticatable` concern extracts and verifies the Clerk session token (`__session` cookie or `Authorization` header). Only authenticated users can submit votes.

For local development without a Clerk account, voting buttons will show "Sign in to vote" but the rest of the app works fine.

## Design Notes

- Chose PostgreSQL over MySQL (better JSON support, row locking for the read model counter).
- Vote idempotency is enforced in the command layer by reading the event stream before publishing — not at the DB level. This keeps the write path clean and avoids a separate `votes` table.
- The read model `vote_counts` table exists purely for query performance. It can be rebuilt at any time from the event store.
- Frontend is minimal by design — the focus was on backend architecture per the brief.
