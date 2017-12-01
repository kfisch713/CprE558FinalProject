#include <SPI.h>

const int PIN_CS = 4;
const unsigned long UPDATE_PERIOD = 10000; //In microseconds

//const float COUNT_TO_METERS = 0.000028947f;

const uint8_t HEADER_VALUE = 0xA5;

int32_t encCount1 = 0, encCount2 = 0;
uint8_t encState1, encState2;

unsigned long long updateTime = 0;

void setup() {
  Serial.begin(115200);
  Serial1.begin(115200);

  //Initialize SPI CS pin
  pinMode(PIN_CS, OUTPUT);
  digitalWrite(PIN_CS, HIGH);

  //Set encoder pins to input
  DDRB &= 0x00;

  //Read initial encoder states
  uint8_t portb = PORTB;
  encState1 = portb & 0x03;
  encState2 = (portb >> 2) & 0x03;

  //Configure PC interrupts on encoder pins
  attachInterrupt(0, updateEncoders, CHANGE);
  attachInterrupt(1, updateEncoders, CHANGE);
  attachInterrupt(2, updateEncoders, CHANGE);
  attachInterrupt(3, updateEncoders, CHANGE);

  SPI.begin();

  updateTime = micros() + UPDATE_PERIOD;
}

void loop() {
  noInterrupts();
  auto countCopy1 = encCount1;
  auto countCopy2 = encCount2;
  interrupts();

  Serial1.write(reinterpret_cast<const char*>(&HEADER_VALUE), sizeof(HEADER_VALUE));
  Serial1.write(reinterpret_cast<char*>(&countCopy1), sizeof(countCopy1));
  Serial1.write(reinterpret_cast<char*>(&countCopy2), sizeof(countCopy2));

  if(Serial1.available() >= 3) {
    char ch;
    while(Serial1.available() >= 3 && (ch = Serial1.read()) != HEADER_VALUE) {
      Serial.print("[Error] Received invalid header value: ");
      Serial.println(static_cast<int>(ch), HEX);
    }

    uint16_t dacVal = (Serial1.read() & 0xFF) | (Serial1.read() & 0xFF) << 8;
    updateDAC(dacVal);

    Serial.print("DAC Update: ");
    Serial.println(dacVal);
  }

  auto curTime = micros();

  if(curTime >= updateTime) {
    updateTime += UPDATE_PERIOD;

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

  uint8_t portb = PORTB;
  uint8_t newEncState1 = portb & 0x03;
  uint8_t newEncState2 = (portb >> 2) & 0x03;

  encCount1 += STATE_TABLE[encState1][newEncState1];
  encCount2 += STATE_TABLE[encState2][newEncState2];

  encState1 = newEncState1;
  encState2 = newEncState2;
}

