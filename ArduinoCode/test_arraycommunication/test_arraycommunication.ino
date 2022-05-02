int WaitingIntVal = -1;
int Stimulations = WaitingIntVal;


void setup() {
  
  Serial.begin(115200);
  delay(100);
  Serial.println(String("Waiting for Inputs"));
 
  WaitForNumericalInput(Stimulations);
  int Arr[Stimulations];
  for (int i = 0; i <= Stimulations; i++) {
    Arr[i]= i;
    Serial.println(Arr[i]);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}

/*------------------------------------------Input Functions--------------------------------------------------------------- */
/* -------------------------------------------------------------------
   --------------------  Receive Number ---------------------------
   convert a string into a Int value to be used in the code*/
 int SerialRead_Int_Value() {
    boolean NewData = true;
    int dataNumber;
    boolean recvInProgress = false;
    char startMarker = '<';
    char endMarker = '>';
    char rc;
    static byte ndx = 0;
    const byte numChars = 32;
    char receivedChars[numChars];

  while(NewData){
    if (Serial.available() > 0) {
        rc = Serial.read();
        if (recvInProgress == true) {
          if (rc != endMarker) {
              receivedChars[ndx] = rc;
              ndx++;
              if (ndx >= numChars) {
                  ndx = numChars - 1;
              }
          }
          else {
              receivedChars[ndx] = '\0'; // terminate the string
              ndx = 0;
              NewData = false;
          }
        }
        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
  }
  dataNumber = atoi(receivedChars);
  return dataNumber;
}

/* -------------------- Function to send variables as a csv string -------------------- 
the & symbol enable the call-by-reference option otherwise it would only copy x value*/
void WaitForNumericalInput(int &x){
  while (x == WaitingIntVal) {x = SerialRead_Int_Value();}
  Serial.println(String(x) + ' ' + String(millis())); // Signal that all is well
  delay(100);
}

void WaitForIntArray(int x[], int siz) { //In C and C++ there is no way (no way) that a function can know the size of an array unless you tell it. So the array size has to be a separate argument.
  for (int i = 0; i < siz; i++){
    Serial.print(String(x[i]) + ' ');
    while (x[i] == WaitingIntVal) {x[i] = SerialRead_Int_Value();}
    Serial.print(x[i]+ ' ');
  }
  Serial.println();
  delay(100);
}
