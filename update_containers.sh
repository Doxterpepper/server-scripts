function update_and_restart () {
  docker pull $1 | grep "Status: Image is up to date" || docker restart $2
}

update_and_restart doxterpepper/nobonezone-landing:latest landing-page
