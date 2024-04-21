

const int earthPin = 2;
const int airPin = 3;
const int firePin = 4;
const int waterPin = 5;
const int lovePin = 6;

const int earthLED = 9;
const int airLED = 10;
const int fireLED = 11;
const int waterLED = 12;

const int ledPin = 13;

bool earthOn = false;
bool airOn = false;
bool fireOn = false;
bool waterOn = false;
bool loveOn = false;

bool puzzleComplete = false;

void setup() {
  pinMode(ledPin, OUTPUT);  // declare the ledPin as as OUTPUT
  digitalWrite(ledPin, LOW);

  pinMode(earthPin, INPUT_PULLUP);
  pinMode(airPin, INPUT_PULLUP);
  pinMode(firePin, INPUT_PULLUP);
  pinMode(waterPin, INPUT_PULLUP);
  pinMode(lovePin, INPUT_PULLUP);

  pinMode(earthLED, OUTPUT);
  digitalWrite(earthLED, LOW);
  pinMode(airLED, OUTPUT);
  digitalWrite(airLED, LOW);
  pinMode(fireLED, OUTPUT);
  digitalWrite(fireLED, LOW);
  pinMode(waterLED, OUTPUT);
  digitalWrite(waterLED, LOW);

  Serial.begin(9600);       // use the serial port
}

void loop() {
  if (digitalRead(lovePin) == HIGH) {
    loveOn = false;
  }
  else {
    loveOn = true;
  }

  if (digitalRead(earthPin) == HIGH) {
    earthOn = false;
    digitalWrite(earthLED, HIGH);
  }
  else {
    earthOn = true;
    digitalWrite(earthLED, LOW);
  }

  if (digitalRead(airPin) == HIGH) {
    airOn = false;
    digitalWrite(airLED, HIGH);
  }
  else {
    airOn = true;
    digitalWrite(airLED, LOW);
  }

  if (digitalRead(firePin) == HIGH) {
    fireOn = false;
    digitalWrite(fireLED, HIGH);
  }
  else {
    fireOn = true;
    digitalWrite(fireLED, LOW);
  }

  if (digitalRead(waterPin) == HIGH) {
    waterOn = false;
    digitalWrite(waterLED, HIGH);
  }
  else {
    waterOn = true;
    digitalWrite(waterLED, LOW);
  }

  Serial.println(earthOn ? "EARTH:ON" : "EARTH:OFF");
  Serial.println(airOn ? "AIR:ON" : "AIR:OFF");
  Serial.println(fireOn ? "FIRE:ON" : "FIRE:OFF");
  Serial.println(waterOn ? "WATER:ON" : "WATER:OFF");
  Serial.println(loveOn ? "LOVE:ON" : "LOVE:OFF");

  puzzleComplete = earthOn && airOn && fireOn && waterOn && loveOn;

  if (puzzleComplete) {
    digitalWrite(ledPin, HIGH);
    Serial.println("PUZZLE:ON");

    digitalWrite(earthLED, LOW);
    digitalWrite(airLED, LOW);
    digitalWrite(fireLED, LOW);
    digitalWrite(waterLED, LOW);

    delay(1000);

    digitalWrite(earthLED, HIGH);
    digitalWrite(airLED, HIGH);
    digitalWrite(fireLED, HIGH);
    digitalWrite(waterLED, HIGH);
  }
  else {
    digitalWrite(ledPin, LOW);
    Serial.println("PUZZLE:OFF");
  }
   
  delay(100);  // delay to avoid overloading the serial port buffer
}
