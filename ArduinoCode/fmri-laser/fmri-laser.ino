#define ttl A2
#define read_ttl !digitalRead(ttl)

// Pin settings
int            OutputPin     = 53; // laser stimulation PORT: LZR 

// Temporary variables for debugging
boolean        Periodic      = true;
unsigned long  Start         = millis();
int            Begin         = -1;

// Condition variables
boolean        DuringStim    = true;
boolean        Stim          = true;     // Control variable to skipstim completely
boolean        StimBlock     = true;     // variable to control blocks of stim and no stim


// Frame count variables
bool           NewVolume     = false;
int            VolumeCount   = 0;              // Counter of the images acquired by the scanner
int            RunCount      = 0;              // Stores frame counter at the latest run beginning
int            StimCount     = 0;              // Stores frame counter at the latest stim block start
int            EndingCount   = 0;              // Stores frame counter at the latest stim block end
int            WaitingIntVal = -1;             // this is a place holder for int values that needs to be transmitted
int            StimVolumes   = WaitingIntVal;  // Number of images to stimulate
int            UnstimVolumes = WaitingIntVal;  // Number of images to NOT stimulate
int            State         = 1;              // Switch State variable


// Stimulation parameters
unsigned long  StimOnset     = 0;
int            StimFreq[]    = {0,2};    // Vector of alternative frequencies
int            which         = 2;        // Defines the stimulation kind - which = 1 => 4Hz, if which = 2 => 12Hz
int            Pulse         = 10;       // PulseWidth
int            CurrentHZ     = 0;        // Saving Variable


void setup() {
  // put your setup code here, to run once:
  pinMode(OutputPin, OUTPUT);
  pinMode(A2, INPUT);
  StimOnset = millis();
  Serial.begin(115200);
  //Serial.println("Type 'S' to start");
  Serial.println(String("Waiting for Inputs"));
  delay(100);
  WaitForNumericalInput(StimVolumes);
  WaitForNumericalInput(UnstimVolumes);
  Serial.println(String("All Good:") + ' ' + String(millis())); // Signal that all is well
  Serial.println("Volume,Time,State,Hz");
}

void loop() {
updatevolumes();// This counts TTLs coming from the scanner to

  switch (State) {
    case 1: // This is to wait 30 seconds before stim
    if (VolumeCount - RunCount >= UnstimVolumes) {
      StimOnset = millis();
      StimCount = VolumeCount;
      State = 2;
      //which = random(1,3);// This gives either 1 or 2, if which = 1 => 4Hz, if which = 2 => 12Hz
    }
    break;

    case 2:// This is where to control what stimulation should occur
    if (which == 1) {
      lowstim ();
    }
    else if (which == 2) {
      highstim ();
    }
    if (VolumeCount - StimCount > StimVolumes) {
      EndingCount = VolumeCount;
      CurrentHZ = 0;
      State = 3;
    }
    break;

    case 3:// This is to wait 30 seconds after stimulation
    digitalWrite(OutputPin, LOW);
    if (VolumeCount - EndingCount > UnstimVolumes) {
      RunCount = VolumeCount;
      State = 1;
    }
    break;
  }
 }
  
/*------------------------------------------Saving Functions--------------------------------------------------------------- */
void savestatus () {
  Serial.println(String(VolumeCount) + ',' + \
  String(millis()) + ',' + \
  String(State) + ',' + \
  String(CurrentHZ)
  );
}

/*------------------------------------------TTL Functions--------------------------------------------------------------- */

void updatevolumes () {
  if ((read_ttl) && !(NewVolume)) {
    NewVolume = true;
    ++VolumeCount;
    savestatus ();
  }
  else if (!(read_ttl) && NewVolume) {
    NewVolume = false;
  }
}
/*------------------------------------------Stimulation Functions------------------------------------------------------- */
// control the stimulation frequency

void stimatfreq (long onset, int freq, int pulse) {
  if ((millis()-onset)*freq % 1000 < pulse*freq){
    digitalWrite(OutputPin, HIGH);
  }
  else {
    digitalWrite(OutputPin, LOW);
  }
}

// Create a boolean variable to alternate periodo of stimulated and unstimulated volumes
// counting the frame received from the start of the last block of stimulation 
// it checks wheter the stimulation should be on or off at this point: 
// for intance 12Hz requires stim 5 seconds on and 10 seconds Off
void stimtiming (int volumecount, int framehigh, int framelow) {
  if ((volumecount % (framehigh + framelow)) <= framehigh) {
    Stim = true;
  }
  else {
    Stim = false;
  }
}
//void stimtiming (int volumecount, int firsthz, int firstvols, int secondhz, int secondvols) {
//  if ((volumecount % (firstvols + secondvols)) <= firstvols) {
//    stimatfreq (StimOnset, firsthz, Pulse);
//  }
//  else {
//    stimatfreq (StimOnset, secondhz, Pulse);
//  }
//}

void highstim () {
  stimtiming ((VolumeCount - StimCount), 5, 10);
    if (Stim) {
      CurrentHZ = 12;
      stimatfreq (StimOnset, 12, Pulse);
    }
    else {
      CurrentHZ = 0;
      digitalWrite(OutputPin, LOW);
    }
}

void lowstim () {
  CurrentHZ = 4;
  stimatfreq (StimOnset, 4, Pulse);
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
  while (x == -1) {x = SerialRead_Int_Value();}
  Serial.println(String(x) + ' ' + String(millis())); // Signal that all is well
  delay(100);
}
