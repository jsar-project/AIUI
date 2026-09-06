# AIUI Agent Real-Device Debugging

On-device debugging is a critical step in verifying the real user experience of AIUI agents. Compared with desktop or simulated environments, real devices can more accurately reflect device-side performance, interaction feedback, network conditions, and local capability invocation, Prioritize real-device results as the final basis for judging the user experience.

## 1. Package and Save the AIX

Open the **Build & Review** tab on the right, then complete the packaging and save the agent information. The Rokid AI App downloads the latest version of the current agent through **Update glasses resource** only after a new version has been generated and saved in AIUI Studio.

The version number is generated automatically by the system and cannot be edited by developers. The version number increases each time you package, save the agent information, or submit it for review.

A progress dialog is displayed during upload:

- **Upload successful:** Continue with real-device debugging or submit the agent for review.
- **Upload failed:** Fix the issue based on the error message and try again.

Package the AIUI agent by going to **Build & Review -> AIX Packaging**. After packaging succeeds, the package is automatically synchronized to the cloud.

![image.jpg](../../image/quickstart.en-us/10.png)

```latex
⚠️ Before debugging an AIUI agent on a real device, you must complete “AIX Packaging” to obtain the latest files.
```

## 2. Real-Device Debugging

1. Open the Hi Rokid App and connect your Rokid Glasses.
2. Go to **Settings -> Developer Options -> AIUI**.
3. Tap **Update glasses resource** and wait for the download to finish on the glasses.

![image.jpg](../../image/quickstart.en-us/11.png)

4. After the message **Agent resource package downloaded successfully** appears, invoke the agent by voice and complete the real interaction flow, for example: “Hi Rokid, open the xxx agent.”

![image.jpg](../../image/quickstart.en-us/12.png)

5. If the result does not match expectations, return to AIUI Studio, make the necessary changes, package and save the agent again, and repeat the steps above.

## 3. Developer Self-Test

After completing real-device debugging, verify at least the following:

- The initial screen loads as expected, and core tasks and return paths work correctly.
- Speech recognition, camera input, and Temple Controls behave as expected.
- Text, icons, and status information remain clear and legible under different lighting conditions.
- Console, Problems, and network information contain no unhandled errors.
- The application recovers correctly during continuous operation, after unexpected input, and under weak-network conditions.

Real-device results are the primary basis for evaluating the final experience. Pay particular attention to startup time, visual stability, voice and gesture feedback, network status, local capability calls, and stability over extended use.
