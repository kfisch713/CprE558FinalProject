

const uint8_t UPDATE_PIN = 3;
const uint8_t DAC_INPUT = A0;

bool updateFlag;

int32_t encCount1 = 0, encCount2 = 0;
uint8_t encState1, encState2;

void setup() {
  updateFlag = false;
  
  analogReference(EXTERNAL);

  Serial.begin(115200);
  Serial.println("Time, Cart_Position, Pendulum_Angle, Voltage");

  //Set encoder pins to input
  DDRD &= 0x00;
  pinMode(UPDATE_PIN, INPUT);

  //Read initial encoder states
  uint8_t pind = PIND;
  encState1 = pind & 0x03;
  encState2 = (pind >> 2) & 0x03;

  //Configure PC interrupts on encoder pins
  attachInterrupt(digitalPinToInterrupt(18), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(19), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(20), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(21), updateEncoders, CHANGE);
  attachInterrupt(digitalPinToInterrupt(UPDATE_PIN), [](){ updateFlag=true; }, RISING);
}

void loop() {
  if(updateFlag) {
    updateFlag = false;
    
    noInterrupts();
    auto countCopy1 = -encCount1;
    auto countCopy2 = -encCount2;
    interrupts();

    auto voltage = analogRead(DAC_INPUT);

    Serial.print(millis()/1000.f, 3); Serial.print(",");
    Serial.print(countCopy1 / 43985.f, 6); Serial.print(",");
    Serial.print(countCopy2 * PI / 2048.f, 6); Serial.print(",");
    Serial.println(voltage * 20.f / 1023.f - 10.f, 6);
  }
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
