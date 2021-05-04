FROM ruby:2.6.2

ENV RUBYOPT -EUTF-8

RUN apt-get install -y gnupg
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs npm
RUN npm install -g heroku

ADD . /app
WORKDIR /app

RUN gem install bundler && bundle install