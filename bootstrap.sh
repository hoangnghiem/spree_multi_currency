#!/bin/sh

clear

echo "Start creating test app..."

bundle exec rake test_app

cd spec/dummy

bundle exec rake db:drop db:create db:migrate
bundle exec rake db:seed

bundle exec rake spree_sample:load
bundle exec rake spree_multi_currency:generate_default_currency

echo 'Done!'
