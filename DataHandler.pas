// Поток обрабатывающий принятые данные из ацп
unit DataHandler;

interface

uses
  Classes, PSDT, Forms, 	Windows, Messages, SysUtils, Variants, Graphics, Controls;

type
  DataHandler1 = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;
var
  DataHandlerPotoc: DataHandler1;

implementation


procedure AddToLabels16_32();
begin

end;




procedure DataHandler1.Execute;
var
    i:Integer;
    j:Integer;
    n:Integer;
    average:Integer;
    a:Integer;
    iv:Integer;
    c:Integer;
    NumOfGraf:Integer;
    StrToFile: string;
begin
    n:=0;
    i:=0;
    j:=0;
    iv:=0;
    average:=0;
    while(True) do
    begin
        if DataHandlerPotoc.Terminated then break;
        if(buf_fill>120)and(OutEnable=true) then
        begin
            case NextState of                              // Переключение по вложенным каналам
                0:                                           // Если прога только запустилась найдем 0 в сигнале маркера 1го канала
                begin
                    if( ((Chanel_data[2][buf_rd_i])>(-250)) and ((Chanel_data[2][buf_rd_i])<(250)) ) then   // Диапазон нуля +-15 Ищем 0 на маркере 1го канала
                    begin
                        NextState:=1;
                        n:=0;
                    end;
                end;
                1:                                          // Теперь ждем восходящий фронт маркера 1го канала
                begin
                    if(Chanel_data[2][buf_rd_i]>1000)  then   // Если стало >  1.2 Вольта  Ищем 1 на маркере 1го канала
                    begin
                        n:=n+1;                                // Считаем 20 точек в лог 1
                    end
                    else
                    begin                                     // Если помеха обнуляем
                        n:=0;
                    end;
                    if(n>30)then                              // 20 точек посчитали
                    begin
                        Current5Volt :=FloatToStrF( Chanel_data[5][buf_rd_i]/819.1,ffFixed ,4,2);
                        Current3_3Volt :=FloatToStrF( Chanel_data[6][buf_rd_i]/819.1,ffFixed ,4,2);
                        Current3_9Volt :=FloatToStrF( Chanel_data[7][buf_rd_i]/819.1,ffFixed ,4,2);
                        
                        CurrentInsertChanel:=0;               // Вложенный канал 0
                        NextState:=6;                         // Отправляемся считать среднее значение
                        NextNextState:=2;                     // А потом искать нисподающий фронт на маркере четного/нечетного
                        n:=0;
                        j:=0;
                        average:=0;
                    end;
                end;
                2:                                            // Ждем ниспадающий фронт на маркере четного/нечетного
                begin
                    if( ((Chanel_data[1][buf_rd_i])>(-250)) and ((Chanel_data[1][buf_rd_i])<(250)) )  then // Диапазон нуля +-15  Ищем 0 на маркере четного/нечетного канала
                    begin
                        n:=n+1;                                // Считаем 20 точек в лог 0
                    end
                    else
                    begin
                        n:=0;                                  // Если помеха обнуляем
                    end;
                    if(n>30)then                              // 20 точек == 0 помех нет
                    begin
                        CurrentInsertChanel:=CurrentInsertChanel+1;      // Инкрементируем канал
                        NextState:=6;                          // Посчитать среднее значение
                        if(CurrentInsertChanel=31)then         // Если текущий канал 32
                        begin
                            NextNextState:=1;                   // Идем искать первый канал
                        end
                        else
                        begin
                            NextNextState:=3;
                        end;
                        n:=0;
                    end;
                end;
                3:                                              // Ждем возрастающий фронт
                begin
                    if(Chanel_data[1][buf_rd_i]>1000)  then      // Ищем 1 на маркере четного/нечетного канала  (если >1.2В)
                    begin
                        n:=n+1;
                    end
                    else
                    begin
                        n:=0;
                    end;
                    if(n>30)then
                    begin

                        NextState:=6;
                        CurrentInsertChanel:=CurrentInsertChanel+1;     // Инкрементируем канал
                        n:=0;
                        NextNextState:=2;
                    end;
                end;
                6:
                begin
                    average:=0;
                    if(Chanel_data[3][buf_rd_i]>1000)then
                    begin
                        ChanelsConnectStatus:= ChanelsConnectStatus or (1 shl CurrentInsertChanel);
                    end
                    else
                    begin
                        ChanelsConnectStatus:= ChanelsConnectStatus and (not(1 shl CurrentInsertChanel));
                    end;
                    for j:=0 to 39  do                              // Среденее арифмитическое по 40 точкам
                    begin
                        average:=average+Chanel_data[0][buf_rd_i];
                        buf_rd_i:=buf_rd_i+1;
                        if(buf_rd_i=ChanelBufSize*100)  then
                        begin
                            buf_rd_i:=0;
                        end;
                        buf_fill:=buf_fill-1;
                    end;
                    buf_rd_i:=buf_rd_i-1;
                    buf_fill:=buf_fill+1;
                    averageInsrtCh[CurrentInsertChanel]:=average div 40;  // Записываем в массив для выдачи
                    NextState:=NextNextState;
                    if (CurrentInsertChanel = 31)then
                    begin
                        StrToFile:=FormatDateTime('dd.yy hh.mm.ss.ms', Now())+#9;
                        for c:=0 to 31 do
                        begin
                            StrToFile:=StrToFile+IntToStr(averageInsrtCh[c])+#9;
                        end;
                        StrToFile:=StrToFile+CurrentVolt+#9+CurrentAmp+#9+Current5Volt+#9+Current3_3Volt+#9+Current3_9Volt+#9+IntToStr(ChanelsConnectStatus)+#13#10;
                        write(FileHandle,StrToFile);
                        ReceiveActive:= True; 
                    end
                    else if(CurrentInsertChanel = 2) then
                    begin
                       // AddToLabels16_32();
                        //Calibration_mV0:=averageInsrtCh[0];
                        //Calibration_mV1:=averageInsrtCh[1];
                        //AddToLabels1_15();

                    end
                    else if( CurrentInsertChanel = 19)then
                    begin
                        if(Form1.rb33.Checked=True)then
                        begin
                            NumOfGraf:=0;
                        end
                        else if (Form1.rb2.Checked=True) then
                        begin
                            NumOfGraf:=1;
                        end
                        else if(Form1.rb3.Checked=True)then
                        begin
                            NumOfGraf:=2;
                        end
                        else if(Form1.rb4.Checked=True)then
                        begin
                            NumOfGraf:=3;
                        end
                        else if(Form1.rb5.Checked=True)then
                        begin
                            NumOfGraf:=4;
                        end
                        else if(Form1.rb6.Checked=True)then
                        begin
                            NumOfGraf:=5;
                        end
                        else if(Form1.rb7.Checked=True)then
                        begin
                            NumOfGraf:=6;
                        end
                        else if(Form1.rb8.Checked=True)then
                        begin
                            NumOfGraf:=7;
                        end
                        else if(Form1.rb9.Checked=True)then
                        begin
                            NumOfGraf:=8;
                        end
                        else if(Form1.rb10.Checked=True)then
                        begin
                            NumOfGraf:=9;
                        end
                        else if(Form1.rb11.Checked=True)then
                        begin
                            NumOfGraf:=10;
                        end
                        else if(Form1.rb12.Checked=True)then
                        begin
                            NumOfGraf:=11;
                        end
                        else if(Form1.rb13.Checked=True)then
                        begin
                            NumOfGraf:=12;
                        end
                        else if(Form1.rb14.Checked=True)then
                        begin
                            NumOfGraf:=13;
                        end
                        else if(Form1.rb15.Checked=True)then
                        begin
                            NumOfGraf:=14;
                        end
                        else if(Form1.rb16.Checked=True)then
                        begin
                            NumOfGraf:=15;
                        end
                        else if(Form1.rb17.Checked=True)then
                        begin
                            NumOfGraf:=16;
                        end
                        else if(Form1.rb18.Checked=True)then
                        begin
                            NumOfGraf:=17;
                        end
                        else if(Form1.rb19.Checked=True)then
                        begin
                            NumOfGraf:=18;
                        end
                        else if(Form1.rb20.Checked=True)then
                        begin
                            NumOfGraf:=19;
                        end
                        else if(Form1.rb21.Checked=True)then
                        begin
                            NumOfGraf:=20;
                        end
                        else if(Form1.rb22.Checked=True)then
                        begin
                            NumOfGraf:=21;
                        end
                        else if(Form1.rb23.Checked=True)then
                        begin
                            NumOfGraf:=22;
                        end
                        else if(Form1.rb24.Checked=True)then
                        begin
                            NumOfGraf:=23;
                        end
                        else if(Form1.rb25.Checked=True)then
                        begin
                            NumOfGraf:=24;
                        end
                        else if(Form1.rb26.Checked=True)then
                        begin
                            NumOfGraf:=25;
                        end
                        else if(Form1.rb27.Checked=True)then
                        begin
                            NumOfGraf:=26;
                        end
                        else if(Form1.rb28.Checked=True)then
                        begin
                            NumOfGraf:=27;
                        end
                        else if(Form1.rb29.Checked=True)then
                        begin
                            NumOfGraf:=28;
                        end
                        else if(Form1.rb30.Checked=True)then
                        begin
                            NumOfGraf:=29;
                        end
                        else if(Form1.rb31.Checked=True)then
                        begin
                            NumOfGraf:=30;
                        end
                        else if(Form1.rb32.Checked=True)then
                        begin
                            NumOfGraf:=31;
                        end ;
                        if (numPoint<trunc(form1.Chart2.BottomAxis.Maximum))then
                        begin
                            form1.Series2.AddXY(numPoint,averageInsrtCh[NumOfGraf]);
                        end;
                        inc(numPoint);
                        if numPoint>trunc(form1.Chart2.BottomAxis.Maximum) then
                        begin
                            outToGist:=false;
                            form1.Series2.Clear;
                            numPoint:=1;
                            outToGist:=true;
                        end;
                    end;
                end;
            end;
            buf_rd_i:=buf_rd_i+1;
            buf_fill:=buf_fill-1;
            if(buf_rd_i=ChanelBufSize*100)  then
            begin
                buf_rd_i:=0;
            end;
        end
        else
        begin

        end;
    end;
    DataHandlerPotoc.Free;
end;
end.

