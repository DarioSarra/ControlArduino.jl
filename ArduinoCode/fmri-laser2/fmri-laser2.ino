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
bool           NewVolume      = false;
int            VolumeCount    = 0;              // Counter of the images acquired by the scanner
int            RunVolumeCount = 0;              // Stores frame counter at the latest run beginning
int            StimVolumeCount= 0;              // Stores frame counter at the latest stim block start
int            EndingCount    = 0;              // Stores frame counter at the latest stim block end
int            WaitingIntVal  = -1;             // this is a place holder for int values that needs to be transmitted
int            StimVolumes    = WaitingIntVal;  // Number of images to stimulate
int            UnstimVolumes  = WaitingIntVal;  // Number of images to NOT stimulate
int            State          = 1;              // Switch State variable


// Stimulation parameters
int           StimCount    = 0; // variable to keep track of the current run as an index of the stim definition arrays
int           Stimulations = WaitingIntVal; // variable that determines how many different type of stimulations are to be run
int           idx;              // variable that ensures looping on the right stim indexes once the Stimulation count is more than the stimulation types

unsigned long StimOnset    = 0;
int           Pulse        = 10;       // PulseWidth
int           CurrentHZ    = 0;        // Saving Variable
int           StimFreq1[10];
int           StimDur1[10];
int           StimFreq2[10];
int           StimDur2[10];



void setup() {
  // put your setup code here, to run once:
  pinMode(OutputPin, OUTPUT);
  pinMode(A2, INPUT);

  Serial.begin(115200);
  Serial.println(String("Waiting for Inputs"));
  delay(100);
  
  WaitForNumericalInput(StimVolumes);
  WaitForNumericalInput(UnstimVolumes);
  WaitForNumericalInput(Stimulations);
 
  StimOnset = millis();
  memset(StimFreq1,-1,Stimulations*sizeof(int));//memeset is a function so it has to be called in the loop
  memset(StimDur1,-1,Stimulations*sizeof(int)); // also memset depends on the number of bits not array cells
  memset(StimFreq2,-1,Stimulations*sizeof(int));
  memset(StimDur2,-1,Stimulations*sizeof(int));

  WaitForIntArray(StimFreq1,Stimulations);
  WaitForIntArray(StimDur1,Stimulations);
  WaitForIntArray(StimFreq2,Stimulations);
  WaitForIntArray(StimDur2,Stimulations);

  Serial.println(String("All Good:") + ' ' + String(millis())); // Signal that all is well
  Serial.println("Volume,Time,State,Hz, StimCount");
  delay(10);
}

void loop() {
updatevolumes();// This counts TTLs coming from the scanner to

  switch (State) {
    case 1: // This is to wait 30 seconds before stim
    if (VolumeCount - RunVolumeCount >= UnstimVolumes) {
      StimOnset = millis();
      StimVolumeCount = VolumeCount;
      State = 2;
      //which = random(1,3);// This gives either 1 or 2, if which = 1 => 4Hz, if which = 2 => 12Hz
    }
    break;

    case 2:// This is where to control what stimulation should occur
    idx = StimCount%Stimulations; // return the correct idx to select the parameter ones all stimulations have been run
    stimtiming((VolumeCount - StimVolumeCount),StimFreq1[idx],StimDur1[idx],StimFreq2[idx],StimDur2[idx]);
    if (VolumeCount - StimVolumeCount >= StimVolumes) {
      EndingCount = VolumeCount;
      CurrentHZ = 0;
      State = 3;
    }
    break;

    case 3:// This is to wait 30 seconds after stimulation
    digitalWrite(OutputPin, LOW);
    if (VolumeCount - EndingCount >= UnstimVolumes) {
      RunVolumeCount = VolumeCount;
      ++StimCount;
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
  String(CurrentHZ) + ',' + \
  String(StimCount)
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

// Function to alternate between 2 stimulation frequencies one can be 0
void stimtiming (int volumecount, int hz1, int dur1, int hz2, int dur2) {
  if ((volumecount % (dur1 + dur2)) < dur1) {
    stimatfreq (StimOnset, hz1, Pulse);
    CurrentHZ = hz1;
  }
  else {
    stimatfreq (StimOnset, hz2, Pulse);
    CurrentHZ = hz2;
  }
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
//  delay(100);
}

void WaitForIntArray(int x[], int Size) { //In C and C++ there is no way (no way) that a function can know the size of an array unless you tell it. So the array size has to be a separate argument.
  for (int i = 0; i < Size; i++){
    while (x[i] == WaitingIntVal) {x[i] = SerialRead_Int_Value();}
//    delay(100);
    Serial.print(String(x[i])+ ' ');
  }
  Serial.println();
//  delay(1000);
}
