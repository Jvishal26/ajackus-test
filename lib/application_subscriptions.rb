class ApplicationSubscriptions
  def handlers
    {}
      .merge(Voting.subscriptions)
  end
end
