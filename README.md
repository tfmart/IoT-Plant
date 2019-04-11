# IoT Plant

This application let users register their plants to check their humidity, so he can check whenever they need to be watered. The data can either be read from a device, such as a Arduino with a humidty sensor, or can be input manually inside the app.

![Plant List](https://d3r69eeiwn2k86.cloudfront.net/items/403a1B3s0L0S3p2k3S1P/plant1.png)

Currently, the app get it's data from a Firebase Realtime Database, in which it displays the plants and their latest humidity value. 

![Plant Detail](https://d3r69eeiwn2k86.cloudfront.net/items/0g070U1O2c2w0f1x310d/plant2.png)

When the user taps a plant, he's presetented with more option, such as to change the plant's image, input an humidity value manually or to check the full history of humidity values, which are also stored in the database

![Add Plant](https://d3r69eeiwn2k86.cloudfront.net/items/2B3b3U313k192T0R1u35/plant3.png)

Back to the plant list screen, if the user taps the '+' button, he can register a new plant, by taking a photo of it and giving it a name. However, if the CoreML model used in this app recognizes the plant from the image chosen by the user, it will suggest a name to be used. When the user adds the plant, it's automatically uploaded to the Firebase database as well.

## Goals

- [x] CoreML Model to identify plants
- [x] Store plants on Firebase
- [x] 3D Touch Shortcuts
- [ ] iOS Widget to display plants'info
- [ ] SiriKit Integration to get a plant's humidity by voice
- [ ] watchOS companion app
