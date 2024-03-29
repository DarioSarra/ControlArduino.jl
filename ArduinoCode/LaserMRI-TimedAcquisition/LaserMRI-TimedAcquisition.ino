#define ttl A2
#define read_ttl !digitalRead(ttl)

// Pin settings
int            LaserPin     = 53; // laser stimulation
int            LightPin     = 51;

// Volume count variables
bool           NewVolume      = false;
int            VolumeCount    = 0;              // Counter of the images acquired by the scanner
int            RunVolumeCount = 0;              // Stores frame counter at the latest run beginning
int            InStimVolumeCount= 0;            // Stores frame counter at the latest stim block start
int            EndingCount    = 0;              // Stores frame counter at the latest stim block end
int            ResetVolume    = 0;              // Sores frame counter at the end of the post stimulation period

// States to control no stim and stim periods throughout the run
int            StimState      = 1;              // Switch Stimulation State (laser off-on)
int            RunState       = 1;              // Switch Run State (Pre, during and post stim) 

// Input volume counts
int            WaitingIntVal   = -1;             // this is a place holder for int values that needs to be transmitted
int            PreStimVolumes  = WaitingIntVal;  // Number of volumes to wait before stim
int            InStimVolumes   = WaitingIntVal;  // Number of volumes to use stimulation
int            PostStimVolumes = WaitingIntVal;  // Number of volumes to wait after stim
int            UnstimVolumes   = WaitingIntVal;  // Number of volumes NOT to stimulate in Stim phase
int            StimVolumes     = WaitingIntVal;  // Number of volumes to stimulate in Stim phase



// Stimulation parameters
int           StimCount    = 0; // variable to keep track of the current run as an index of the stim definition arrays
int           Stimulations = WaitingIntVal; // variable that determines how many different type of stimulations are to be run
int           idx;              // variable that ensures looping on the right stim indexes once the Stimulation count is more than the stimulation types
unsigned long StimOnset      = 0;
unsigned long Now            = 0;
int           StimFreq1[10];
int           StimDur1[10];
int           StimFreq2[10];
int           StimDur2[10];
int           Pulse[10];//          = 10;       // PulseWidth
int           LightHZ[10];//        = WaitingIntVal;  // Masking Light freq

// Saving variables
int           CurrentHZ_1    = 0;
int           CurrentDur_1   = 0;
int           CurrentHZ_2    = 0;
int           CurrentDur_2   = 0;
int           CurrentLED     = 0;
int           CurrentStim    = 0;
int           CurrentPulse   = 0;



void setup() {
  // put your setup code here, to run once:
  pinMode(LaserPin, OUTPUT);
  pinMode(LightPin, OUTPUT);
  pinMode(A2, INPUT);
  digitalWrite(LaserPin, LOW);
  digitalWrite(LightPin, LOW);
  delay(2000);
  digitalWrite(LaserPin, HIGH);
  digitalWrite(LightPin, HIGH);
  delay(1000);
  digitalWrite(LaserPin, LOW);
  digitalWrite(LightPin, LOW);
  Serial.begin(115200);
  Serial.println(String("Waiting for Inputs"));
  delay(100);
  
  WaitForNumericalInput(PreStimVolumes, "PreStimVolumes");
  WaitForNumericalInput(InStimVolumes, "InStimVolumes");
  WaitForNumericalInput(PostStimVolumes, "PostStimVolumes");
  WaitForNumericalInput(UnstimVolumes, "UnstimVolumes");
  WaitForNumericalInput(StimVolumes, "StimVolumes");
  WaitForNumericalInput(Stimulations, "Stimulations");
 
  StimOnset = millis();
  // We use the -1 as a flag value indicating that it has to be replaced with a serial port input.
  // To be able to update a variable length array we use memset to edit an initialized array
  memset(StimFreq1,-1,Stimulations*sizeof(int));//memset is a function so it has to be called in the loop
  memset(StimDur1,-1,Stimulations*sizeof(int)); // also memset depends on the number of bits not array cells
  memset(StimFreq2,-1,Stimulations*sizeof(int));
  memset(StimDur2,-1,Stimulations*sizeof(int));
  memset(LightHZ,-1,Stimulations*sizeof(int));
  memset(Pulse,-1,Stimulations*sizeof(int));

  WaitForIntArray(StimFreq1,Stimulations, "Hz_1");
  WaitForIntArray(StimDur1,Stimulations, "mS_1");
  WaitForIntArray(StimFreq2,Stimulations, "Hz_2");
  WaitForIntArray(StimDur2,Stimulations, "mS_2");
  WaitForIntArray(Pulse,Stimulations, "Pulse");
  WaitForIntArray(LightHZ,Stimulations, "Hz_LED");
  

  Serial.println(String("All Good:") + ' ' + String(millis())); // Signal that all is well
  delay(10);
  Serial.println("Volume,Time,RunState, StimState,Hz_1, Dur_1,Hz_2, Dur_2, MaskLED, Pulse, StimCount");
  delay(10);
}

void loop() {
updatevolumes();// This counts TTLs coming from the scanner and saves the status
switch(RunState) {
  case 1:
  if (VolumeCount - ResetVolume >= PreStimVolumes) {
    RunVolumeCount = VolumeCount;
    StimOnset = millis();
    InStimVolumeCount = VolumeCount; //start a counter from the latest stim block initiation
    RunState = 2;
  }
  break;
  
  case 2:
  // Check if you are still in the stim period or go to run state 3
  if (VolumeCount - ResetVolume >= PreStimVolumes + InStimVolumes) {
    RunState = 3;
    }
    // Until VolumeCount = PreStimVolumes + UnStimVolumes goes in the stim switch loop
    switch (StimState) {
      case 1:// This is to start the masking light before the stim period for UnstimVolumes number
      digitalWrite(LaserPin, LOW);
      idx = StimCount%Stimulations; // return the correct idx to select the parameter on the stimulation protocol array
      CurrentStim = StimCount +1; // Because the reminder is 0 everytime we are back to the first protocol we update to +1 in the saved data
      
      // masking light continous stimulation at LightHZ throughout the stimulation period
      stimatfreq(StimOnset,LightHZ[idx],Pulse[idx],LightPin);
      CurrentLED = LightHZ[idx];
      CurrentPulse = Pulse[idx];
      CurrentHZ_1 = 0;
      CurrentDur_1 = 0;
      CurrentHZ_2 = 0;
      CurrentDur_2 = 0;
      /*
       * When the volume count from the last beginning of a stimulation period (VolumeCount - UnstimVolumes)
       * exceeds the amount of not stimulated control volumes it goes to StimState 2. 
       * This controls the block design stimulation (e.g. 30s Off and 10s On)
       */
      if (VolumeCount - InStimVolumeCount >= UnstimVolumes) {
        EndingCount = VolumeCount; //This stores the volume count value when of the last unstim volume
        StimState = 2;
      }
      break;

      case 2:// This is to stimulate for StimVolumes number after stimulating
      digitalWrite(LaserPin, LOW);
      stimatfreq(StimOnset,LightHZ[idx],Pulse[idx],LightPin);
      /* stimtiming is a function that given two stim frequencies and duration activate the laser counting the time from stim onset
         it also automatically update the current HZ and Dur values
      */
      stimtiming(StimFreq1[idx],StimDur1[idx],StimFreq2[idx],StimDur2[idx], Pulse[idx]);
      
      if (VolumeCount - EndingCount >= StimVolumes) { //when the volume count - last unstim count exceeds volumes to be stim it goes back to unstimulated state
        InStimVolumeCount = VolumeCount;
        ++StimCount;
        StimState = 1;
      }
      break;
    }
  break;
  case 3: // RunState case 3
    digitalWrite(LaserPin, LOW);
    digitalWrite(LightPin, LOW);
    CurrentHZ_1 = 0;
    CurrentDur_1 = 0;
    CurrentHZ_2 = 0;
    CurrentDur_2 = 0;
    CurrentPulse = 0;
    StimState = 0;
    CurrentStim = 0;
    StimCount = 0;
    CurrentLED = 0;
    if (VolumeCount - ResetVolume >= PreStimVolumes + InStimVolumes + PostStimVolumes) {
      ResetVolume = VolumeCount;
      RunState = 1;
      StimState = 1;
    }
  break;
  } 
}
  
/*------------------------------------------Saving Functions--------------------------------------------------------------- */
void savestatus () {
  Serial.println(String(VolumeCount) + ',' + \
  String(millis()) + ',' + \
  String(RunState) + ',' + \
  String(StimState) + ',' + \
  String(CurrentHZ_1) + ',' + \
  String(CurrentDur_1) + ',' + \
  String(CurrentHZ_2) + ',' + \
  String(CurrentDur_2) + ',' + \
  String(CurrentLED) + ',' + \
  String(CurrentPulse) + ',' + \
  String(CurrentStim)
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

void stimatfreq (long onset, int freq, int pulse, int pin) {
  if ((millis()-onset)*freq % 1000 < pulse*freq){
    digitalWrite(pin, HIGH);
  }
  else {
    digitalWrite(pin, LOW);
  }
}

/* Function to alternate between 2 stimulation frequencies over time. To turn off stimulation use frequency = 0
 * This function automatically alternate between frequencies hz1 and hz2 according to input durations dur1 and dur2 
 * If a volume acquisition takes longer than the sum of dur1 and dur2, it will cycle back
 */
void stimtiming (int hz1, int dur1, int hz2, int dur2, int pulse) {
  Now = (millis() - StimOnset) % (dur1 + dur2);
  if (0 < Now && Now < dur1) {
    stimatfreq (StimOnset, hz1, pulse, LaserPin);
    CurrentHZ_1 = hz1;
    CurrentDur_1 = dur1;
  }
  else {
    stimatfreq (StimOnset, hz2, pulse, LaserPin);
    CurrentHZ_2 = hz2;
    CurrentDur_2 = dur2;
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

/* -------------------- Function to receive variables as a message from julia -------------------- 
the & symbol enable the call-by-reference option otherwise it would only copy x value*/
void WaitForNumericalInput(int &x, String msg){
  while (x == WaitingIntVal) {x = SerialRead_Int_Value();}
  Serial.println(msg + ' ' + String(x)); // Signal that all is well
}

void WaitForIntArray(int x[], int Size, String msg) { //In C and C++ there is no way (no way) that a function can know the size of an array unless you tell it. So the array size has to be a separate argument.
  for (int i = 0; i < Size; i++){
    while (x[i] == WaitingIntVal) {x[i] = SerialRead_Int_Value();}
    Serial.print(msg + ' ' + String(x[i]) + "; ");
  }
  Serial.println();
}
