FROM ruby:3.0.0

ADD . /app
WORKDIR /app

RUN bundle install -j4