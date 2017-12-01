#include "PID.h"

#include <Arduino.h>
#include <math.h>

PID::PID(float _kp, float _ki, float _kd)
  : kp  {_kp}
  , ki  {_ki}
  , kd  {_kd}
  , integral  {0.f}
  , lastError {0.f}
  , setpoint  {0.f}
  , lastTime  {0} {

}

float PID::set(float _setpoint) {
  setpoint = _setpoint;
}

float PID::update(float curpoint) {
  unsigned long curTime = micros();
  
  if(lastTime == 0) {
    lastTime = curTime;

    return 0.f;
  }
  else {
    float dt = (curTime - lastTime) * 0.000001;
  
    float error = setpoint - curpoint;
  
    integral += error*dt;
  
    float actuation = kp*error + ki*integral + kd*(error - lastError)/dt;
  
    lastError = error;
    lastTime = curTime;
  
    return actuation;
  }
}
