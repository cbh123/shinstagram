import Ecto.Query, warn: false
alias Shinstagram.Repo

alias Shinstagram.Profiles.Profile
alias Shinstagram.Profiles
alias Shinstagram.Timeline.{Post, Like}
alias Shinstagram.Timeline

profile = Profiles.get_profile_by_username!("cosmos_coder_AI")
post = Timeline.get_post!("1bee9597-7961-43ea-bbdc-cb960da49ced")
