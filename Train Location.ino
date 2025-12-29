#include <TinyGPSPlus.h>
#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include "ThingSpeak.h"

#define SS_PIN 5
#define RST_PIN 0

char ssid[] = "iPhone";   // your network SSID (name) 
char pass[] = "korterking";   // your network password
int keyIndex = 0;            // your network key Index number (needed only for WEP)
WiFiClient  client;


String Location;
float LocationLat = 9.530740;
float LocationLng = 6.470493;  
float LocationLat1 = 8.530452;
float LocationLng1= 3.470552;
float LOCLAT;
float LOCLONG;
String OldCardID = "";

const int buttonPin = 26;     // the number of the pushbutton pin
const int ledPin =  25;      // the number of the LED pin

// variables will change:
int buttonState = 0;   

unsigned long myChannelNumber = 2;
const char * myWriteAPIKey = "ME1OJFI0TESCCXI6";

static const uint32_t GPSBaud = 9600;


// The TinyGPSPlus object
TinyGPSPlus gps;

// RFID Object
MFRC522 rfid(SS_PIN, RST_PIN); // Instance of the class

MFRC522::MIFARE_Key key; 

// Init array that will store new NUID 
byte nuidPICC[4];

void setup()
{
  Serial.begin(115200);
  Serial2.begin(GPSBaud); //Begin GPS
  SPI.begin(); // Init SPI bus
  rfid.PCD_Init(); // Init MFRC522 
  WiFi.mode(WIFI_STA);   
  ThingSpeak.begin(client);  // Initialize ThingSpeak

   // initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);

for (byte i = 0; i < 6; i++) {
    key.keyByte[i] = 0xFF;
  }
  
 
  Serial.println(F("A demonstration of TinyGPSPlus with an attached GPS module and MIFARE Classic NUID"));
  Serial.print(F("Testing TinyGPSPlus library v. ")); Serial.println(TinyGPSPlus::libraryVersion());
  Serial.println();
  Serial.println(F("This code scan the MIFARE Classsic NUID."));
  Serial.print(F("Using the following key:"));
  printHex(key.keyByte, MFRC522::MF_KEY_SIZE);
  Serial.println();
}

void loop()
{
  
  // Connect or reconnect to WiFi
  if(WiFi.status() != WL_CONNECTED){
    Serial.println("Attempting to connect to SSID: ");
    Serial.print(ssid);
    while(WiFi.status() != WL_CONNECTED){
      WiFi.begin(ssid, pass); // Connect to WPA/WPA2 network. Change this line if using open or WEP network
      Serial.println(".");
      delay(5000);     
    } 
    Serial.println("\nConnected....");
  }

  // Check GPS or RFID and communicate it to Thingspeak server
  if (Serial2.available() > 0){
    if (gps.encode(Serial2.read())){
      displayInfo();
    }
  }else{
    rfidInfo();
  }

  emergency();

}


void displayInfo()
{
  Serial.print(F("Location: ")); 
  if (gps.location.isValid())
  {
    Serial.print(gps.location.lat(), 6);
    Serial.print(F(","));
    Serial.println(gps.location.lng(), 6);
    LOCLAT = gps.location.lat();
    LOCLONG = gps.location.lng();

    Serial.print("Lat : ");
    Serial.println(LOCLAT,6);
    Serial.print("Long: ")  ;
    Serial.println(LOCLONG, 6);

    Location = String(LOCLAT,6) + ", " + String(LOCLONG,6);
    Serial.println("Locat ; " + Location);

    ThingSpeak.setField(1, String(LOCLAT,6));
    ThingSpeak.setField(2, String(LOCLONG,6));
    ThingSpeak.setField(3, Location);

    ThingSpeak.setStatus(Location);
    int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
    if(x == 200){
      Serial.println("Channel update successful.");
    }
    else{
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }
    delay(2000);
  }
  else
  {
    Serial.println(F("INVALID"));
    rfidInfo();
    delay(1000);
  }
  Serial.println();
}

void rfidInfo(){
  
  // Reset the loop if no new card present on the sensor/reader. This saves the entire process when idle.
  if ( ! rfid.PICC_IsNewCardPresent())
    return;

  // Verify if the NUID has been readed
  if ( ! rfid.PICC_ReadCardSerial())
    return;

  Serial.print(F("PICC type: "));
  MFRC522::PICC_Type piccType = rfid.PICC_GetType(rfid.uid.sak);
  Serial.println(rfid.PICC_GetTypeName(piccType));

  // Check is the PICC of Classic MIFARE type
  if (piccType != MFRC522::PICC_TYPE_MIFARE_MINI &&  
    piccType != MFRC522::PICC_TYPE_MIFARE_1K &&
    piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
    Serial.println(F("Your tag is not of type MIFARE Classic."));
    return;
  }
  
  String CardID ="";
    for (byte i = 0; i < rfid.uid.size; i++) {
    CardID += rfid.uid.uidByte[i];
    }
   Serial.print("CardID is: ");  
   Serial.println(CardID);
   


  if(CardID == "6713075246" ){
     LOCLAT = LocationLat;
     LOCLONG = LocationLng;
  }
  else if(CardID == "163207132197"){
      LOCLAT = LocationLat1;
      LOCLONG = LocationLng1;
  }

   if( LOCLAT == 0 &&
     LOCLONG == 0){
    return;
  }
  

   Serial.print("Lat : ");
    Serial.println(LOCLAT,6);
    Serial.print("Long: ")  ;
    Serial.println(LOCLONG, 6);

    Location = String(LOCLAT,6) + ", " + String(LOCLONG,6);
    Serial.println("Locat ; " + Location);

    ThingSpeak.setField(1, String(LOCLAT,6));
    ThingSpeak.setField(2, String(LOCLONG,6));
    ThingSpeak.setField(3, Location);

    ThingSpeak.setStatus(Location);
    int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
    if(x == 200){
      Serial.println("Channel update successful.");
    }
    else{
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }

  // Halt PICC
  rfid.PICC_HaltA();

  // Stop encryption on PCD
  rfid.PCD_StopCrypto1();
  delay(2000);
}

void printHex(byte *buffer, byte bufferSize) {
  for (byte i = 0; i < bufferSize; i++) {
    Serial.print(buffer[i] < 0x10 ? " 0" : " ");
    Serial.print(buffer[i], HEX);
  }
}

void emergency(){
   // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);

  // check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  if (buttonState == HIGH) {
    // turn LED on:
    digitalWrite(ledPin, HIGH);
    Serial.println("Emergency!!!");
    ThingSpeak.setField(4, "Emergency!!!");

    ThingSpeak.setStatus("Emergency");
    int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
    if(x == 200){
      Serial.println("Channel update successful.");
    }
    else{
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }
    delay(2000);
    
  } else {
    // turn LED off:
    digitalWrite(ledPin, LOW);
  }

  
  
}
