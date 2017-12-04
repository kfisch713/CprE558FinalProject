#pragma once

class PID {
public:
  PID(float kp, float ki, float kd);

  float set(float setpoint);
  float update(float curPoint);
  
private:
  float kp, ki, kd;
  float integral, lastError;
  float setpoint;

  unsigned long lastTime;
};
