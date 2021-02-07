FROM ruby:3.0.0-alpine3.12 as builder
COPY Gemfile /
RUN apk add --no-cache --update g++ make && bundle install

FROM ruby:3.0.0-alpine3.12
RUN mkdir /output && \
    apk add --no-cache --update libgcc libstdc++ ca-certificates libcrypto1.1 libssl1.1 libgomp expat tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apk del tzdata
COPY --from=jrottenberg/ffmpeg:4.3-alpine312 /usr/local /usr/local
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY rec_hibiki.rb /
ENTRYPOINT ["ruby", "rec_hibiki.rb"]
