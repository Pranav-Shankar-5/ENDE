#include <Servo.h>
int ledgreen = 10;
int ledred = 13;
int ledwhite = 12;
int buzz = 11;
int trigpin = 9;
int echopin = 8;
int distance;
float duration;
float cm;
Servo motor;

void setup() {

  pinMode(ledgreen,OUTPUT);
  pinMode(ledred,OUTPUT);
  pinMode(ledwhite,OUTPUT);
  pinMode(buzz,OUTPUT);
  motor.attach(7);
  pinMode(trigpin,OUTPUT);
  pinMode(echopin,INPUT);
  Serial.begin(9600);
  digitalWrite(ledgreen,HIGH);

}

void loop() {
  
  digitalWrite(trigpin,LOW);
  delay(2);
  digitalWrite(trigpin,HIGH);
  delayMicroseconds(10);
  digitalWrite(trigpin,LOW);
  duration = pulseIn(echopin,HIGH);
  cm = (duration/58.82);
  distance = cm;
  Serial.println(distance);
  
  if(distance<30) {
    //digitalWrite(ledred,HIGH);
    digitalWrite(buzz,HIGH);
    digitalWrite(ledgreen,LOW);
    motor.write(180);    
    digitalWrite(ledwhite, HIGH);
    delay(2000);
  }
  else{
    //digitalWrite(ledred,LOW);
    digitalWrite(buzz,LOW);
    digitalWrite(ledwhite, LOW);
    digitalWrite(ledgreen, HIGH);
    motor.write(0);
    delay(100);
  }
}