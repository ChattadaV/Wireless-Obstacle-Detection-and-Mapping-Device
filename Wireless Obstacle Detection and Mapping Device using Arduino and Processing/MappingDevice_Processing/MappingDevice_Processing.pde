/* 
File Name: MappingDevice_Processing.pde
By Team 01: Chattada Viriyaphap (Pi) & Abdullah Arif
EE537 Intro to Embedded SYstems
Department of Electrical and Computer Engineering
The University of Alabama at Birmingham
Version Sept. 30, 2022
*/

import processing.serial.*;       // Import serial communication
import java.awt.event.KeyEvent;   // Import data reading from serial port
import java.io.IOException;       // Import IO Exception

// Initialization
Serial Port1;                     // Init serial port

PFont orcFont;                    // Init font class
int width = 1280;                 // Init display width in integer
int height = 720;                 // Init display height in integer

String angleAndDistance = "";     // Init angle and distance information in string
String angleString = "";          // Init angle information in string
String distanceString = "";       // Init distance in string
int angleStartPosition = 0;       // Init first index position of angle information in integer
int angleEndPosition = 0;         // Init last index position of angle information in integer
int distanceStartPosition = 0;    // Init first index position of distance information in integer
int distanceEndPosition = 0;      // Init last index position of distance information in integer
int angle;                        // Init angle information (°) in integer
int distance;                     // Init distance information (cm) in integer
float distancePixels;             // Init distance information (pixels) in float (32-bit)

Table table;                      // Init table for angle and distance information

// Set up
void setup() {

  // Display configuration
  size(1280, 720);                            // Configure display size to 1280x720
  //smooth();

  // Serial communication configuration
  Port1 = new Serial(this, "COM5", 9600);     // Set up serial communication with current parent and COM 5 port at 9600bps baud rate
  Port1.bufferUntil('d');                     // Buffer data until letter 'd' (end of each information block) before calling serialEvent()

  // Text font configuration
  orcFont = loadFont("Arial-Black-12.vlw");   // Load text font style
  textFont(orcFont);                          // Set up text font

  // Data table configuration
  table = new Table();                        // Set up table
  table.addColumn("Angle (degrees)");         // Add a column for angle information
  table.addColumn("Distance (cm)");           // Add a column for distance information
}

// Main loop
void draw() {
  
  // Serial communication
  serialEvent(Port1);                         // Start serial communication

  // Fading effect for previous data points
  fill(0, 3);                                 // Creates fading for previous data information displayed (white (RGB 0), fading style 3)
  rect(0, 0, width, 0.91 * height);           // Area for fading effect (initial x-coordinate, intial y-coordinate, final x-coordinate, final y-coordinate)

  // Calling functions to draw the map
  MapBackground();                            // Draw background of map
  MapObstacles();                             // Draw obstacles on screen
  MapText();                                  // Create various condition messages on screen
}

// Serial communication of serial port (data reading)
void serialEvent(Serial Port1) {

  if (Port1.available() > 0) {                                                                   // Check if incoming data exists

    angleAndDistance = Port1.readStringUntil('d');                                               // Read the data until letter 'd' (end of each information block)

    if (angleAndDistance != null) {                                                              // Check if incoming data is not null

      // Angle and distance information
      angleAndDistance = angleAndDistance.substring(0, angleAndDistance.length() - 1);           // Trim out data block to only contain angle information + 'a' + distance information

      // Angle information
      angleStartPosition = 0;                                                                    // Init first index position of angle information
      angleEndPosition = angleAndDistance.indexOf('a');                                          // Find last index position of angle information (before letter 'a')
      angleString = angleAndDistance.substring(angleStartPosition, angleEndPosition);            // Trim out data block to only contain angle information in string

      // Distance information
      distanceStartPosition = angleEndPosition + 1;                                              // Find fist index position of distance information (after letter 'a')
      distanceEndPosition = angleAndDistance.length();                                           // Find last index position of distance information
      distanceString = angleAndDistance.substring(distanceStartPosition, distanceEndPosition);   // Trim out data block to only contain distance information in string

      // Angle and distance conversion
      angle = int(angleString);                                                                  // Convert angle information to integer
      distance = int(distanceString);                                                            // Convert distance information to integer

      // Data table update
      TableRow newRow = table.addRow();                                                          // Create new row in the table for updated angle and distance information
      newRow.setString("Angle (degrees)", angleString);                                          // Insert angle information in angle column
      newRow.setString("Distance (cm)", distanceString);                                         // Insert distance information in distance column
      saveTable(table, "data/MapInformation.csv");                                               // Save the updated data as a .csv file in "data" folder
    }
  }
}

// Background display for map
void MapBackground() {
  pushMatrix();                                                                              // Pop background data onto the matrix stack

  // Set up background settings
  translate(width / 2, height / 1.1);                                                        // Init starting x-y coordinates
  noFill();                                                                                  // Creates hollow black grid between the lines, making fading effect possible
  stroke(255, 255, 255);                                                                     // White color line in uint8 RGB
  strokeWeight(1);                                                                           // Init line thickness

  // Half-circle arc lines for distance information
  for (float index = 1; index >= 0.25; index -= 0.25) {                                      // Four lines total
    arc(0, 0, index * (width - 50), index * (width - 50), PI, 2 * PI);                       // Arc line (intial x-coordinate, intial y-coordinate, width, height, initial angle, final angle)
  }

  // Linear lines for angle information
  for (int angle = 180; angle >= 0; angle -= 30) {                                           // Six lines total
    line(0, 0, -0.48 * width * cos(radians(angle)), -0.48 * width * sin(radians(angle)));    // Linear line (intial x-coordinate, initial y-coordinate, final x-coordinate, final y-coordinate)
  }

  popMatrix(); // Pop background data off the matrix stack
}

// Obstacles display for map
void MapObstacles() {
  pushMatrix();                                                                                   // Pop obstacle information onto the matrix stack

  // Set up obstacle settigs
  translate(width / 2, height / 1.1);                                                             // Init starting x-y coordinates
  fill(255, 255, 255);                                                                            // Solid white color in uint8 RGB

  if (distance < 60) {                                                                           // Check if distance is within preferred range (<100cm)
    distancePixels = (distance * height) / 120;                                                  // Convert distance information from integers to pixels
    circle(distancePixels * cos(radians(angle)), -distancePixels * sin(radians(angle)), 20);     // Circle object to represent obstacle (x-coordinate, y-coordinate, size)
  }

  popMatrix();                                                                                    // Pop obstacle information off the matrix stack
}

// Various condition text messages on map display
void MapText() {                                                           // draws the texts on the screen
  pushMatrix();                                                            // Pop text information onto the matrix stack

  // Set up text background settings
  fill(0, 0, 0);                                                           // Solid black color in uint8 RGB
  rect(0, 0.91 * height, width, height);                                   // Area for black background for better text contrast (intial x-coordinate, intial y-coordinate, width, height)

  // Set up text settings
  fill(255, 255, 255);                                                     // Solid white color in uint8 RGB
  textSize(25);                                                            // Configure text size

  // Changing angle and distance information
  text("Angle: " + angle +" °", width-width*0.5, height*0.98);             // Angle information (°) (x-coordinate, y-coordinate)
  text("Distance: " + distance +" cm", width-width*0.3, height*0.98);      // Distance information (cm) (x-coordinate, y-coordinate)

  // In-range/out-of-range information
  if (distance > 100) {                                                    // Check if obstacle is out of range (>100cm)
    text("Object Out of Range (>60cm)", 0.1 * width, 0.98 * height);      // Display condition message (x-coordinate, y-coordinate)
  }

  // Static distance information
  text("100cm", 0.02 * width, 0.94 * height);   // Display 100cm distance condition message (x-coordinate, y-coordinate)
  text("75cm", 0.12 * width, 0.94 * height);    // Display 75cm distance condition message (x-coordinate, y-coordinate)
  text("50cm", 0.23 * width, 0.94 * height);    // Display 50cm distance condition message (x-coordinate, y-coordinate)
  text("25cm", 0.35 * width, 0.94 * height);    // Display 25cm distance condition message (x-coordinate, y-coordinate)
  text("0cm", 0.48 * width, 0.94 * height);     // Display 0cm distance condition message (x-coordinate, y-coordinate)
  text("25cm", 0.6 * width, 0.94 * height);     // Display 25cm distance condition message (x-coordinate, y-coordinate)
  text("50cm", 0.72 * width, 0.94 * height);    // Display 50cm distance condition message (x-coordinate, y-coordinate)
  text("75cm", 0.83 * width, 0.94 * height);    // Display 75cm distance condition message (x-coordinate, y-coordinate)
  text("100cm", 0.93 * width, 0.94 * height);   // Display 100cm distance condition message (x-coordinate, y-coordinate)

  // Static angle information
  textSize(20); // Configure text size
  text("30°", 0.93 * width, 0.47 * height);     // Display 30° angle condition message (x-coordinate, y-coordinate)
  text("60°", 0.74 * width, 0.15 * height);     // Display 60° angle condition message (x-coordinate, y-coordinate)
  text("90°", 0.49 * width, 0.04 * height);     // Display 90° angle condition message (x-coordinate, y-coordinate)
  text("120°", 0.23 * width, 0.15 * height);    // Display 120° angle condition message (x-coordinate, y-coordinate)
  text("150°", 0.04 * width, 0.47 * height);    // Display 150° angle condition message (x-coordinate, y-coordinate)

  popMatrix(); // Pop text information off the matrix stack
}
