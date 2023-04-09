/* 
File Name: MappingDevice_Arduino.ino
By Team 01: Chattada Viriyaphap (Pi) & Abdullah Arif
EE537 Intro to Embedded SYstems
Department of Electrical and Computer Engineering
The University of Alabama at Birmingham
Version Sept. 30, 2022
*/

#include <Servo.h>                         // Import servo library
#include "SoftwareSerial.h"                // Import serial communication library
#include "Arduino.h"                       // Import Arduino library for other miscellanous function

// Initialization
const byte rxPin = 10;                            // Init pin 10 on Arduino board as receiver (transmitter on HC-05 bluetooth module)
const byte txPin = 11;                            // Init pin 11 on Arduino board as transmitter (receiver on HC-05 bluetooth module)
SoftwareSerial BTSerial(rxPin, txPin);            // Init serial communication of HC-05 bluetooth module (RX, TX) 
                                                  // Connect pin 10 Arduino to pin TX HC-05 // Connect pin 11 Arduino to pin RX HC-05

Servo servo1;                                     // Init servo class
int servoPin = 9;                                 // Init pin 8 as servo pin

#define echoPin 2                                 // Init pin 2 on Arduino board as echo pin on HC-SR04 sensor module
#define trigPin 3                                 // Init pin 3 on Arduino board as trigger pin on HC-SR04 sensor module

long duration;                                    // Init time duration variable in long type
int distance;                                     // Init distance variable in integer type
int angle = 0;                                   // Init angle variable in integer type

// Set up
void setup() {
  pinMode(trigPin, OUTPUT);                       // Connect trigger pin HC-SR04 as output
  pinMode(echoPin, INPUT);                        // Connect echo pin of HC-SR04 as output

  BTSerial.begin(9600);                           // Start serial communication (bluetooth) at 9600bps baud rate
  servo1.attach(servoPin);                        // Start servo connection with servo pin
}

// Main loop
void loop() {

  // Servo rotates to the right
  for (int angle = 0; angle <= 180; angle++) {    // Servo angle ranges from 0° to 180° at an increment of one
    servo1.write(angle);                          // Servo rotates to specified angle
    delay(30);                                    // Delay for 30ms to allow servo to reach its specified angle

    servo1.detach();                              // Stop servo connection with servo pin

    distance = findDistance();                    // Calculate distance based on sound reflection time measured

    BTSerial.print(angle);                        // Print angle information using bluetooth serial communication
    BTSerial.print('a');                          // Print letter 'a' to separate angle and distance information using bluetooth serial communication
    BTSerial.print(distance);                     // Print distance information using bluetooth serial communication
    BTSerial.print('d');                          // Print letter 'd' to indicate the end of angle and distance data information block using bluetooth serial communication

    servo1.attach(servoPin);                      // Start servo connection with servo pin
  }

  // Servo rotates to the left
  for (int angle = 180; angle >= 0; angle--) {    // Servo angle ranges from 180° to 0° at an increment of one
    servo1.write(angle);                          // Servo rotates to specified angle
    delay(30);                                    // Delay for 30ms to allow servo to reach its specified angle

    servo1.detach();                              // Stop servo connection with servo pin

    distance = findDistance();                    // Calculate distance based on sound reflection time measured

    BTSerial.print(angle);                        // Print angle information using bluetooth serial communication
    BTSerial.print('a');                          // Print letter 'a' to separate angle and distance information using bluetooth serial communication
    BTSerial.print(distance);                     // Print distance information using bluetooth serial communication
    BTSerial.print('d');                          // Print letter 'd' to indicate the end of angle and distance data information block using bluetooth serial communication

    servo1.attach(servoPin);                      // Start servo connection with servo pin
  }
}

// Distance calculation function
int findDistance() {

  // Send ultrasound signal
  digitalWrite(trigPin, LOW);                     // Clear trigger pin of HC-SR04
  delayMicroseconds(1);                           // Delay for 1us to allow trigger pin of HC-SR04 to change its state
  digitalWrite(trigPin, HIGH);                    // Enable trigger pin of HC-SR04
  delayMicroseconds(10);                          // Delay for 10us to allow trigger pin of HC-SR04 to change its state and send ultrasound
  digitalWrite(trigPin, LOW);                     // Clear trigger pin of HC-SR04

  // Calculate distance from ultrasound reflection time
  duration = pulseIn(echoPin, HIGH);              // Record ultrasound reflection time in ms
  distance = duration * 0.034 / 2;                // Calculate distance ultrasound travelled based on ultrasound reflection time (divide by 2 to represent time it takes to travel back and forth)

  return distance;                                // Return calculated distance
}