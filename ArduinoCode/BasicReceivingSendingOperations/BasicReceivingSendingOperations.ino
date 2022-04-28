int WaitingIntVal       = -1; // this is a place holder for int values that needs to be transmitted
int StimulatedVolumes   = WaitingIntVal;
int UnstimulatedVolumes = WaitingIntVal;

void setup() {
  delay(500);
  Serial.begin(115200);
  delay(500);
  Serial.println(String("Waiting for Inputs"));

  WaitForNumericalInput(StimulatedVolumes);
  WaitForNumericalInput(UnstimulatedVolumes);

  Serial.println(String("All Good:") + ' ' + String(millis())); // Signal that all is well
}

void loop() {
  delay(5000);
  SaveState();
}

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
  while (x == -1) {x = SerialRead_Int_Value();}
  Serial.println(String(x) + ' ' + String(millis())); // Signal that all is well
  delay(100);
}

/* -------------------- Function to send variables as a csv string -------------------- */
 void SaveState() {
  Serial.println(String(StimulatedVolumes) + ',' + \
  String(UnstimulatedVolumes));
}
 
