void setup() {
  // put your setup code here, to run once:
pinMode(53,OUTPUT);

}

void loop() {
  // put your main code here, to run repeatedly:


//digitalWrite(53,HIGH);
digitalWrite(53,LOW);
//delay(1205);// delay for full emission at any power, at powers higher than 5mW bleed through light appears immediately
delay(10);
digitalWrite(53,LOW);
delay(83);


}
