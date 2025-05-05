#!/bin/bash
set -e

#
bundle check || bundle install

bundle exec good_job start

exec "$@"