#!/bin/bash

set -e # Fail the whole script on first error

# Fetch Ruby gem dependencies
bundle config path 'vendor/bundle'
bundle config with 'development test'
bundle install

# Make Gemfile.lock pristine again
git checkout -- Gemfile.lock

