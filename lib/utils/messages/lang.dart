
//TODO: CREATE AS SINGLETON THAT CAN EXIST IN ONE THROUGHOUT THE ENTIRE APPLICATION TO AVOID PASSING IT THROUGH EVERYWHERE AND INITIALIZING IT MULTIPLE TIMES;
//TODO: Lookup locale
class Lang {
  
  String language;
  String path;

  Lang({String lang = "EN"}){
    language = lang;
    path = 'jsonDirectory'+language+'.json';
  }

  static String getMessageText(String key){
    //access path and pull string with that key or return key if not existing. 
    return null;
  }


}

// cd "C:\Program Files\Oracle\VirtualBox\"
// VBoxManage.exe modifyvm "macOS 10.13 High Sierra" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
// VBoxManage setextradata "macOS 10.13 High Sierra" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
// VBoxManage setextradata "macOS 10.13 High Sierra" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
// VBoxManage setextradata "macOS 10.13 High Sierra" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
// VBoxManage setextradata "macOS 10.13 High Sierra" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
// VBoxManage setextradata "macOS 10.13 High Sierra" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
// VBoxManage setextradata "macOS 10.13 High Sierra" VBoxInternal2/EfiGraphicsResolution 1920×1080

