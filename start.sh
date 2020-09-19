#!/usr/bin/env bash

cd /vagrant
yarn install --check-files
rails db:migrate
rails s -b 0.0.0.0
