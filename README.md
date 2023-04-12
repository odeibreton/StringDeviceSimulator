# Stance test
We want to create an app that allows a user to exercise with a Stance device (string device). The user will be able to select an exercise (Bench press, squat or deadlift) and weight before starting the exercise.

When the user wants to start the exercise, they will press a button in the app, and the app will communicate with the string device to start recording data.

While this happens, the string device will be streaming readings to the app, and the app must receive those values for processing after the exercise is done.

Once the user is done with the exercise, they will be able to press a button to stop the exercise. Once this happens, the app will show how many readings were received from the string device.

After this, the readings must be sent to the API (there is no API, so this call should be mocked).

## User flow
- Select exercise
- Input weight
- Start exercise
  - Send start recording message to the BLE device
  - Receive readings
- Stop exercise
  - Send stop recording message to the BLE device
- Show how many readings were received
- Send readings to the API
- Start over

## Goals
⭐️
- Complete the user journey by allowing the user to select the exercise, input the weight, perform the exercise and how many readings were received

⭐️⭐️
- Send the recorded data to the API (readings and other data like exercise name and weight)
- Store the recorded data locally for future processing (including the exercise name and weight)

⭐️⭐️⭐️
- Implement a retry mechanism to make sure the data reaches the API if the app is not connected to the internet

## What we'll look into
We will look into the candidate's problem-solving abilities and coding practices.

It's okay if the app doesn't fully work, or if there are a few bugs, the most important part is to see the intent and reasoning behind the code and to be able to talk through the solution.

Automated testing is not required, but it is desirable. If automated testing is implemented, 100% coverage is not required. We'd rather see a few tests covering the most important parts of the app, rather than many tests trying to cover absolutely everything. Less is more.

## What we'll NOT look into
As this app is more about the communication and logic side of things, we will not pay very close attention to the UI. Well-structured views are nice to have but don't sacrifice time into creating the most perfect UI for the project.

We won't look into the deployment, monitoring or infrastructure.

# Simulator documentation
The string device simulator is designed to act like one of our real devices. It can receive a message to start and stop recording, and when the device is recording, it will start sending random numbers to the BLE client.

## BLE Spec
The simulator exposes one BLE service with the ID `2cdaa35b-be1e-40d4-aba0-3add764a6a8b`.
This service has two characteristics:

### IsRecordingCharacteristic
**ID**: `69872099-e938-4e1e-99c4-74afc913d553`

This characteristic is used for the app to indicate when to start and stop recording.

The app can write a value into the characteristic, and there are only two possible values: `0x00` and `0x01` (hex notation). The simulator will only accept values that are one byte long.

When the written value is `0x01`, the simulator will start recording (and sending data). When the value is `0x00`, the simulator will stop recording (and stop sending data).

### ReadingsCharacteristic
**ID**: `85844cc1-2eac-4744-9b9d-462cfd8debd1`

This characteristic is used to transfer readings from the simulator to the app. The app can't write to this property but can subscribe to notifications.

The simulator will write random `UInt64` values at 100Hz (100 times per second, every 10ms).

The simulator will only write data when the app indicates it to start recording.
