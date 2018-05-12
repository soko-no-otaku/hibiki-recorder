FROM ruby:2.5.1
MAINTAINER soko-no-otaku

ENV TZ="Asia/Tokyo"

RUN apt-get update && apt-get install -y ffmpeg

WORKDIR /output
COPY ./Gemfile Gemfile
RUN bundle install

ENTRYPOINT ["ruby", "./rec_hibiki.rb"]
