# BLEClient
### Bluetooth Low Energy with the ability to view specific characteristics and send them to UDP.

Description of the interface:

#### Buttons:
+ Once - scanning the bluetooth devices around for a preset time (5 seconds)
+ Always - a constant devices scanning
+ Stop - stop scanning bluetooth
+ All - Search for all devices around (Yes), or one or two with the specified number UUID (No)
 
#### Table of devices: 
+ The table displays scanned devices around: contains the device name and address.

UUID service: input and display characteristics for a specific UUID.

Delete: clear the table with the characteristics of the services.

#### Table of characteristics:
+ UIID and value characteristics.
+ + / -: respectively, the right to read, write, receive notifications from the characteristic.
+ Read selected characteristic (needed when notifications are unavailable)
+ Write to BLE: writing a randomly generated string to the selected characteristic

Transfer: UDP data transfer to the required server

<center>
<img src="https://user-images.githubusercontent.com/12527666/36307498-830b448a-132d-11e8-9f0b-577c6390d329.PNG" width="250">
</center>
