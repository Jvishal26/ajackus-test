# Billetto Rails Test

A Rails application that fetches events from the Billetto API, stores them, displays them with pagination, and allows authenticated users to vote via Rails Event Store.

## Setup

**Requirements:** Ruby 4.0.3, PostgreSQL, Redis

`bash
cp .env.example .env
# Fill in: BILLETTO_CLIENT_ID, BILLETTO_CLIENT_SECRET, CLERK_SECRET_KEY, CLERK_PUBLISHABLE_KEY

bundle install
rails db:create db:migrate
`

## Running

`bash
rails server
bundle exec sidekiq
`

To sync events from Billetto:
`bash
rails console
> SyncBillettoEventsJob.perform_now
`

The sync also runs automatically every hour via Sidekiq Cron.

## Tests

`bash
bundle exec rspec
`

## Architecture

### Billetto API Integration

Billetto::EventsService (under app/integrations/billetto/) fetches public events from the Billetto API with pagination and error handling. Events are mapped to the Event model via Billetto::EventMapper and upserted in bulk. The sync runs as a background job via Sidekiq.

### Event Display

Events are listed on the index page with title, date, image, location, and description (truncated). Pagination is handled at 20 events per page using limit/offset.

### Voting with Rails Event Store

Voting is built as a domain module (app/domain/voting/) following the project's DDD conventions:

- **Facts** (EventUpvoted, EventDownvoted) are published to a per-event stream (Voting$<id>) and linked to a per-user stream (VotingByUser$<user_id>).
- **Commands** (UpvoteEvent, DownvoteEvent) are self-executing, validate their inputs, and enforce idempotency by reading the event stream before publishing — one vote per user per event.
- **Read model** (Voting::ReadModels::VoteCounts) subscribes to vote facts and maintains a vote_counts table for fast display. Uses pessimistic locking to handle concurrent votes safely.

All commands go through CommandBus, which wraps execution in a DB transaction.

### Authentication

User authentication is handled by [Clerk](https://clerk.com/) via clerk-sdk-ruby. The Clerk Rack middleware authenticates each request by reading the __session cookie and sets 
equest.env["clerk"] with the user's session proxy.

The Authenticatable concern exposes current_user_id and signed_in? to controllers and views. Voting is restricted to authenticated users — unauthenticated requests are redirected to the sign-in page.

Sign-up and sign-in pages embed Clerk's JavaScript components (mountSignIn, mountSignUp). Sign-out is handled via Clerk.signOut() on the client.

Required environment variables:
- CLERK_SECRET_KEY — for the Rack middleware to verify sessions server-side
- CLERK_PUBLISHABLE_KEY — for loading the Clerk JS bundle

### Testing

- **Model specs** — validate Event model constraints and scopes
- **Domain specs** — test the voting commands, idempotency, stream linking, and vote count read model
- **Request specs** — cover event listing, pagination, auth-gated voting, and redirect behaviour for unauthenticated users
- **System specs** — browser-level tests using 
ack_test driver covering the auth flow (sign-in state, vote buttons, redirects) via a test middleware that injects a fake Clerk session

In test environment, CLERK_SKIP_RAILTIE=true prevents the real Clerk middleware from loading. A ClerkTestMiddleware reads a test-only cookie (_clerk_test_user) to simulate authenticated sessions.

## Design Notes

- Voting idempotency is enforced in the command layer by reading the event stream, not by a DB constraint. This keeps the write side clean and avoids a separate votes table.
- The vote_counts read model can be rebuilt at any time from the event store.
- The Billetto integration lives in app/integrations/billetto/ rather than app/services/, following the project's convention for third-party ACL modules.
- Frontend is deliberately minimal — the focus of the assignment is backend architecture.
