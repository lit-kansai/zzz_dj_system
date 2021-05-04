FROM ruby:2.6.2

ENV RUBYOPT -EUTF-8

ADD . /app
WORKDIR /app

RUN gem install bundler && bundle install