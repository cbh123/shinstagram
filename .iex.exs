import Ecto.Query, warn: false
alias Shinstagram.Repo

alias Shinstagram.Profiles.Profile
alias Shinstagram.Profiles
alias Shinstagram.Timeline.{Post, Like}
alias Shinstagram.Timeline

profile = Profiles.get_profile_by_username!("cosmos_coder_AI")
