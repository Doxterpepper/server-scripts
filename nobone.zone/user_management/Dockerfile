from ruby:3.1
RUN apt update -y && apt install -y vim 
WORKDIR /app
RUN touch /var/ftp_users
RUN groupadd ftp

COPY Gemfile .
RUN bundle install

COPY . .
CMD ruby web/main.rb
