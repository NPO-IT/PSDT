unit PSDT;

interface                                                        

uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  	Dialogs, TeEngine, Series, ExtCtrls, TeeProcs, Chart, StdCtrls,Lusbapi,
  	XPMan,Visa_h, IdBaseComponent, IdComponent, IdUDPBase, IdUDPServer,IdSocketHandle,IniFiles,IdHTTP,
    IdTCPConnection, IdTCPClient;

const
 	DataStep : DWORD = 24992;        // ���������� ������������� ������ � ����� ��� (������� 32) ��� �. ReadData
    ChannelsQuantity : WORD = 8;     // ���������� �������
    AcpBufSize: integer = 24992;     // ���������� ������������� ������ � ����� ��� (������� 32)(int)
    ChanelBufSize: integer = 3124;   // 24992 / 8 = 3124 - ���������� ������ ������� ������
  	AdcRate : double  = 100.0;       // ������� ������ ���

type
  	TShortrArray = array [0..1] of array of SHORT;
  	TForm1 = class(TForm)
  	Button1: TButton;
  	Memo1: TMemo;
  	Chart1: TChart;
  	Series1: TBarSeries;
  	Chart2: TChart;
  	diaTimer: TTimer;
  	Label1: TLabel;
    rb2: TRadioButton;
    rb3: TRadioButton;
    rb4: TRadioButton;
    rb5: TRadioButton;
    rb6: TRadioButton;
    rb7: TRadioButton;
    rb11: TRadioButton;
    rb12: TRadioButton;
    rb13: TRadioButton;
    rb14: TRadioButton;
    rb15: TRadioButton;
    rb8: TRadioButton;
    rb9: TRadioButton;
    rb10: TRadioButton;
    rb16: TRadioButton;
    rb17: TRadioButton;
    rb18: TRadioButton;
    rb19: TRadioButton;
    rb20: TRadioButton;
    rb21: TRadioButton;
    rb22: TRadioButton;
    rb23: TRadioButton;
    rb24: TRadioButton;
    rb25: TRadioButton;
    rb26: TRadioButton;
    rb27: TRadioButton;
    rb28: TRadioButton;
    rb29: TRadioButton;
    rb30: TRadioButton;
    rb31: TRadioButton;
    rb32: TRadioButton;
    rb33: TRadioButton;
    lbl9: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    lbl14: TLabel;
    lbl10: TLabel;
    lbl15: TLabel;
    lbl16: TLabel;
    lbl17: TLabel;
    lbl18: TLabel;
    lbl19: TLabel;
    lbl20: TLabel;
    lbl21: TLabel;
    lbl22: TLabel;
    lbl23: TLabel;
    lbl24: TLabel;
    lbl25: TLabel;
    lbl26: TLabel;
    lbl27: TLabel;
    lbl28: TLabel;
    lbl29: TLabel;
    lbl30: TLabel;
    lbl31: TLabel;
    lbl32: TLabel;
    lbl33: TLabel;
    lbl34: TLabel;
    lbl35: TLabel;
    lbl36: TLabel;
    lbl37: TLabel;
    lbl38: TLabel;
    lbl39: TLabel;
    lbl40: TLabel;
    lbl41: TLabel;
    lbl42: TLabel;
    lbl43: TLabel;
    lbl44: TLabel;
    XPManifest1: TXPManifest;
    lbl45: TLabel;
    lbl46: TLabel;
    lbl47: TLabel;
    lbl2: TLabel;
    edt1: TEdit;
    Series2: TLineSeries;
    tmr1: TTimer;
    tmr2: TTimer;
    lbl1: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    edt2: TEdit;
    pnl1: TPanel;
    lbl5: TLabel;
    chk1: TCheckBox;
    chk2: TCheckBox;
    chk3: TCheckBox;
    chk4: TCheckBox;
    chk5: TCheckBox;
    chk6: TCheckBox;
    btn2: TButton;
    tmr3: TTimer;
    idUDPServer2: TIdUDPServer;
    tmr4: TTimer;
    IdHTTP1: TIdHTTP;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
  	procedure FormCreate(Sender: TObject);
  	procedure Button1Click(Sender: TObject);
  	procedure FormClose(Sender: TObject; var Action: TCloseAction);
  	procedure Series1Click(Sender: TChartSeries; ValueIndex: Integer;
  	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  	procedure diaTimerTimer(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure chk2Click(Sender: TObject);
    procedure chk3Click(Sender: TObject);
    procedure chk4Click(Sender: TObject);
    procedure chk5Click(Sender: TObject);
    procedure chk6Click(Sender: TObject);
    procedure tmr3Timer(Sender: TObject);
    procedure idUDPServer2UDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
    procedure tmr4Timer(Sender: TObject);


  	private
  	{ Private declarations }
 	public
   { Public declarations }
end;
var
	Form1: TForm1;
  	//���
  	hReadThread : THANDLE;          // ������������� ������ �����
  	ReadTid : DWORD;
  	pModule : ILE440;               // ��������� ������ E14-440
  	DllVersion : DWORD;             // ������ ���������� Lusbapi.dll
  	ModuleHandle : THandle;         // ������������� ����������
  	ModuleName: String;             // �������� ������
  	UsbSpeed : BYTE;                // �������� ������ ���� USB
  	ModuleDescription : MODULE_DESCRIPTION_E440;   // ��������� � ������ ����������� � ������
  	ap : ADC_PARS_E440;             // ��������� ���������� ������ ���
  	Counter : longWORD;             // �������� �������-���������
  	Buffer : TShortrArray;          // ��������� �� ����� ��� ������
  	ReadThreadErrorNumber : WORD;   // ����� ������ ��� ���������� ������ ����� ������
  	IsReadThreadComplete : boolean; // ������ ���������� ������� ����� ������
  	RequestNumber : WORD;
  	chInd:integer=0;                // ����� ������ ��� ������ �� �����������
  	outToGist:boolean=false;        // ���� ������ �� �����������
  	numPoint:integer=1;             // ����� ����� ��� ������ �� �����������
  	outArr:array of double;         // ������ ��� ������ �� ������ �������
  	size:int64=0;                   // ������ ���������� � ���� ��
    Chanel_data : array[0..7,0..1000000] of Integer; // ���� ��� ������ ������� ������
    buf_wr_i:Integer;                                // ������ ������ (��������� ������������ ������ �����������, �� ������ ������, ������ ���� �� ����)
    buf_rd_i:Integer;                                // ������ ������
    buf_fill:Integer;                                // ������������� ����
    OutEnable:Boolean;                               // ���������� ������ �� ����������� � ���������
    NextState: Integer;                              // ��������� ��� swith
    NextNextState: Integer;                          // ������� ������������ ��������� �� 2 ���� ������
    CurrentInsertChanel: Integer;                    // ������� ����� ������ (32 ������ ������ ���������� ��������������� �� 0��(1��) ������ ���
    ChanelsConnectStatus:Integer;                    // ��������� ������ - ����� ���������� ��� 1, �� ����� - 0, ���� ������� ������������ ���������� (���� 01000011000...000) - 32 �������
    averageInsrtCh:array[0..31] of Integer;          // ������ ������� �������� ������� ������
    ProgramRun: Boolean;                             // ���� ����������� �������-�� ����� ���
    CurrentVolt: String;                             // ���������� ��� ���������� �������� � ����������
    CurrentAmp: String;                              // ���������� ��� ���������� �������� � ��������� �������
    Current5Volt: String;                            // ���������� 5�� �����, ��������������� ���
    Current3_3Volt: String;                          // ���������� 3.3 �����, ��������������� ���
    Current3_9Volt: String;                          // ���������� 3.9 �����, ��������������� ���
    Calibration_mV0: Double;                         // ���������� �������� ��� ���������� ��� 0�
    Calibration_mV1: Double;                         // ���������� �������� ��� ���������� ��������� �
    CompareCalibration_mV1:Double;                   // ���������� �������� �������� � ������������ ��� ��������� ���������� (�������� �������������)
    Calibration_Omh0: Double;                        // ���������� �������� ��� ���������� ��� 0 ��
    Calibration_Omh1: Double;                        // ���������� �������� ��� ���������� ������������� �������� ��
    CompareCalibration_Omh1:Double;                  // ���������� �������� �������� � ���� ��� ��������� ���������� (�������� �������������)
    SelectOmh25:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 25 ������
    SelectOmh26:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 26 ������
    SelectOmh27:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 27 ������
    SelectOmh28:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 28 ������
    SelectOmh29:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 29 ������
    SelectOmh30:Boolean;                             // ���������� ���������� �� ����� �� ��� �� ��� 30 ������
    ReceiveActive:Boolean;
    FileName: string;                                // ��� �����
    FileHandle: TextFile;
    mydate: TDateTime;
    AkipV7_78_1:array [0..1] of string;
    m_defaultRM_usbtmc, m_instr_usbtmc:array[0..2] of LongWord;
    viAttr:Longword =  $3FFF001A;      Timeout: integer = 7000;
    TimParity:Integer = 0;
    IP_POWER_SUPPLY_1:string;
    verify_send, flagCur, AkipOff:Boolean;
   implementation
   uses DataHandler;
	{$R *.dfm}
// ������ �������� ������� �� �������� �������
function SendCommandToPowerSupply(NumberPowerSupply:integer;Command:string):String;
var
    pStrout:string;
begin
    pStrout:=Command+#13;
    if (NumberPowerSupply=1) then Form1.idUDPServer2.Send(IP_POWER_SUPPLY_1,4001,pStrout);
end;
// ������� �������� ����������� ����������
function TestConnect(Name:string; var m_defaultRM_usbtmc_loc, m_instr_usbtmc_loc:Longword; vAtr:Longword; m_Timeout: integer):integer;
var
    status:integer;
    viAttr:Longword;
    m_findList_usbtmc: LongWord;
    m_nCount: LongWord;
    instrDescriptor:vichar;
begin
    setlength(instrDescriptor,255);
    result:=0;
	status:= viOpenDefaultRM(@m_defaultRM_usbtmc_loc);
	if (status < 0) then
	begin
		viClose(m_defaultRM_usbtmc_loc);
		m_defaultRM_usbtmc_loc:= 0;
        result:=-1;
        //  showmessage('       ��������� �������� �� ������!');
	end
	else
	begin
		status:= viFindRsrc(m_defaultRM_usbtmc_loc, name, @m_findList_usbtmc, @m_nCount, instrDescriptor);
 		if (status < 0) then
        begin
			status:= viFindRsrc (m_defaultRM_usbtmc_loc, 'USB[0-9]*::5710::3501::?*INSTR', @m_findList_usbtmc, @m_nCount, instrDescriptor);
			if (status < 0) then
			begin
				viClose(m_defaultRM_usbtmc_loc);
                result:=-1;
                //    showmessage('       ��������� �������� �� ������!');
				m_defaultRM_usbtmc_loc:= 0;
                exit;
			end
			else
			begin
				viOpen(m_defaultRM_usbtmc_loc, instrDescriptor, 0, 0, @m_instr_usbtmc_loc);
				status:= viSetAttribute(m_instr_usbtmc_loc, vatr, m_Timeout);
			end
		end
		else
		begin
			status:= viOpen(m_defaultRM_usbtmc_loc, instrDescriptor, 0, 0, @m_instr_usbtmc_loc);
  		    status:= viSetAttribute(m_instr_usbtmc_loc, viAttr, m_Timeout);
		end
	end;
    result:=status;
end;
// ������� ���������� ����� � ����������
function GetDatStr(m_instr_usbtmc_loc:Longword; var dat:string):integer;
var
    i:integer;
    len:integer;
    status:integer;
    pStrin:vichar;
    nRead: integer;
    stbuffer:string;
begin
    dat:='';
    setlength(pStrin,64);
    sleep(45);//100
    len:= 64;
    status := viRead(m_instr_usbtmc_loc, pStrin, len, @nRead);
    if (nRead > 0) then
    begin
        stbuffer:='';
        for i:=0 to (nRead-1) do stbuffer:=stbuffer+pStrin[i];
    end;
    if(stbuffer='') then
    begin
        form1.Memo1.Lines.Add('������ � ���������� ���')
    end
    else
    begin
        dat:=floattostrf(strtofloat(stbuffer), fffixed, 5, 4);
    end;
end;

function SetConf(m_instr_usbtmc_loc:Longword; command:string):integer;
var
    pStrout:vichar;
    i:integer;
    nWritten:LongWord;
begin
    setlength(pStrout,64);
    for i:=0 to length(command) do
    begin
        pStrout[i]:=command[i+1];
    end;
    result:= viWrite(m_instr_usbtmc_loc, pStrout, length(command), @nWritten);
    Sleep(30);
end;
//==============================================================================
// �������� ���������� ���������� ���������� ������� �� ���� ������
//==============================================================================
function WaitingForRequestCompleted(var ReadOv : OVERLAPPED) : boolean;
var
    BytesTransferred : DWORD;
begin
    Result := true;
    while true do
	begin
	    if GetOverlappedResult(ModuleHandle, ReadOv, BytesTransferred, FALSE) then
		begin
			break;
        end
		else
   	    begin
            if (GetLastError() <>  ERROR_IO_INCOMPLETE) then
            begin
                // ������ �������� ����� ��������� ������ ������
                ReadThreadErrorNumber := 3;
                Result := false;
                break;
      	    end
   	    end;
    end;
end;
//==============================================================================
// ������ ����������� � ��������� ������ ��� ����� ������ c ���
//==============================================================================
function ReadThread(var param : pointer): DWORD;
var
    //mm:short;
    i{,ii }: WORD;
    j : integer;
    //U1:integer;
    //k,n:integer;
    // U:double;
    // ������ OVERLAPPED �������� �� ���� ���������
    ReadOv : array[0..1] of OVERLAPPED;
    // ������ �������� � ����������� ������� �� ����/����� ������
    IoReq : array[0..1] of IO_REQUEST_LUSBAPI;
    ind_of_data:Integer;
begin
    Result := 0;
    // ��������� ������ ��� � ������������ ������� USB-����� ������ ������
    if not pModule.STOP_ADC() then
    begin
        ReadThreadErrorNumber := 1;
        IsReadThreadComplete := true;
        exit;
    end;
    // ��������� ����������� ��� ����� ������ ���������
	for i := 0 to 1 do
  	begin
   	    // ������������� ��������� ���� OVERLAPPED
	  	ZeroMemory(@ReadOv[i], sizeof(OVERLAPPED));
    	// ������ ������� ��� ������������ �������
		ReadOv[i].hEvent := CreateEvent(nil, FALSE , FALSE, nil);
    	// ��������� ��������� IoReq
		IoReq[i].Buffer := Pointer(Buffer[i]);
		IoReq[i].NumberOfWordsToPass := DataStep;
		IoReq[i].NumberOfWordsPassed := 0;
		IoReq[i].Overlapped := @ReadOv[i];
		IoReq[i].TimeOut := Round(Int(DataStep/ap.AdcRate)) + 1000;
  	end;
    // ������� ������� ������ ����������� ���� ������ � Buffer
	RequestNumber := 0;
	if not pModule.ReadData(@IoReq[RequestNumber]) then
  	begin
   	    CloseHandle(IoReq[0].Overlapped.hEvent);
    	CloseHandle(IoReq[1].Overlapped.hEvent);
    	ReadThreadErrorNumber := 2;
    	IsReadThreadComplete := true;
    	exit;
  	end;
    // � ������ ����� ��������� ���� ������
	if pModule.START_ADC() then
  	begin
        //-------------------------------------------------------------------------------------------------
        while true do                           // ������� �����������
        begin
            RequestNumber := RequestNumber xor $1;  // ������� ��������� ������ � ���
            if not pModule.ReadData(@IoReq[RequestNumber]) then   // ������� ������ �� ��������� ������ �������� ������
            begin
                ReadThreadErrorNumber := 2;
                break;
            end;
            if not WaitingForRequestCompleted(IoReq[RequestNumber xor $1].Overlapped^) then
            begin
                // �������� ���������� ���������� ������� �� ���� ������
                break;
            end;
            // ����� �����
            ind_of_data:=0;   // ������ ������ �� ������ ���
            i:=0;
            while( ind_of_data<=(AcpBufSize-1-7))  do // ��������� � ���� �������� 8 �������, �� ��������� ��� ������� ���� ����� �������� 8
            begin
                Chanel_data[0][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data];        // �������� ��� ����� 0 � ������� ���������� ������
                Chanel_data[1][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+1];      // ����� 1 - ������ ������� - ��������� ������
                Chanel_data[2][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+2];      // ����� 2 - ������ 1�� ������
                Chanel_data[3][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+3];      // ����� 3 - ��������� ������
                                                                                              // ����� 4 - �������������
                Chanel_data[5][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+5];      // ����� 5 - 5 �����
                Chanel_data[6][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+6];      // ����� 6 - 3_3 �����
                Chanel_data[7][i+buf_wr_i]:=buffer[RequestNumber xor $1][ind_of_data+7];      // ����� 7 - 3_9 �����

                ind_of_data:=ind_of_data+8;
                i:=i+1;
   		    end;
            buf_wr_i:=buf_wr_i+ChanelBufSize;      // �������� ������ ������
            buf_fill:=buf_fill+ChanelBufSize;      // �������� ����� ��������� � ������
            if(buf_wr_i>=ChanelBufSize*100)  then     // ��������� �����
            begin
                buf_wr_i:=0;
            end;
            if(buf_fill>=3124*4)then
            begin
                OutEnable:=True;
            end;
            if(buf_wr_i<0)or(buf_wr_i>=ChanelBufSize*100+1) then
            begin
                Form1.Memo1.Lines.Add('����� - '+IntToStr(buf_wr_i));
            end;
            // ������� ��������� ������ � ���
            if ReadThreadErrorNumber <> 0 then
            begin
                // ���� �� ������ ��� ������������ ������� ���� ������?
                break;
            end;
            // ����������� ������� ���������� ������ ������
            Inc(Counter);
		end
	end
	else
  	begin
   	    ReadThreadErrorNumber := 6;
  	end;
    // ��������� ������ ������ ���
	if ReadThreadErrorNumber = 0 then
 	begin
   	    // ��� ��������� �������� ����� ��������� ������ ������
		if WaitingForRequestCompleted(IoReq[RequestNumber].Overlapped^) then
		begin
      	    // �������� ������� ���������� ������ ������
      	    Inc(Counter);
      	    ///////////////////////////////////
            ///////////////////////////////////
    	end;
  	end;
 	if not pModule.STOP_ADC() then
 	begin
   	    // ��������� ���� ������
		ReadThreadErrorNumber := 1;
  	end;
	if not CancelIo(ModuleHandle) then
  	begin
   	    // ���� ����, �� ������ ������������� ����������� ������
    	ReadThreadErrorNumber := 7;
  	end;
  	// ��������� �������������� �������
	CloseHandle(IoReq[0].Overlapped.hEvent); CloseHandle(IoReq[1].Overlapped.hEvent);
	//Sleep(100);
  	// ����������
  	// ��������� ������ ��������� ������ ����� ������
    IsReadThreadComplete := true;
end;

//==============================================================================
// ��������� ���������� ���������
//==============================================================================
procedure AbortProgram(ErrorString: string; AbortionFlag : bool = true);
var
	i : WORD ;
begin
    // ������� ��������� �� ��������� ������
  	pModule := nil;
  	// ��������� ������������� ������ ����� ������
	if hReadThread = THANDLE(nil) then CloseHandle(hReadThread);
  	/////////////////////////////////
    /////////////////////////////////
  	// ��������� ������ ��-��� ������� ������
	for i := 0 to 1 do
  	begin
   	    Buffer[i] := nil;
  	end;
	if ErrorString <> ' ' then
  	begin
   	    // ���� ����� - ������� ��������� � �������
   	    MessageBox(HWND(nil),pCHAR(ErrorString),'������!!!',
        MB_OK + MB_ICONINFORMATION);
  	end;
	// ���� ����� - �������� ��������� ���������
	if AbortionFlag = true then halt;
end;
//==============================================================================
procedure AdcInit();
var
	i:integer;
	str:string;
begin
	///////////////////////////
	///////////////////////////
	// �������� ������ ������������ DLL ����������
  	DllVersion := GetDllVersion;
	if (DllVersion <> CURRENT_VERSION_LUSBAPI) then
	begin
   	    Str:='�������� ������ DLL ���������� Lusbapi.dll! ' + #10#13 +
		'           �������: ' + IntToStr(DllVersion shr 16) +
        '.' + IntToStr(DllVersion and $FFFF) + '.' +
		' ���������: ' + IntToStr(CURRENT_VERSION_LUSBAPI shr 16) + '.' +
        IntToStr(CURRENT_VERSION_LUSBAPI and $FFFF) + '.';
		AbortProgram(Str);
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('DLL Version --> OK');
  	end;
    // ��������� �������� ��������� �� ��������� ��� ������ E14-440
    pModule := CreateLInstance(pCHAR('e440'));
  	if pModule = nil then
  	begin
   	    AbortProgram('�� ���� ����� ��������� ������ E14-440!');
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('Module Interface --> OK');
  	end;
    for i := 0 to (MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI-1) do
  	begin
   	    if pModule.OpenLDevice(i) then
    	begin
      	    // ��������� ���������� ������ E14-440 �
      	    //������ MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI ����������� ������
      	    break;
    	end;
  	end;
    if i = MAX_VIRTUAL_SLOTS_QUANTITY_LUSBAPI then
  	begin
   	    // ���-������ ����������?
    	AbortProgram('�� ������� ���������� ������ E14-440 � ������ 127 ����������� ������!')
  	end
	else
 	begin
   	    form1.Memo1.Lines.Add(Format('OpenLDevice(%u) --> OK', [i]));
  	end;
  	// ������� ������������� ����������
	ModuleHandle := pModule.GetModuleHandle();
  	// ��������� �������� ������ � ������� ����������� �����
	ModuleName := '0123456';
    if not pModule.GetModuleName(pCHAR(ModuleName)) then
  	begin
   	    AbortProgram('�� ���� ��������� �������� ������!')
    end
	else
  	begin
   	    form1.Memo1.Lines.Add('GetModuleName() --> OK');
  	end;
    if Boolean(AnsiCompareStr(ModuleName, 'E440')) then
  	begin
   	    // ��������, ��� ��� ������ E14-440
    	AbortProgram('������������ ������ �� �������� E14-440!')
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('The module is ''E14-440''');
  	end;
    if not pModule.GetUsbSpeed(@UsbSpeed) then
  	begin
   	    // ��������� �������� �������� ������ ���� USB
    	AbortProgram(' �� ���� ���������� �������� ������ ���� USB')
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('GetUsbSpeed() --> OK');
  	end;
    if UsbSpeed = USB11_LUSBAPI then
  	begin
   	    Str := 'Full-Speed Mode (12 Mbit/s)';
    	form1.Memo1.Lines.Add(Format(' USB is in %s', [Str]));
  	end
  	else
  	begin
   	    // ������ ��������� �������� ������ ���� USB
    	Str := 'High-Speed Mode (480 Mbit/s)';
    	form1.Memo1.Lines.Add(Format('USB is in %s', [Str]));
  	end;
    if not pModule.LOAD_MODULE(nil) then
  	begin
   	    // ��� �������� DSP ������ �� ���������������� ������� DLL ���������� Lusbapi.dll
    	AbortProgram('�� ���� ��������� ������ E14-440!');
  	end
	else
  	begin
        form1.Memo1.Lines.Add('LOAD_MODULE() --> OK');
  	end;
    if not pModule.TEST_MODULE() then
  	begin
   	    // �������� �������� ������
   	    AbortProgram('������ � �������� ������ E14-440!');
    end
	else
  	begin
   	    form1.Memo1.Lines.Add('TEST_MODULE() --> OK');
  	end;
	if not pModule.GET_MODULE_DESCRIPTION(@ModuleDescription) then
  	begin
   	    // ������ ������� ����� ������ ������������ �������� DSP
    	AbortProgram('�� ���� �������� ���������� � ������!');
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('GET_MODULE_DESCRIPTION() --> OK');
  	end;
    if not pModule.GET_ADC_PARS(@ap) then
  	begin
   	    // ������� ������� ��������� ������ ����� ������
    	AbortProgram('�� ���� �������� ������� ��������� ����� ������!');
  	end
	else
    begin
   	    form1.Memo1.Lines.Add('GET_ADC_PARS --> OK');
  	end;
    // �������� ������������� ������ �� ������ �������� DSP
	ap.IsCorrectionEnabled := TRUE;
  	// ������� ���� ������ ���� ������ ������������� �����
	ap.InputMode := NO_SYNC_E440;
    // ���-�� �������� �������
	ap.ChannelsQuantity := ChannelsQuantity;
	for i:=0 to (ap.ChannelsQuantity-1) do
  	begin
   	    ap.ControlTable[i] := i or ((ADC_INPUT_RANGE_10000mV_E440 shl $6)
   	    or (1 shl $5));
    end;
  	// ������� ����� ������ � ���
	ap.AdcRate := AdcRate;
  	// ����������� �������� - ���� ������ ������������� � 0.0
	ap.InterKadrDelay := 0.0;
  	// ������� ����� FIFO ������ ��� � DSP ������
	ap.AdcFifoBaseAddress := $0;
  	// ����� FIFO ������ ��� � DSP ������
	ap.AdcFifoLength := $3000;
  	// ����� ������������ ��������� ������������� ������������,
  	//������� ��������� � ���� ������ E14-440
	for i:=0 to (ADC_CALIBR_COEFS_QUANTITY_E440-1) do
  	begin
		ap.AdcOffsetCoefs[i] := ModuleDescription.Adc.OffsetCalibration[i];
		ap.AdcScaleCoefs[i] := ModuleDescription.Adc.ScaleCalibration[i];
  	end;
    if not pModule.SET_ADC_PARS(@ap) then
  	begin
   	    // ��������� � ������ ��������� ��������� �� ����� ������
   	    AbortProgram('�� ���� ���������� ��������� ����� ������!');
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('SET_ADC_PARS --> OK');
  	end;
    for i := 0 to 1 do
  	begin
   	    // ��������� �������� ������ ���-�� ������ ��� ������ ������
    	SetLength(Buffer[i], DataStep);
  	end;
	form1.Memo1.Lines.Add('');
    // ��������� ��������� ������ ������ �� ����� ������ � ����������
	form1.Memo1.Lines.Add('');
	form1.Memo1.Lines.Add('Module E14-440 is ready...');
	form1.Memo1.Lines.Add('Module Info:');
	form1.Memo1.Lines.Add(Format('Module  Revision   is ''%1.1s''',
    [StrPas(@ModuleDescription.Module.Revision)]));
	form1.Memo1.Lines.Add(Format('MCU Driver Version is %s (%s)',
    [StrPas(@ModuleDescription.Mcu.Version.Version),
    StrPas(@ModuleDescription.Mcu.Version.Date)]));
	form1.Memo1.Lines.Add(Format('LBIOS   Version    is %s (%s)',
    [StrPas(@ModuleDescription.Dsp.Version.Version),
    StrPas(@ModuleDescription.Dsp.Version.Date)]));
	form1.Memo1.Lines.Add('ADC parameters:');
    if (ap.IsCorrectionEnabled) then
 	begin
   	    form1.Memo1.Lines.Add('Data Correction is ENABLED')
  	end
	else
  	begin
   	    form1.Memo1.Lines.Add('Data Correction is DISABLED');
  	end;
    form1.Memo1.Lines.Add('ChannelsQuantity = '+ IntToStr(ap.ChannelsQuantity));
	form1.Memo1.Lines.Add(Format('AdcRate = %5.3f kHz', [ap.AdcRate]));
	form1.Memo1.Lines.Add(Format('InterKadrDelay = %2.4f ms',[ap.InterKadrDelay]));
	form1.Memo1.Lines.Add(Format('KadrRate =  %5.3f kHz', [ap.KadrRate])+#13#10);
    //form1.Memo1.Lines.Add(#13#10);
end;
//==============================================================================
procedure AdcStart();
begin
    //form1.Memo1.Clear();
    pModule.STOP_ADC();
    // ������� ����� ������ ������ �����
    ReadThreadErrorNumber := 0;
    // ������� ������ ������������� ������ ����� ������
    IsReadThreadComplete := false;
    hReadThread := CreateThread(nil, $2000, @ReadThread, nil, 0, ReadTid);
end;
//==============================================================================
procedure AdcStop ();
begin
	ReadThreadErrorNumber:=4;
  	//--------------------------------��������� �����-----------------------------
  	WaitForSingleObject(hReadThread, 5500);    //INFINITE
  	if hReadThread <> THANDLE(nil) then
  	begin
		CloseHandle(hReadThread);
   	    Application.ProcessMessages;
    	sleep(500);
    	hReadThread:=THANDLE(nil);
  	end;
  	Counter:=0;
  	//  halt;
  	//--------------------------------��������� �����-----------------------------
end;
//==============================================================================
procedure IdleLabels()   ;
begin
    //                   �����   ���      ��        ��
    Form1.lbl10.Caption:='1'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl15.Caption:='2'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl16.Caption:='3'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl14.Caption:='4'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl18.Caption:='5'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl17.Caption:='6'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl20.Caption:='7'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl23.Caption:='8'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl21.Caption:='9'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl24.Caption:='10'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl22.Caption:='11'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl19.Caption:='12'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl26.Caption:='13'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl29.Caption:='14'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl27.Caption:='15'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl30.Caption:='16'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl28.Caption:='17'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl25.Caption:='18'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl31.Caption:='19'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl32.Caption:='20'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl33.Caption:='21'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl34.Caption:='22'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl35.Caption:='23'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl36.Caption:='24'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl37.Caption:='25'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl38.Caption:='26'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl39.Caption:='27'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl40.Caption:='28'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl41.Caption:='29'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl42.Caption:='30'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl43.Caption:='31'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
    Form1.lbl44.Caption:='32'+#9+'  -'+#9+'  -'+#9+'  -'+#9;
end;
procedure TForm1.FormCreate(Sender: TObject);
var
    IniFile:TIniFile;
begin
    DecimalSeparator:='.';
    AkipV7_78_1[0]:='USB[0-9]*::0x164E::0x0DAD::?*INSTR';
    IniFile:=TIniFile.Create(GetCurrentDir+'/���������.ini');
    IP_POWER_SUPPLY_1:=IniFile.ReadString('POWER','IP_address','192.168.0.202');
    if (IdHTTP1.Host='0') then
    begin
        showmessage('���� "��������� ��������� �������� ������� ���.ini" ����������� ��� �������� ������������ ������!');
        Form1.Close;
        Halt;
    end;
    IniFile.Free;
    AdcInit();
    ReceiveActive:= True;  // ���� �������� �� ��� ��� ����� � ��� �������� � 32 ������ ��������� ����������
    buf_wr_i:=0;            // �������� ������ ������
    buf_rd_i:=0;            // �������� ������ ������
    buf_fill:=0;            // �������� ���������� ������ � ������
    DecimalSeparator := '.';// ����� � �������� �����������
    OutEnable:=False  ;     // ����� �� ��������� / ����������� ��������
    NextState:=0;           // ������� ��������� ��������� ������� ������ - 0
    ProgramRun:=false;      // ����� ��� �� ����������
    CurrentVolt:='  -  ';   // �������� ��� Label
    CurrentAmp:='  -  ';    // �������� ��� Label
    //------------------------------------------------------------------------
    // ������ ����� ��� ������� 25-30 - �����������
    SelectOmh25:= False;
    SelectOmh26:= False;
    SelectOmh27:= False;
    SelectOmh28:= False;
    SelectOmh29:= False;
    SelectOmh30:= False;

    if (TestConnect(AkipV7_78_1[0],m_defaultRM_usbtmc[0],m_instr_usbtmc[0],viAttr,Timeout)=-1) then
    begin
        form1.Memo1.Lines.Add('��������� �� ���������'+#13#10);
    end
    else
    begin
        form1.Memo1.Lines.Add('��������� ���������'+#13#10);
    end;
    //-------------------------------------------------------------------------
    IdleLabels();// �������� ��� ������� ������ �������
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    if form1.Button1.Caption='�����' then
    begin
        if(Form1.chk1.Checked=True) then
            SelectOmh25:=True
        else
            SelectOmh25:=False;
        if(Form1.chk2.Checked=True) then
            SelectOmh26:=True
        else
            SelectOmh26:=False;
        if(Form1.chk3.Checked=True) then
            SelectOmh27:=True
        else
            SelectOmh27:=False;
        if(Form1.chk4.Checked=True) then
            SelectOmh28:=True
        else
            SelectOmh28:=False;
        if(Form1.chk5.Checked=True) then
            SelectOmh29:=True
        else
            SelectOmh29:=False;
        if(Form1.chk6.Checked=True) then
            SelectOmh30:=True
        else
            SelectOmh30:=False;
        mydate:=Now;
        FileName:= 'DataOut\report'+FormatDateTime('yyyy.mm.dd_hh.mm.ss', mydate)+'.txt';
        assignfile(FileHandle, FileName);
        if (FileExists(FileName)) then
            Append(FileHandle)
        else
            ReWrite(FileHandle);

        write(FileHandle, '����� + ������ ������� + ���������� + ��� + 5 ����� + 3_3 ����� + 3_9 ����� + ������ ����������'+#13#10);
        write(FileHandle, '����.��� ���/�/�/��'+#9+'1'+#9+'2'+#9+'3'+#9+'4'+#9+'5'+#9+'6'+#9+'7'+#9+'8'+#9+'9'+#9+'10'+#9+'11'+#9+'12'+#9+'13'+#9+'14'+#9+'15'+#9+'16'+#9+'17'+#9+'18'+#9+'19'+#9+'20'+#9+'21'+#9+'22'+#9+'23'+#9+'24'+#9+'25'+#9+'26'+#9+'27'+#9+'28'+#9+'29'+#9+'30'+#9+'31'+#9+'32'+#9+'����'+#9+'���'+#9+'5V'+#9+'3.3V'+#9+'3.9V'+#9+'��������� ����'+#13#10+'----------------------'+#13#10);
        AdcStart;
        DataHandlerPotoc:=DataHandler1.Create(false);
        DataHandlerPotoc.Priority:=tpNormal{tpHigher};
        ProgramRun:=True;       // ��������� ���� ��������
        CompareCalibration_mV1:=StrToFloat(Form1.edt1.Text);
        CompareCalibration_Omh1:=StrToFloat(Form1.edt2.Text);
        Form1.tmr1.Enabled:=True;
        Form1.tmr2.Enabled:=True;
        Form1.tmr3.Enabled:=True;
        form1.Button1.Caption:='����';
    end
    else
    begin
        AdcStop;
        form1.diaTimer.Enabled:=false;
        outToGist:=false;
        Application.ProcessMessages;
        sleep(50);
        form1.Chart1.Series[0].Clear;
        form1.Chart2.Series[0].Clear;
        if(ProgramRun=True)then
        begin
            DataHandlerPotoc.Terminate;
            CloseFile(Filehandle);
            ProgramRun:=False;   // ��������� ���� ���������
        end;
        Form1.tmr1.Enabled:=False;
        Form1.tmr2.Enabled:=False;
        Form1.tmr3.Enabled:=False;
        GetDatStr(m_instr_usbtmc[0],CurrentVolt);
        form1.Button1.Caption:='�����';
    end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
    volt:string;
begin
    if(ProgramRun=True)then
    begin
        DataHandlerPotoc.Terminate;
        CloseFile(Filehandle);
        ProgramRun:=False;
    end;
    GetDatStr(m_instr_usbtmc[0],volt);
    Form1.tmr3.Enabled:=False;
    AdcStop;
end;

procedure TForm1.Series1Click(Sender: TChartSeries; ValueIndex: Integer;
Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	if (outToGist) then
  	begin
   	    outToGist:=false;
    	form1.Chart2.Series[0].Clear;
    	numPoint:=1;
  	end
  	else
  	begin
   	    chInd:=ValueIndex;
    	form1.Memo1.Lines.Add(intTostr(chInd));
    	outToGist:=true;
  	end;
end;

procedure AddToLabels();
var
    i:Integer;
    ChStat:array[1..32] of Integer;
    dMaskByte:Integer;
    CopyChanelsConnectStatus:Integer;
begin
    Form1.lbl10.Caption:='1'+#9+IntToStr(averageInsrtCh[0])+#9+'0'+#9+'  -'+#9;
    Form1.lbl15.Caption:='2'+#9+IntToStr(averageInsrtCh[1])+#9+FloatToStrF(CompareCalibration_mV1,ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl16.Caption:='3'+#9+IntToStr(averageInsrtCh[2])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[2]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl14.Caption:='4'+#9+IntToStr(averageInsrtCh[3])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[3]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl18.Caption:='5'+#9+IntToStr(averageInsrtCh[4])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[4]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl17.Caption:='6'+#9+IntToStr(averageInsrtCh[5])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[5]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl20.Caption:='7'+#9+IntToStr(averageInsrtCh[6])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[6]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl23.Caption:='8'+#9+IntToStr(averageInsrtCh[7])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[7]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl21.Caption:='9'+#9+IntToStr(averageInsrtCh[8])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[8]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl24.Caption:='10'+#9+IntToStr(averageInsrtCh[9])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[9]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl22.Caption:='11'+#9+IntToStr(averageInsrtCh[10])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[10]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl19.Caption:='12'+#9+IntToStr(averageInsrtCh[11])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[11]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl26.Caption:='13'+#9+IntToStr(averageInsrtCh[12])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[12]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl29.Caption:='14'+#9+IntToStr(averageInsrtCh[13])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[13]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl27.Caption:='15'+#9+IntToStr(averageInsrtCh[14])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[14]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl30.Caption:='16'+#9+IntToStr(averageInsrtCh[15])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[15]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl28.Caption:='17'+#9+IntToStr(averageInsrtCh[16])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[16]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl25.Caption:='18'+#9+IntToStr(averageInsrtCh[17])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[17]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl31.Caption:='19'+#9+IntToStr(averageInsrtCh[18])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[18]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl32.Caption:='20'+#9+IntToStr(averageInsrtCh[19])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[19]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl33.Caption:='21'+#9+IntToStr(averageInsrtCh[20])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[20]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl34.Caption:='22'+#9+IntToStr(averageInsrtCh[21])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[21]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl35.Caption:='23'+#9+IntToStr(averageInsrtCh[22])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[22]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    Form1.lbl36.Caption:='24'+#9+IntToStr(averageInsrtCh[23])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[23]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    //--------------------------------------------------------------------------------------------------
    // ����� � ����������� �� ������ ������ / ���
    if(SelectOmh25=false)then
    begin
        Form1.lbl37.Caption:='25'+#9+IntToStr(averageInsrtCh[24])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[24]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl37.Caption:='25'+#9+IntToStr(averageInsrtCh[24])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[24]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
    if(SelectOmh26=false)then
    begin
        Form1.lbl38.Caption:='26'+#9+IntToStr(averageInsrtCh[25])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[25]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl38.Caption:='26'+#9+IntToStr(averageInsrtCh[25])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[25]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
    if(SelectOmh27=false)then
    begin
        Form1.lbl39.Caption:='27'+#9+IntToStr(averageInsrtCh[26])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[26]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl39.Caption:='27'+#9+IntToStr(averageInsrtCh[26])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[26]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
    if(SelectOmh28=false)then
    begin
        Form1.lbl40.Caption:='28'+#9+IntToStr(averageInsrtCh[27])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[27]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl40.Caption:='28'+#9+IntToStr(averageInsrtCh[27])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[27]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
    if(SelectOmh29=false)then
    begin
        Form1.lbl41.Caption:='29'+#9+IntToStr(averageInsrtCh[28])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[28]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl41.Caption:='29'+#9+IntToStr(averageInsrtCh[28])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[28]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
    if(SelectOmh30=false)then
    begin
        Form1.lbl42.Caption:='30'+#9+IntToStr(averageInsrtCh[29])+#9+FloatToStrF((CompareCalibration_mV1 / (Calibration_mV1-Calibration_mV0))*(averageInsrtCh[29]-Calibration_mV0),ffFixed,5,2)+#9+'  -'+#9;
    end
    else
    begin
        Form1.lbl42.Caption:='30'+#9+IntToStr(averageInsrtCh[29])+#9+'  -'+#9+FloatToStrF((CompareCalibration_Omh1 / (Calibration_Omh1-Calibration_Omh0))*(averageInsrtCh[29]-Calibration_Omh0),ffFixed,5,2)+#9;
    end;
            Form1.lbl43.Caption:='31'+#9+IntToStr(averageInsrtCh[30])+#9+'  -'+#9+'  0'+#9;
    Form1.lbl44.Caption:='32'+#9+IntToStr(averageInsrtCh[31])+#9+'  -'+#9+FloatToStrF(CompareCalibration_Omh1,ffFixed,5,2)+#9;
    Form1.lbl3.Caption:=' '+CurrentVolt+'  ';
    Form1.lbl1.Caption:=' '+CurrentAmp+'  ';

    Form1.Label3.Caption:=' '+Current5Volt+'  ';   //����� �������� 5 �����
    Form1.Label5.Caption:=' '+Current3_3Volt+'  '; //����� �������� 3_3 �����
    Form1.Label7.Caption:=' '+Current3_9Volt+'  '; //����� �������� 3_9 �����

    CopyChanelsConnectStatus:=ChanelsConnectStatus;
    dMaskByte  :=1;
    for i:=1 to 32 do
    begin
        ChStat[i]:=0;
    end;

    for  i:=1 to 32 do
    begin
        if((CopyChanelsConnectStatus and dMaskByte)>0) then
        begin
            ChStat[i]:=1;
        end;
        dMaskByte:=dMaskByte shl 1;
    end;

    if( ChStat[1]=0 ) then
    begin
        Form1.lbl10.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl10.Font.Color:=clRed;
    end;
    if( ChStat[2]=0 ) then
    begin
        Form1.lbl15.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl15.Font.Color:=clRed;
    end;
    if( ChStat[3]=0 ) then
    begin
        Form1.lbl16.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl16.Font.Color:=clRed;
    end;
    if( ChStat[4]=0 ) then
    begin
        Form1.lbl14.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl14.Font.Color:=clRed;
    end;
    if( ChStat[5]=0 ) then
    begin
        Form1.lbl18.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl18.Font.Color:=clRed;
    end;
    if( ChStat[6]=0 ) then
    begin
        Form1.lbl17.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl17.Font.Color:=clRed;
    end;
    if( ChStat[7]=0 ) then
    begin
        Form1.lbl20.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl20.Font.Color:=clRed;
    end;
    if( ChStat[8]=0 ) then
    begin
        Form1.lbl23.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl23.Font.Color:=clRed;
    end;
    if( ChStat[9]=0 ) then
    begin
        Form1.lbl21.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl21.Font.Color:=clRed;
    end;
    if( ChStat[10]=0 ) then
    begin
        Form1.lbl24.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl24.Font.Color:=clRed;
    end;
    if( ChStat[11]=0 ) then
    begin
        Form1.lbl22.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl22.Font.Color:=clRed;
    end;
    if( ChStat[12]=0 ) then
    begin
        Form1.lbl19.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl19.Font.Color:=clRed;
    end;
    if( ChStat[13]=0 ) then
    begin
        Form1.lbl26.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl26.Font.Color:=clRed;
    end;
    if( ChStat[14]=0 ) then
    begin
        Form1.lbl29.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl29.Font.Color:=clRed;
    end;
    if( ChStat[15]=0 ) then
    begin
        Form1.lbl27.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl27.Font.Color:=clRed;
    end;
    if( ChStat[16]=0 ) then
    begin
        Form1.lbl30.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl30.Font.Color:=clRed;
    end;
    if( ChStat[17]=0 ) then
    begin
        Form1.lbl28.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl28.Font.Color:=clRed;
    end;
    if( ChStat[18]=0 ) then
    begin
        Form1.lbl25.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl25.Font.Color:=clRed;
    end;
    if( ChStat[19]=0 ) then
    begin
        Form1.lbl31.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl31.Font.Color:=clRed;
    end;
    if( ChStat[20]=0 ) then
    begin
        Form1.lbl32.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl32.Font.Color:=clRed;
    end;
    if( ChStat[21]=0 ) then
    begin
        Form1.lbl33.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl33.Font.Color:=clRed;
    end;
    if( ChStat[22]=0 ) then
    begin
        Form1.lbl34.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl34.Font.Color:=clRed;
    end;
    if( ChStat[23]=0 ) then
    begin
        Form1.lbl35.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl35.Font.Color:=clRed;
    end;
    if( ChStat[24]=0 ) then
    begin
        Form1.lbl36.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl36.Font.Color:=clRed;
    end;
    if( ChStat[25]=0 ) then
    begin
        Form1.lbl37.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl37.Font.Color:=clRed;
    end;
    if( ChStat[26]=0 ) then
    begin
        Form1.lbl38.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl38.Font.Color:=clRed;
    end;if( ChStat[27]=0 ) then
    begin
        Form1.lbl39.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl39.Font.Color:=clRed;
    end;
    if( ChStat[28]=0 ) then
    begin
        Form1.lbl40.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl40.Font.Color:=clRed;
    end;
    if( ChStat[29]=0 ) then
    begin
        Form1.lbl41.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl41.Font.Color:=clRed;
    end;if( ChStat[30]=0 ) then
    begin
        Form1.lbl42.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl42.Font.Color:=clRed;
    end;if( ChStat[31]=0 ) then
    begin
        Form1.lbl43.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl43.Font.Color:=clRed;
    end;if( ChStat[32]=0 ) then
    begin
        Form1.lbl44.Font.Color:=clBlack;
    end
    else
    begin
        Form1.lbl44.Font.Color:=clRed;
    end;
end;

procedure TForm1.diaTimerTimer(Sender: TObject);
var
	i:integer;
begin
   form1.Chart1.Series[0].Clear;
   for i:=0 to 31 do
   begin
      Form1.Chart1.Series[0].AddXY(i+1,averageInsrtCh[i]);
   end;
end;

procedure OutSeria() ;
begin
    form1.Chart1.Series[0].Clear;
    Form1.Chart1.Series[0].AddXY(1,averageInsrtCh[0]);
    Form1.Chart1.Series[0].AddXY(2,averageInsrtCh[1]);
    Form1.Chart1.Series[0].AddXY(3,averageInsrtCh[2]);
    Form1.Chart1.Series[0].AddXY(4,averageInsrtCh[3]);
    Form1.Chart1.Series[0].AddXY(5,averageInsrtCh[4]);
    Form1.Chart1.Series[0].AddXY(6,averageInsrtCh[5]);
    Form1.Chart1.Series[0].AddXY(7,averageInsrtCh[6]);
    Form1.Chart1.Series[0].AddXY(8,averageInsrtCh[7]);
    Form1.Chart1.Series[0].AddXY(9,averageInsrtCh[8]);
    Form1.Chart1.Series[0].AddXY(10,averageInsrtCh[9]);
    Form1.Chart1.Series[0].AddXY(11,averageInsrtCh[10]);
    Form1.Chart1.Series[0].AddXY(12,averageInsrtCh[11]);
    Form1.Chart1.Series[0].AddXY(13,averageInsrtCh[12]);
    Form1.Chart1.Series[0].AddXY(14,averageInsrtCh[13]);
    Form1.Chart1.Series[0].AddXY(15,averageInsrtCh[14]);
    Form1.Chart1.Series[0].AddXY(16,averageInsrtCh[15]);
    Form1.Chart1.Series[0].AddXY(17,averageInsrtCh[16]);
    Form1.Chart1.Series[0].AddXY(18,averageInsrtCh[17]);
    Form1.Chart1.Series[0].AddXY(19,averageInsrtCh[18]);
    Form1.Chart1.Series[0].AddXY(20,averageInsrtCh[19]);
    Form1.Chart1.Series[0].AddXY(21,averageInsrtCh[20]);
    Form1.Chart1.Series[0].AddXY(22,averageInsrtCh[21]);
    Form1.Chart1.Series[0].AddXY(23,averageInsrtCh[22]);
    Form1.Chart1.Series[0].AddXY(24,averageInsrtCh[23]);
    Form1.Chart1.Series[0].AddXY(25,averageInsrtCh[24]);
    Form1.Chart1.Series[0].AddXY(26,averageInsrtCh[25]);
    Form1.Chart1.Series[0].AddXY(27,averageInsrtCh[26]);
    Form1.Chart1.Series[0].AddXY(28,averageInsrtCh[27]);
    Form1.Chart1.Series[0].AddXY(29,averageInsrtCh[28]);
    Form1.Chart1.Series[0].AddXY(30,averageInsrtCh[29]);
    Form1.Chart1.Series[0].AddXY(31,averageInsrtCh[30]);
    Form1.Chart1.Series[0].AddXY(32,averageInsrtCh[31]);
end;


// ������ ���������� �� ����� ������� �������� ������ 1-32
procedure TForm1.tmr1Timer(Sender: TObject);
begin
    Calibration_mV0:=averageInsrtCh[0];      // ������� �������� �������� ������ - ���������� 0 ��
    Calibration_mV1:=averageInsrtCh[1];      // ������� �������� ������� ������ - ���������� �������� ����������
    Calibration_Omh0:=averageInsrtCh[30];    // ������� �������� 30 ������ - ���������� 0 ��
    Calibration_Omh1:=averageInsrtCh[31];    // ������� �������� 31 ������ - ���������� �������� ��
    if( Calibration_mV0 = 0) then            // ������ �� ������� �� 0
    begin
       Calibration_mV0:=0.01
    end;
    if( Calibration_Omh0 = 0) then
    begin
       Calibration_Omh0:=0.01
    end;
    if(ReceiveActive=True)then
    begin
        AddToLabels();
        if(Form1.tmr2.Enabled=False) then
        begin
            Form1.tmr2.Enabled:=True;
        end;
    end
    else
    begin
        IdleLabels();
        form1.Chart1.Series[0].Clear;
        Form1.tmr2.Enabled:=False;
        Form1.lbl3.Caption:=' '+CurrentVolt+'  ';
        Form1.lbl1.Caption:=' '+CurrentAmp+'  ';
    end;
    ReceiveActive:= False;
end;
// ������ ���������� �� ����� ��������
procedure TForm1.tmr2Timer(Sender: TObject);
begin
    OutSeria() ;
end;

// ������ ���������� �� ����� ���������� � ��������� �������
procedure TForm1.tmr3Timer(Sender: TObject);
var
    volt:string;
begin
    if(TimParity=0) then
    begin
        SetConf(m_instr_usbtmc[0],'READ?'); //���
        SendCommandToPowerSupply(1, 'GETD');
        TimParity:=1;
    end
    else
    begin
        GetDatStr(m_instr_usbtmc[0],volt);  //�����
        CurrentVolt:=volt;
        TimParity:=0;
    end;
end;

// ������ �������� ������������ ��������
procedure TForm1.btn2Click(Sender: TObject);
var
    i:Integer;
begin
    if (TestConnect(AkipV7_78_1[0],m_defaultRM_usbtmc[0],m_instr_usbtmc[0],viAttr,Timeout)=-1) then
    begin
        form1.Memo1.Lines.Add('��������� �� ���������'+#13#10);
    end
    else
    begin
        form1.Memo1.Lines.Add('��������� ���������'+#13#10);
        SetConf(m_instr_usbtmc[0],'READ?');
        Sleep(20);
        GetDatStr(m_instr_usbtmc[0],CurrentVolt);
    end;
    // �������� ��������� �������
    flagCur:=false;
    AkipOff:=false;
    SendCommandToPowerSupply(1, 'GETD'); // ������� ��� �����������
    form1.Tmr4.Enabled:=true;
    while(flagCur=false) and (AkipOff=false) do
    begin
        application.ProcessMessages;
    end;
    form1.Tmr4.Enabled:=false;
    if(AkipOff=true) then
    begin
        Form1.Memo1.Lines.Add('�������� ������� �� ��������.');
    end
    else
        Form1.Memo1.Lines.Add('�������� ������� ���������.');
end;
//--------------------------------------------------------------------
// �������� ������������� ���� �� - ��
procedure TForm1.chk1Click(Sender: TObject);
begin
    if(Form1.chk1.Checked=True) then
        SelectOmh25:=True
    else
        SelectOmh25:=False;
end;

procedure TForm1.chk2Click(Sender: TObject);
begin
    if(Form1.chk2.Checked=True) then
        SelectOmh26:=True
    else
        SelectOmh26:=False;

end;

procedure TForm1.chk3Click(Sender: TObject);
begin
    if(Form1.chk3.Checked=True) then
        SelectOmh27:=True
    else
        SelectOmh27:=False;
end;

procedure TForm1.chk4Click(Sender: TObject);
begin
    if(Form1.chk4.Checked=True) then
        SelectOmh28:=True
    else
        SelectOmh28:=False;
end;

procedure TForm1.chk5Click(Sender: TObject);
begin
    if(Form1.chk5.Checked=True) then
        SelectOmh29:=True
    else
        SelectOmh29:=False;
end;

procedure TForm1.chk6Click(Sender: TObject);
begin
    if(Form1.chk6.Checked=True) then
        SelectOmh30:=True
    else
        SelectOmh30:=False;
end;
//--------------------------------------------------------------------

// ����� ������ �� ��������� �������
procedure TForm1.idUDPServer2UDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
A:array[1..1000] of char;
A1:string;
I:double;
begin
    if ABinding.PeerIp = IP_POWER_SUPPLY_1 then
    begin
        AData.Read(A,aData.size);
        if((verify_send=false) and (A[1]='O')) then
        begin
            verify_send:=true;
        end;
        if A[1] <> 'O' then
        begin
            A1:=A[5]+'.'+A[6]+A[7]+A[8];
            CurrentAmp:=A1;
            //Form1.Memo1.Lines.Add(CurrentAmp);
            FlagCur:=True;
        end;
    end;
end;
// ������ �������� ��������� �������
procedure TForm1.tmr4Timer(Sender: TObject);
begin
    AkipOFF:=True;
end;

end.


