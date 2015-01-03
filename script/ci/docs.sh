#!/bin/bash
export MIX_ENV="docs"
mix deps.get
mix inch.report
