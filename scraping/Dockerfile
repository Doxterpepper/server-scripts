FROM ruby:3.1-buster
RUN apt-get update -y &&  apt-get install -y apt-utils
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install build-essential
RUN mkdir /app
WORKDIR /app
RUN which g++
COPY Gemfile /app/Gemfile
RUN bundle install
copy . /app
CMD ruby retrostic.rb
