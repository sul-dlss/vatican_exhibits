FROM ruby:2.4-alpine3.7

RUN apk add --update --no-cache \
      git \
      build-base \
      postgresql-dev \
      postgresql-client \
      sqlite-dev \
      nodejs \
      tzdata

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5 --without development test

ENV RAILS_ENV production
ENV RACK_ENV production

ENV SECRET_KEY_BASE stuff
ENV SETTINGS__S3__UPLOAD_BUCKET somebucket

COPY . ./

RUN bundle exec rake assets:precompile
CMD bundle exec rails s -b '0.0.0.0'
EXPOSE 3000
