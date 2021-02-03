FROM ruby:2.5.1
MAINTAINER soko-no-otaku

ENV TZ="Asia/Tokyo"

RUN apt-get update && apt-get install -y ffmpeg

RUN mkdir /output

COPY Gemfile /
RUN bundle install

COPY rec_hibiki.rb /
ENTRYPOINT ["ruby", "rec_hibiki.rb"]
