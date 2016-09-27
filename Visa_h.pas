unit Visa_h;

interface

type
  vichar = array of char;

  function viOpenDefaultRM(vi:pLongWord): integer;                                                         stdcall; external 'visa32.DLL' name 'viOpenDefaultRM';
  function viFindRsrc(sesn:LongWord; expr: string; vi:pLongWord; retCnt:pLongWord;sesc:vichar): integer;    stdcall; external 'visa32.DLL' name 'viFindRsrc';
  function viOpen(sesn:LongWord; name:viChar; mode:LongWord; timeout:LongWord; vi:pLongWord): integer;      stdcall; external 'visa32.DLL' name 'viOpen';
  function viClose(vi:LongWord): integer;                                                                  stdcall; external 'visa32.DLL' name 'viClose';
  function viWrite(vi:LongWord; name:vichar; len:LongWord; retval:pLongWord): integer;                      stdcall; external 'visa32.DLL' name 'viWrite';
  function viSetAttribute(vi:LongWord; viAttr:LongWord; attrstat:LongWord): integer;                       stdcall; external 'visa32.DLL' name 'viSetAttribute';
  function viRead(vi:LongWord; name: vichar; len: LongWord; retval:pLongWord): integer;                     stdcall; external 'visa32.DLL' name 'viRead';

implementation
 

end.

