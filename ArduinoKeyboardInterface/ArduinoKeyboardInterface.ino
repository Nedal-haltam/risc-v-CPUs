//
//
//typedef enum
//{
//    STRING_HEX_LN,
//    CHAR,
//} MODE;
//
//MODE mode = MODE::STRING_HEX_LN;
//String userInput = "";
//String CharMap = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789=|-";
const int DataPins[8] = {4, 5, 6, 7, 8, 9, 10, 11};
#define PIN_CURSOR 12
//
//void EchoBackStringAtLN(String s)
//{
//    Serial.print("string : `");
//    Serial.print(userInput);
//    Serial.println("`");
//}
//
//void EchoBackHexAtLN(String s)
//{
//    Serial.print("Hex : `");
//    for (int i = 0; i < s.length(); i++) 
//    {
//        byte b = s[i];
//        if (b < 0x10) 
//            Serial.print("0");  // leading zero for single-digit hex
//        Serial.print(b, HEX);
//        if (i != s.length()-1)
//            Serial.print(" ");
//    }
//    Serial.println("`");
//}
//
//void EchoBackChar(char c)
//{
//    Serial.print("Char: ");
//    Serial.print("`");
//    Serial.print(c);
//    Serial.print("`");
//    Serial.print(" | Hex: 0x");
//    if ((byte)c < 0x10) Serial.print("0");
//    Serial.println(c, HEX);
//}
//
//void ModeLogic(char c)
//{
//    if (c == 0x13) // ctrl + `s`
//    {
//        mode = MODE::STRING_HEX_LN;
//        userInput = "";
//    }
//    else if (c == 0x03) // ctrl + `c`
//    {
//        mode = MODE::CHAR;
//        c = 0;
//    }
//    
//    if (mode == MODE::CHAR && c != 0)
//    {
//        EchoBackChar(c);
//    }
//    else if (mode == MODE::STRING_HEX_LN)
//    {
//        if (c == ';') {
//            EchoBackStringAtLN(userInput);
//            EchoBackHexAtLN(userInput);
//            userInput = "";
//        } else {
//            userInput += c;
//        }
//    }
//}
//
//void TriggerPin(int pin)
//{
//    digitalWrite(pin, HIGH);
//    delayMicroseconds(1);
//    digitalWrite(pin, LOW);
//}
//
//void SendByte(byte b)
//{
//    for (int i = 0; i < 8; i++) {
//        digitalWrite(outputPins[i], (b >> i) & 0x01);
//    }
//    TriggerPin(PIN_CURSOR);
//    for (int i = 0; i < 8; i++) {
//        digitalWrite(outputPins[i], HIGH);
//    }
//}
//
//void setup() {
//  Serial.begin(9600);
//
//  // Set D4 to D11 as output
//  for (int i = 0; i < 8; i++) {
//    pinMode(outputPins[i], OUTPUT);
//  }
//  SendByte(0);
//  SendByte(0x31);
//  SendByte(0x32);
//  SendByte(0x33);
//  Serial.println("Send a character:");
//}
//
//// to output a null: ctrl + 2
//void loop() {
//    if (Serial.available()) 
//    {
//        char c = Serial.read();
//        byte b = (byte)c;
//        if (c == 0x0D)
//        {
//            Serial.print('\n');
//            Serial.print(c);
//        }
//        else
//        {
//            Serial.print(c, HEX);
//        }
//        SendByte(b);
//    }
//}

bool lastTriggerState = LOW;

void setup() {
  Serial.begin(9600);

  // Set data pins as INPUT
  for (int i = 0; i < 8; i++) {
    pinMode(DataPins[i], INPUT);
  }

  // Set trigger pin as INPUT
  pinMode(PIN_CURSOR, INPUT);
}

void loop() {
  bool currentTrigger = digitalRead(PIN_CURSOR);

  // Detect rising edge: LOW → HIGH
  if (currentTrigger == HIGH && lastTriggerState == LOW) {
    byte DataIn = 0;

    for (int i = 0; i < 8; i++) {
      int bitVal = digitalRead(DataPins[i]);
      DataIn |= (bitVal << i);  // LSB on D4, MSB on D11
    }
    if (DataIn != 0)
    {
        if (DataIn == 0x0A)
        {
            Serial.print('\n');
            Serial.print((char)0x0D);
        }
        else
        {
            Serial.print((char)DataIn);
        }
    }
  }

  lastTriggerState = currentTrigger;
}
