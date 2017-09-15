unit SmartFlowerPot;

interface

uses
  System.Beacon, System.Bluetooth, System.Beacon.Components;

type

  TSmartFlowerPot = class
    strict private
      FName :               string;
      FAddress :            string;
      FTemp :               real;
      FNrfTemp :            real;
      FLight :              integer;
      FSoli :               integer;
      FBatteryPercent :     integer;
      FSignalRSSI :         integer;
      FActive :             boolean;
      FNumber :             integer;
      FReciveCounter :      integer;

      function  getTemp( const data : array of byte ):           real;
      function  getNrfTemp( const data : array of byte ):        real;
      function  getLight( const data : array of byte ):          integer;
      function  getSoli( const data : array of byte ):           integer;
      function  getBatteryPercent( const data : array of byte ): integer;
    public
      constructor Create(const ABeacon: IBeacon);

      property Name :            string  read FName            write FName;
      property Address :         string  read FAddress         write FAddress;
      property Temp :            real    read FTemp            write FTemp;
      property NrfTemp :         real    read FNrfTemp         write FNrfTemp;
      property Light :           integer read FLight           write FLight;
      property Soli :            integer read FSoli            write FSoli;
      property BatteryPercent :  integer read FBatteryPercent  write FBatteryPercent;
      property SignalRSSI :      integer read FSignalRSSI      write FSignalRSSI;
      property Active :          boolean read FActive          write FActive;
      property Number :          integer read FNumber          write FNumber;
      property ReciveCounter :   integer read FReciveCounter   write FReciveCounter;

      function  checkSFP( const data :array of byte ): boolean;
      procedure update(const ABeacon: IBeacon; const AEddystoneTLM: TEddystoneTLM);
  end;



implementation


constructor TSmartFlowerPot.Create(const ABeacon: IBeacon);
begin
  Address := ABeacon.DeviceIdentifier;
  Name    := 'Smart FLower Pot ' + Address;
  Factive := True;
end;

function  TSmartFlowerPot.getTemp( const data :array of byte  ): real;
var
  temp: real;
  tempWord: word;
begin
  tempWord := Word(( ((Word(data[1]) and $FF ) shl 8 ) or ((Word(data[2]) and $FF ) ) ) );
  temp := tempWord / 10. ;

  result := temp;
end;

function  TSmartFlowerPot.getNrfTemp( const data :array of byte  ): real;
var
  temp: real;
  tempWord: word;
begin
  tempWord := Word( ( ((Word(data[3]) and $FF ) shl 8 ) or ((Word(data[4]) and $FF ) ) ) );
  temp := tempWord / 10. ;

  result := temp;
end;

function  TSmartFlowerPot.getLight( const data :array of byte  ): integer;
var
  light : integer;
begin
  light := data[8];
  result := light;
end;

function  TSmartFlowerPot.getSoli( const data :array of byte  ): integer;
var
  soli : integer;
begin
  soli := data[7];
  result := soli;
end;

function  TSmartFlowerPot.getBatteryPercent( const data :array of byte ): integer;
var
  battery : integer;
begin
  battery := data[9];
  result := battery;
end;

function TSmartFlowerPot.checkSFP( const data :array of byte ): boolean;
var
 check: integer;
 test: boolean;
begin
  check := (data[10]) or ( ( data[11] ) shl 8 ) or ( ( data[12] ) shl 16 );
  if ( check = $9AAAEB ) then test := true
  else                        test := false;

  result := test;
end;

procedure  TSmartFlowerPot.update(const ABeacon: IBeacon; const AEddystoneTLM: TEddystoneTLM);
begin
  SignalRSSI := ABeacon.Rssi;
  Temp := getTemp(AEddystoneTLM.EncodedTLM);
  NrfTemp := getNrfTemp(AEddystoneTLM.EncodedTLM);
  Soli := getSoli(AEddystoneTLM.EncodedTLM);
  Light := getLight(AEddystoneTLM.EncodedTLM);
  BatteryPercent := getBatteryPercent(AEddystoneTLM.EncodedTLM);
  Inc(FReciveCounter);
end;




end.
