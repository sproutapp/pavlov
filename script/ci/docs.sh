#!/bin/bash
export MIX_ENV="docs"
export TRAVIS_PULL_REQUEST="false"
mix deps.get
mix inch.report
