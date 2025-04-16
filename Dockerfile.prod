FROM ruby:3.2 as builder

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    && npm install -g yarn

# Set working directory
WORKDIR /app

# Copy gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test

# Copy application code
COPY . .

# Precompile assets
RUN SECRET_KEY_BASE=placeholder RAILS_ENV=production bundle exec rails assets:precompile

# Final stage
FROM ruby:3.2-slim

# Install runtime dependencies
RUN apt-get update -qq && apt-get install -y \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy from builder stage
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Expose port
EXPOSE 3000

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
