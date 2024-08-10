#include <Servo.h>
int ledred = 13;
int ledwhite = 12;
int buzz = 11;
int ledgreen = 10;
int sensor_flame = A0;
int sensor_soil = A5;
int flame = 0;
int soil = 0;
Servo motor;

void setup() {

  pinMode(ledred,OUTPUT);
  pinMode(ledwhite,OUTPUT);
  pinMode(buzz,OUTPUT);
  pinMode(ledgreen,OUTPUT);
  pinMode(flame,INPUT);
  pinMode(soil,INPUT);
  motor.attach(7);
  Serial.begin(9600);
  digitalWrite(ledgreen,HIGH);

}

void loop() {
    
  flame = analogRead(sensor_flame);
  soil = analogRead(sensor_soil);
  Serial.println(flame);
  delay(200);
  Serial.println(soil);
  delay(200);
 // motor.write(0);
 // delay(1000);
  if (flame<100 || soil>800) { 
    if(flame<100) {
      digitalWrite(ledred,HIGH);
      digitalWrite(buzz,HIGH);
    }
    digitalWrite(ledgreen,LOW);
    motor.write(90);
    digitalWrite(ledwhite, HIGH);
  }
  else{
    digitalWrite(ledred,LOW);
    digitalWrite(buzz,LOW);
    digitalWrite(ledwhite, LOW);
    digitalWrite(ledgreen, HIGH);
    motor.write(0);
  }
}
