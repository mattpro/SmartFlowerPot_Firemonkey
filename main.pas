unit main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Beacon,
  System.Bluetooth, System.Beacon.Components, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, System.Rtti,
  FMX.Grid.Style, FMX.Grid, Generics.Collections, FMX.Layouts, FMX.ListBox,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, Data.Bind.Components, Data.Bind.ObjectScope,
  FMX.TabControl, IniFiles, FMXTee.Engine, FMXTee.Procs, FMXTee.Chart,
  FMXTee.Series, System.ImageList, FMX.ImgList;

type
  TForm1 = class(TForm)
    Beacon: TBeacon;
    ToolBar1: TToolBar;
    Label1: TLabel;
    ListViewDevice: TListView;
    StyleBook1: TStyleBook;
    ImageList1: TImageList;
    procedure BeaconBeaconEnter(const Sender: TObject; const ABeacon: IBeacon;
      const CurrentBeaconList: TBeaconList);
    procedure FormCreate(Sender: TObject);
    procedure BeaconNewEddystoneTLM(const Sender: TObject;
      const ABeacon: IBeacon; const AEddystoneTLM: TEddystoneTLM);
    procedure ListViewDeviceDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses SmartFlowerPot;
{$R *.LgXhdpiPh.fmx ANDROID}

var
  SmartFlowerPotDeviceList: TDictionary<String, TSmartFlowerPot>;



procedure TForm1.BeaconBeaconEnter(const Sender: TObject;
  const ABeacon: IBeacon; const CurrentBeaconList: TBeaconList);
var
  currentBeacon: TSmartFlowerPot;
  item: TListViewItem;
  bId, bName: TListItemText;
  bImage: TListItemImage;
begin
  currentBeacon := TSmartFlowerPot.Create( ABeacon );
  if (ABeacon.KindofBeacon = Eddystones) and (not SmartFlowerPotDeviceList.ContainsKey(ABeacon.DeviceIdentifier)) then
  begin
    ListViewDevice.BeginUpdate;
    item := ListViewDevice.Items.Add;
    bId := item.Objects.FindObjectT<TListItemText>('TextAddress');
    bId.Text := currentBeacon.Address;
    bName := item.Objects.FindObjectT<TListItemText>('TextName');
    bName.Text := currentBeacon.Name;
    bImage := item.Objects.FindObjectT<TListItemImage>('ImageSoli');
    bImage.Bitmap := ImageList1.Source[1].MultiResBitmap[0].Bitmap;
    bImage := item.Objects.FindObjectT<TListItemImage>('ImageSun');
    bImage.Bitmap := ImageList1.Source[0].MultiResBitmap[0].Bitmap;
    ListViewDevice.EndUpdate;

    currentBeacon.Number := ListViewDevice.Items.Count;
    SmartFlowerPotDeviceList.AddOrSetValue(ABeacon.DeviceIdentifier, currentBeacon);
  end;
end;

procedure TForm1.BeaconNewEddystoneTLM(const Sender: TObject;
  const ABeacon: IBeacon; const AEddystoneTLM: TEddystoneTLM);
var
  SmartFlowerPot: TSmartFlowerPot;
  dataLine: string;
begin
  if SmartFlowerPotDeviceList.ContainsKey(ABeacon.DeviceIdentifier) then
  begin
    SmartFlowerPot := SmartFlowerPotDeviceList.Items[ABeacon.DeviceIdentifier];
    if ( SmartFlowerPot.checkSFP(AEddystoneTLM.EncodedTLM) ) then
    begin
      Log.d('Nowe dane z ' + ABeacon.DeviceIdentifier);
      SmartFlowerPot.update(ABeacon, AEddystoneTLM);
      SmartFlowerPotDeviceList.AddOrSetValue(ABeacon.DeviceIdentifier, SmartFlowerPot);

      ListViewDevice.BeginUpdate;
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextRssi')).Text    := 'RSSI: '    + SmartFlowerPot.SignalRSSI.ToString + ' dBm';
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextBattery')).Text := 'Battery: ' + IntToStr(SmartFlowerPot.BatteryPercent) + '%';
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextAddress')).Text := SmartFlowerPot.Address;
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextNrfTemp')).Text := Format('%.1f', [SmartFlowerPot.NrfTemp]) + '°C';
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextTemp')).Text    := Format('%.1f', [SmartFlowerPot.Temp]) + '°C';
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextCounter')).Text := 'Counter ' + IntToStr( SmartFlowerPot.ReciveCounter );
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextLight')).Text   := IntToStr(SmartFlowerPot.Light) + '%';
      TListItemText(ListViewDevice.Items[SmartFlowerPot.Number - 1].Objects.FindDrawable('TextSoli')).Text    := IntToStr(SmartFlowerPot.Soli) + '%';
      ListViewDevice.EndUpdate;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SmartFlowerPotDeviceList := TDictionary<String, TSmartFlowerPot>.Create;
end;

procedure TForm1.ListViewDeviceDblClick(Sender: TObject);
var
  selectedBeacon: TSmartFlowerPot;
  newName: string;
begin
  if ListViewDevice.Selected.Index >= 0 then
  begin
    selectedBeacon := SmartFlowerPotDeviceList.Items[TListItemText(ListViewDevice.Items[ListViewDevice.Selected.Index].Objects.FindDrawable('TextAddress')).Text];
    SmartFlowerPotDeviceList.AddOrSetValue(selectedBeacon.Address, selectedBeacon);
    InputBox('Set new name for ID: ' + selectedBeacon.Address,'New name:', '');

    if newName <> '' then
    begin
      selectedBeacon.name := newName;
      TListItemText(ListViewDevice.Items[selectedBeacon.Number - 1].Objects.FindDrawable('TextName')).Text := newName;
    end;
  end;
  ListViewDevice.Selected.Index := -1;
end;

end.
