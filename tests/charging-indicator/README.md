# Charging indicator tests

Run from the repository root:

```sh
python3 tests/charging-indicator/run.py
```

The runner loads the production battery service and both indicators with mocked UPower and desktop widgets. It uses an offscreen Qt backend without a session bus connection.

Coverage includes charging, full charge, charge thresholds, charging at 100%, unknown charge state with AC power, and unplugging at 100%. A transition test updates an existing indicator through plugging, charging, full charge, and unplugging.

These tests verify bindings and icon selection. They do not verify native icon rendering, the compositor, or physical charger events.

For a manual check:

1. Connect the charger. The horizontal bar should show a bolt while charging or a plug when charging has stopped.
2. Hover over the battery. The popup should show the power source as plugged in.
3. Disconnect the charger. The plug or bolt should disappear, and the popup should show battery power.
4. Reconnect at 100% or at a charge threshold. The plug should remain visible while charging is stopped.
5. With the vertical bar enabled, check that its battery symbol changes to a bolt or plug while connected.
