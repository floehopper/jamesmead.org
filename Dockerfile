FROM ruby:2.7.5

# Get info on latest versions of packages
RUN apt-get update

# Required by execjs via middleman-core, coffee-script & uglifier
RUN apt-get install -y nodejs

# Clean up to reduce disk usage
RUN apt-get clean

# Install version of Bundler specified by BUNDLED WITH in Gemfile.lock
RUN gem install bundler --version 2.1.4

# Specify app directory on container
ENV APP_HOME /app

# Create app directory on container
RUN mkdir $APP_HOME

# Set working directory on container
WORKDIR $APP_HOME

# Install bundled gems to shared volume
ENV BUNDLE_PATH /bundled_gems

# Share project root as app directory on container
ADD . $APP_HOME
