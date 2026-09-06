# AIUI Agent Web Simulation Debugging

## 1. Web Simulation Debugging

Click **Preview** in the **Real-Device Simulation** panel to debug the agent directly in a web browser. The simulator can reproduce user input, temple controls, and how the display appears in different lighting conditions.

![AIUI Agent Web Simulation Debugging](../../image/quickstart.en-us/9.png)

## 2. Developer Self-Test

After completing the simulation, verify at least the following:

- The initial screen loads as expected, and core tasks and return paths work correctly.
- Speech recognition, camera input, and temple controls behave as expected.
- Text, icons, and status information remain clear and legible under different lighting conditions.
- The Console, Problems view, and network information contain no unhandled errors.
- The application recovers correctly during continuous operation, after unexpected input, and under weak-network conditions.

Real-device simulation is intended for rapid iteration. The final experience must still be evaluated on a physical device. Before submitting the agent for review, validate speech, gestures, network behavior, local capabilities, startup time, and continuous-use scenarios on the device.

For more information, see [AIUI Agent Real-Device Debugging](../../0-guide/debug/real_device_debug.en-US.md).
