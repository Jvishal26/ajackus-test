Sidekiq::Cron::Job.create(
  name: "Sync Billetto Events - every hour",
  cron: "0 * * * *",
  class: "SyncBillettoEventsJob"
)