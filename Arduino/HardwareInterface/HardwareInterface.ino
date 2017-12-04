#include <SPI.h>

/* Connections
 * Encoder1:
 *   CH_A: 21
 *   CH_B: 20
 * Encoder 2:
 *   CH_A: 19
 *   CH_B: 18
 * DAC:
 *   MOSI: 51
 *   MISO: 50
 *   SCK: 52
 *   Chip Select (CS): 4
 * Zybo:
 *   Arduino TX: 16
 *   Arduino RX: 17
  */

const int PIN_CS = 4;
const unsigned long UPDATE_PERIOD = 10000; //In microseconds

//const float COUNT_TO_METERS = 0.000028947f;

const uint8_t HEADER_VALUE = 0xA5;

int32_t encCount1 = 0, encCount2 = 0;
uint8_t encState1, encState2;

unsigned long long updateTime = 0;

void setup() {
  Serial.begin(115200);
  Serial2.begin(115200);

  //Initialize SPI CS pin
  pinMode(PIN_CS, OUTPUT);
  digitalWrite(PIN_CS, HIGH);

  //Set encoder pins to input
  DDRD &= 0x00;

  //Read initial encoder states
  uint8_t pind = PIND;
  encState1 = pind & 0x03;
  encState2 = (pind >> 2) & 0x03;

  //Configure PC interrupts on encoder pins
  attachInterrupt(digitalPinToInterrupt(18), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(19), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(20), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(21), updateEncoders, CHANGE);

  SPI.begin();

  updateTime = micros() + UPDATE_PERIOD;
}

void loop() {
  noInterrupts();
  auto countCopy1 = encCount1;
  auto countCopy2 = encCount2;
  interrupts();



  if(Serial2.available() >= 3) {
    Serial.print("Available: ");
    Serial.println(Serial2.available());
    char ch;
    while(Serial2.available() >= 3 && (ch = Serial2.read()) != HEADER_VALUE) {
      Serial.print("[Error] Received invalid header value: ");
      Serial.println(ch, HEX);
    }

    uint16_t dacVal = (Serial2.read() & 0xFF) | (Serial2.read() & 0xFF) << 8;
    updateDAC(dacVal);

    Serial.print("DAC Update: ");
    Serial.println(dacVal);
  }

  auto curTime = micros();

  if(curTime >= updateTime) {
    updateTime += UPDATE_PERIOD;

    Serial2.write(reinterpret_cast<const char*>(&HEADER_VALUE), sizeof(HEADER_VALUE));
    Serial2.write(reinterpret_cast<char*>(&countCopy1), sizeof(countCopy1));
    Serial2.write(reinterpret_cast<char*>(&countCopy2), sizeof(countCopy2));

    Serial.print("Encoder Update: ");
    Serial.print(countCopy1);
    Serial.print("\t\t");
    Serial.println(countCopy2); 
  }
}

void updateDAC(uint16_t value) {
  SPI.beginTransaction(SPISettings(14000000, MSBFIRST, SPI_MODE2));

  uint8_t data[3];
  data[0] = 0x40 | (value >> 10);
  data[1] = 0xFF & (value >> 2);
  data[2] = (value & 0x03) << 6;

  digitalWrite(PIN_CS, LOW);

  SPI.transfer(data[0]);
  SPI.transfer(data[1]);
  SPI.transfer(data[2]);

  digitalWrite(PIN_CS, HIGH);

  SPI.endTransaction();
}

void updateEncoders() {
  const int STATE_TABLE[4][4] {
    {0, 1, -1, 0},
    {-1, 0, 0, 1},
    {1, 0, 0, -1},
    {0, -1, 1, 0}
  };

  uint8_t pind = PIND;
  uint8_t newEncState1 = pind & 0x03;
  uint8_t newEncState2 = (pind >> 2) & 0x03;

  encCount1 += STATE_TABLE[encState1][newEncState1];
  encCount2 += STATE_TABLE[encState2][newEncState2];

  encState1 = newEncState1;
  encState2 = newEncState2;
}

