import hypermedia.net.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

UDP udp;
int PORT_UDP = 20777;
String HOST_UDP = "127.0.0.1";

int speedDraw, rpmDraw, gearDraw, rearLeftWheelSpeedDraw, handbrakeInputDraw;
float startRpm, startSpeed, speedGauge, rpmGauge;
PImage panel, arrowS, arrowR, brakeOn, brakeOff;
PFont fontGothicMedium_12, fontGothicMedium_24, fontGothicMedium_32, fontGothicMedium_42, fontGothicMedium_64;

void setup() {
  // size window
  size(720, 430);

  // config udp
  udp = new UDP(this, PORT_UDP, HOST_UDP);
  //udp.log(true);
  udp.listen(true);

  // loading fonts
  fontGothicMedium_12 = createFont("./assets/fonts/bankgothicmdbt_medium.otf", 12, true);
  fontGothicMedium_24 = createFont("./assets/fonts/bankgothicmdbt_medium.otf", 24, true);
  fontGothicMedium_32 = createFont("./assets/fonts/bankgothicmdbt_medium.otf", 32, true);
  fontGothicMedium_42 = createFont("./assets/fonts/bankgothicmdbt_medium.otf", 42, true);
  fontGothicMedium_64 = createFont("./assets/fonts/bankgothicmdbt_medium.otf", 64, true);

  // loading images
  panel = loadImage("./assets/images/panel.jpg");
  arrowS = loadImage("./assets/images/arrowS.png");
  arrowR = loadImage("./assets/images/arrowR.png");
  brakeOn = loadImage("./assets/images/brakeOn.png");
  brakeOff = loadImage("./assets/images/brakeOff.png");

  // initial position of the arrows
  startRpm = radians(60);
  startSpeed = radians(0);
}

void draw() {
  // panel
  image(panel, 0, 0);

  // icon handbrake
  pushMatrix();
  translate(467, 30);
  if (handbrakeInputDraw == 1 && rearLeftWheelSpeedDraw == 0) {
    image(brakeOn, -14.5, -14.5, 29, 29);
  } else {
    image(brakeOff, -14.5, -14.5, 29, 29);
  }
  popMatrix();

  // text км/ч, об/мин, х1000
  textFont(fontGothicMedium_24);
  textAlign(CENTER);  
  text("км/ч", 467, 290);
  textFont(fontGothicMedium_32);
  text("км/ч", 211, 390);
  text("об/мин", 467, 390);
  textFont(fontGothicMedium_24);
  text("х1000", 467, 410);
  textAlign(LEFT);
  textFont(fontGothicMedium_24);
  text("DIRT3", 10, 30);
  textFont(fontGothicMedium_12);
  text("udp client", 12, 40);
  text(HOST_UDP + ":" + PORT_UDP, 10, 420);

  // speed arrow
  pushMatrix();
  translate(211, 189);
  rotate(startSpeed + radians(speedGauge));
  image(arrowS, -30.5, -57, 60, 268);
  popMatrix();

  // rpm arrow
  pushMatrix();
  translate(467, 256);
  rotate(startRpm + radians(map(rpmGauge, 0, 6830, 0, 204.5)));
  image(arrowR, -25, 90, 50, 141);
  popMatrix();

  // text speed
  textFont(fontGothicMedium_64);
  textAlign(CENTER);
  text(speedDraw, 467, 256);

  // text gear
  textFont(fontGothicMedium_42);
  textAlign(CENTER);
  switch(gearDraw) {
    case 0: 
      text("N", 467, 335);
      break;
    case 10: 
      text("R", 467, 335);
      break;
    default:
      text(gearDraw, 467, 335);
      break;
  };
}

void receive(byte[] data) {
  ByteBuffer littleEndianByteBuffer = ByteBuffer.wrap(data, 0, 152).order(ByteOrder.LITTLE_ENDIAN);

  float time = littleEndianByteBuffer.getFloat(0);
  float currentLapTime = littleEndianByteBuffer.getFloat(4);
  float distanceCurrentLap = littleEndianByteBuffer.getFloat(8);
  float distance = littleEndianByteBuffer.getFloat(12);

  float worldPositionX = littleEndianByteBuffer.getFloat(16);
  float worldPositionY = littleEndianByteBuffer.getFloat(20);
  float worldPositionZ = littleEndianByteBuffer.getFloat(24);

  float speed = littleEndianByteBuffer.getFloat(28);
  float velocityX = littleEndianByteBuffer.getFloat(32);
  float velocityY = littleEndianByteBuffer.getFloat(36);
  float velocityZ = littleEndianByteBuffer.getFloat(40);

  float objectToWorldLeftDirection_X = littleEndianByteBuffer.getFloat(44);
  float objectToWorldLeftDirection_Y = littleEndianByteBuffer.getFloat(48);
  float objectToWorldLeftDirection_Z = littleEndianByteBuffer.getFloat(52);

  float objectToWorldForwardDirection_X = littleEndianByteBuffer.getFloat(56);
  float objectToWorldForwardDirection_Y = littleEndianByteBuffer.getFloat(60);
  float objectToWorldForwardDirection_Z = littleEndianByteBuffer.getFloat(64);

  float rearLeftSuspensionPosition_mm = littleEndianByteBuffer.getFloat(68);
  float rearRightSuspensionPosition_mm = littleEndianByteBuffer.getFloat(72);
  float frontLeftSuspensionPosition_mm = littleEndianByteBuffer.getFloat(76);
  float frontRightSuspensionPosition_mm = littleEndianByteBuffer.getFloat(80);

  float rearLeftSuspensionSpeed_mm_s = littleEndianByteBuffer.getFloat(84);
  float rearRightSuspensionSpeed_mm_s = littleEndianByteBuffer.getFloat(88);
  float frontLeftSuspensionSpeed_mm_s = littleEndianByteBuffer.getFloat(92);
  float frontRightSuspensionSpeed_mm_s = littleEndianByteBuffer.getFloat(96);

  float rearLeftWheelSpeed_m_s = littleEndianByteBuffer.getFloat(100);
  float rearRightWheelSpeed_m_s = littleEndianByteBuffer.getFloat(104);
  float frontLeftWheelSpeed_m_s = littleEndianByteBuffer.getFloat(108);
  float frontRightWheelSpeed_m_s = littleEndianByteBuffer.getFloat(112);

  float accelerationInput = littleEndianByteBuffer.getFloat(116);
  float steeringInput = littleEndianByteBuffer.getFloat(120);
  float brakeInput = littleEndianByteBuffer.getFloat(124);
  float handbrakeInput = littleEndianByteBuffer.getFloat(128);
  float gear = littleEndianByteBuffer.getFloat(132);
  float gForceLateral = littleEndianByteBuffer.getFloat(136);
  float gForceLongitudinal = littleEndianByteBuffer.getFloat(140);
  float currentLap = littleEndianByteBuffer.getFloat(144);
  float rpm = littleEndianByteBuffer.getFloat(148);

  speedGauge = speed * 3.6;
  speedDraw = int(speedGauge);

  rpmGauge = rpm * 10;
  rpmDraw = int(rpmGauge);

  gearDraw = int(gear);
  rearLeftWheelSpeedDraw = int(rearLeftWheelSpeed_m_s*100);
  handbrakeInputDraw = int(handbrakeInput);

  //println(millis() + " -> " + gearDraw);
}
