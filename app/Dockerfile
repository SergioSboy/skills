# Используем базовый slim-образ Ruby
FROM ruby:3.4.1-slim AS builder

WORKDIR /app

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
 && bundle config set deployment true \
 && bundle config set without 'development test' \
 && bundle install

COPY . .

FROM ruby:3.4.1-slim

WORKDIR /app

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    file \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*


COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

EXPOSE 3000

CMD ["bash", "-c", "rm -f /app/tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0"]