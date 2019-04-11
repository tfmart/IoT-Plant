# IoT Plant

This application let users register their plants to check their humidity, so he can check whenever they need to be watered. The data can either be read from a device, such as a Arduino with a humidty sensor, or can be input manually inside the app.

![Plant List](https://d3r69eeiwn2k86.cloudfront.net/items/3U1T233i0R401V2D183F/iotplant.png)

Currently, the app get it's data from a Firebase Realtime Database, in which it displays the plants and their latest humidity value. 

![Plant Detail](https://d3r69eeiwn2k86.cloudfront.net/items/35162c0q0a153I2j3N2b/iotplant2.PNG)

When the user taps a plant, he's presetented with more option, such as to change the plant's image, input an humidity value manually or to check the full history of humidity values, which are also stored in the database

![Add Plant](https://d3r69eeiwn2k86.cloudfront.net/items/2m3i0c2R1L2j1U400H00/iotplant3.PNG)

Back to the plant list screen, if the user taps the '+' button, he can register a new plant, by taking a photo of it and giving it a name. However, if the CoreML model used in this app recognizes the plant from the image chosen by the user, it will suggest a name to be used. When the user adds the plant, it's automatically uploaded to the Firebase database as well.

## Goals

- [x] CoreML Model to identify plants
- [x] Store plants on Firebase
- [x] 3D Touch Shortcuts
- [ ] iOS Widget to display plants'info
- [ ] SiriKit Integration to get a plant's humidity by voice
- [ ] watchOS companion app
