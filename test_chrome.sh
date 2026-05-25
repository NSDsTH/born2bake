#!/bin/bash
./chromedriver --port=4444 &
DRIVER_PID=$!
trap "kill $DRIVER_PID 2>/dev/null" EXIT

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d chrome
