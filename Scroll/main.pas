unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  Menus, BaseUnix, SynHighlighterPas, SynEdit, LCLType,
  ComCtrls, ExtCtrls, Process, SynGutterLineNumber, SynEditTypes;

type

  { TScrol }

  TScrol = class(TForm)
    FontDialog1: TFontDialog;
    CopyMenuItem: TMenuItem;
    DarkMenuItem: TMenuItem;
    CompileMenuItem: TMenuItem;
    CutMenuItem: TMenuItem;
    FontMenuItem: TMenuItem;
    ReplaceMenuItem: TMenuItem;
    TerminalMenuItem: TMenuItem;
    RunMenuItem: TMenuItem;
    ProjectMenu: TMenuItem;
    Separator3: TMenuItem;
    StatusBar1: TStatusBar;
    ViewMenu: TMenuItem;
    PasteMenuItem: TMenuItem;
    UndoMenuItem: TMenuItem;
    RedoMenuItem: TMenuItem;
    SaveAsMenuItem: TMenuItem;
    MainMenu1: TMainMenu;
    fileMenu: TMenuItem;
    NewMenuItem: TMenuItem;
    OpenMenuItem: TMenuItem;
    SaveMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    EditMenu: TMenuItem;
    SynHighlightMenuItem: TMenuItem;
    LineNumMenuItem: TMenuItem;
    OpenDialog1: TOpenDialog;
    ReplaceDialog1: TReplaceDialog;
    SaveAsDialog1: TSaveDialog;
    Separator1: TMenuItem;
    Separator2: TMenuItem;
    SynEdit1: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    procedure FormCreate(Sender: TObject);
    procedure CompileMenuItemClick(Sender: TObject);
    procedure CopyMenuItemClick(Sender: TObject);
    procedure CutMenuItemClick(Sender: TObject);
    procedure DarkMenuItemClick(Sender: TObject);
    procedure FontMenuItemClick(Sender: TObject);
    procedure fileMenuClick(Sender: TObject);
    procedure SynEdit1Change(Sender: TObject);
    procedure TerminalMenuItemClick(Sender: TObject);
    procedure NewMenuItemClick(Sender: TObject);
    procedure OpenMenuItemClick(Sender: TObject);
    procedure ReplaceMenuItemClick(Sender: TObject);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure EditMenuClick(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SynHighlightMenuItemClick(Sender: TObject);
    procedure LineNumMenuItemClick(Sender: TObject);
    procedure PasteMenuItemClick(Sender: TObject);
    procedure RedoMenuItemClick(Sender: TObject);
    procedure RunMenuItemClick(Sender: TObject);
    procedure SaveAsMenuItemClick(Sender: TObject);
    procedure UndoMenuItemClick(Sender: TObject);
    procedure SynEdit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure SynEdit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Scrol: TScrol;
  filename:   String;
  FCurrentFile: String;
  CurrentDIR: String;

implementation

{$R *.lfm}

{ TScrol }

procedure TScrol.FormCreate(Sender: TObject);
var
      filename: String;
begin
    if ParamCount = 1 then
       begin
            filename := ParamStr(1);
           SynEdit1.Lines.LoadFromFile(filename);
       end;
    if ParamCount >= 2 then
       WriteLn('Too many arguments...');

    Caption := 'Scroll';

      {$IFDEF DARWIN}
        SynEdit1.Font.Name := 'Andale Mono';
        SynEdit1.Font.Size := 10;
      {$ENDIF}
      {$IFDEF LINUX}
        SynEdit1.Font.Name := 'Monospace';
        SynEdit1.Font.Size := 10;
      {$ENDIF}
      {$IFDEF WINDOWS}
      SynEdit1.Font.Name := 'Consolas';
      SynEdit1.Font.Size := 10;
      {$ENDIF}

      {$IFDEF DARWIN}
        SaveMenuItem.ShortCut := ShortCut(Ord('S'), [ssMeta]);
        OpenMenuItem.ShortCut := ShortCut(Ord('O'), [ssMeta]);
        NewMenuItem.ShortCut := ShortCut(Ord('N'), [ssMeta]);
        CopyMenuItem.ShortCut := ShortCut(Ord('C'), [ssMeta]);
        PasteMenuItem.ShortCut := ShortCut(Ord('V'), [ssMeta]);
        CutMenuItem.ShortCut := ShortCut(Ord('X'), [ssMeta]);
        TerminalMenuItem.ShortCut := ShortCut(Ord('T'), [ssMeta]);
        DarkMenuItem.ShortCut := ShortCut(Ord('D'), [ssMeta]);
        ReplaceMenuItem.ShortCut := ShortCut(Ord('R'), [ssMeta]);
        ExitMenuItem.ShortCut := ShortCut(Ord('Q'), [ssMeta]);
        LineNumMenuItem.ShortCut := ShortCut(Ord('L'), [ssMeta]);
        FontMenuItem.ShortCut := ShortCut(Ord('F'), [ssMeta]);
        SynHighlightMenuItem.ShortCut := ShortCut(Ord('H'), [ssMeta]);
      {$ELSE}
        SaveMenuItem.ShortCut := ShortCut(Ord('S'), [ssCtrl]);
        OpenMenuItem.ShortCut := ShortCut(Ord('O'), [ssCtrl]);
        NewMenuItem.ShortCut := ShortCut(Ord('N'), [ssCtrl]);
        CopyMenuItem.ShortCut := ShortCut(Ord('C'), [ssCtrl]);
        PasteMenuItem.ShortCut := ShortCut(Ord('V'), [ssCtrl]);
        CutMenuItem.ShortCut := ShortCut(Ord('X'), [ssCtrl]);
        TerminalMenuItem.ShortCut := ShortCut(Ord('T'), [ssCtrl]);
        DarkMenuItem.ShortCut := ShortCut(Ord('D'), [ssCtrl]);
        ReplaceMenuItem.ShortCut := ShortCut(Ord('R'), [ssCtrl]);
        ExitMenuItem.ShortCut := ShortCut(Ord('Q'), [ssCtrl]);
        LineNumMenuItem.ShortCut := ShortCut(Ord('L'), [ssCtrl]);
        FontMenuItem.ShortCut := ShortCut(Ord('F'), [ssCtrl]);
        SynHighlightMenuItem.ShortCut := ShortCut(Ord('H'), [ssCtrl]);
       {$ENDIF}

end;

// MISC PROCEDURES
      // COMPILE FUNCTIONS NEED WORK
procedure compileTerm;
var
  runcom: String;
  compcom: String;
  filename: String;
  Proc: TProcess;
begin
  if FCurrentFile = '' then Exit;
  filename := ExtractFileName(FCurrentFile);
  filename := ChangeFileExt(filename, '');
  compcom := 'fpc ' + FCurrentFile;
  runcom := './' + filename;
  Proc := TProcess.Create(nil);
  try
    {$IFDEF DARWIN}
    Proc.Executable := '/usr/bin/osascript';
    Proc.Parameters.Add('-e');
    Proc.Parameters.Add('tell application "Terminal" to do script "cd \"' +
                        ExtractFilePath(FCurrentFile) + '\" && ' +
                        compcom + ' && ' + runcom + '"');
    {$ENDIF}
    {$IFDEF LINUX}
    Proc.Executable := 'xterm';
    Proc.Parameters.Add('-e');
    Proc.Parameters.Add('bash -c "' + compcom + ' && ' + runcom + '; read -p ''Press enter to close...''"');
    {$ENDIF}
    Proc.Execute;
  finally
    Proc.Free;
  end;
end;

procedure compileOnly;
var
  runcom: String;
  compcom: String;
  filename: String;
  Proc: TProcess;
begin
  if FCurrentFile = '' then Exit;
  filename := ExtractFileName(FCurrentFile);
  filename := ChangeFileExt(filename, '');
  compcom := 'fpc ' + FCurrentFile;
  runcom := './' + filename;
  Proc := TProcess.Create(nil);
  try
    {$IFDEF DARWIN}
    Proc.Executable := '/usr/bin/osascript';
    Proc.Parameters.Add('-e');
    Proc.Parameters.Add('tell application "Terminal" to do script "cd \"' +
                        ExtractFilePath(FCurrentFile) + '\" && ' +
                        compcom);
    {$ENDIF}
    {$IFDEF LINUX} // This block only runs on Linux
    // We use xterm here as it is the most universal;
    // -e tells it to execute the following string
    Proc.Executable := 'xterm';
    Proc.Parameters.Add('-e');
    Proc.Parameters.Add('bash -c "' + compcom + '; read -p ''Press enter to close...''"');
    {$ENDIF}
    Proc.Execute;
  finally
    Proc.Free;
  end;
end;


// MENUBAR ITEMS

procedure TScrol.CompileMenuItemClick(Sender: TObject);
begin
  CompileOnly;
end;

procedure TScrol.CopyMenuItemClick(Sender: TObject);
begin
  SynEdit1.CopyToClipboard;
end;

procedure TScrol.CutMenuItemClick(Sender: TObject);
begin
  SynEdit1.CutToClipboard;
end;

procedure TScrol.DarkMenuItemClick(Sender: TObject);
begin
  if SynEdit1.Color = clWhite then
  begin
    SynEdit1.Color := clBlack;
    SynEdit1.Gutter.Color := clBlack;
    SynEdit1.Font.Color := clWhite;
  end
  else
  begin
    SynEdit1.Color := clWhite;
    SynEdit1.Gutter.Color := clWhite;
    SynEdit1.Font.Color := clBlack;
  end;
end;

procedure TScrol.FontMenuItemClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    SynEdit1.Font := FontDialog1.Font;
  end;
end;

procedure TScrol.TerminalMenuItemClick(Sender: TObject);
  var
    p: TProcess;
  begin
       p := TProcess.Create(nil);
       fpChDir(filename);
       currentDIR := ExtractFileDir(FCurrentFile);
         {$IFDEF DARWIN}
            p.Executable := '/usr/bin/open';
            p.Parameters.Add('-a');
            p.Parameters.Add('Terminal');
            p.Parameters.Add(currentDIR);
            p.Execute;
            p.Free;
         {$ENDIF}
         {$IFDEF WINDOWS}
            p.Executable := 'cmd.exe';
            p.CurrentDirectory := currentDIR;
            p.Execute;
            p.Free;
         {$ENDIF}
         {$IFDEF LINUX}
            p.Executable := '/usr/bin/xterm';
            p.Execute;
            p.Free;
         {$ENDIF}
      end;

procedure TScrol.NewMenuItemClick(Sender: TObject);
begin
    SynEdit1.Lines.Clear;
    FCurrentFile := '';
end;

procedure TScrol.OpenMenuItemClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    filename := OpenDialog1.FileName;
    FCurrentFile := OpenDialog1.FileName;
    SynEdit1.Lines.LoadFromFile(filename);
    StatusBar1.Panels[1].Text := filename;
    Caption := ExtractFileName(OpenDialog1.FileName);
  end;
  FCurrentFile := OpenDialog1.FileName;
end;

procedure TScrol.ReplaceMenuItemClick(Sender: TObject);
  var
    OldText, NewText: String;
  begin
    OldText := InputBox('Find Text', 'Enter text to find:', '');
    if OldText = '' then Exit;

    NewText := InputBox('Replace With', 'Replace with:', '');

    SynEdit1.Text := StringReplace(
      SynEdit1.Text,
      OldText,
      NewText,
      [rfReplaceAll, rfIgnoreCase]
    );
  end;

procedure TScrol.SaveMenuItemClick(Sender: TObject);
begin
    if FCurrentFile = '' then
    begin
    SaveAsMenuItemClick(Sender);
    StatusBar1.Panels[1].Text := filename;
    end
  else
    SynEdit1.Lines.SaveToFile(FCurrentFile);
    StatusBar1.Panels[1].Text := filename;
end;

procedure TScrol.ExitMenuItemClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TScrol.LineNumMenuItemClick(Sender: TObject);
begin
  SynEdit1.Gutter.Visible := not SynEdit1.Gutter.Visible;
end;

procedure TScrol.PasteMenuItemClick(Sender: TObject);
begin
  SynEdit1.PasteFromClipboard();
end;

procedure TScrol.RedoMenuItemClick(Sender: TObject);
begin
  SynEdit1.Redo;
end;

procedure TScrol.RunMenuItemClick(Sender: TObject);
begin
   CompileTerm();
end;

procedure TScrol.SaveAsMenuItemClick(Sender: TObject);
begin
  if SaveAsDialog1.Execute then
  begin
    SynEdit1.Lines.SaveToFile(SaveAsDialog1.FileName);
    FCurrentFile := SaveAsDialog1.FileName;
    Caption := ExtractFileName(SaveAsDialog1.FileName);
    StatusBar1.Panels[1].Text := filename;
  end;
end;

procedure TScrol.UndoMenuItemClick(Sender: TObject);
begin
  SynEdit1.Undo;
end;

procedure TScrol.EditMenuClick(Sender: TObject);
begin

end;

procedure TScrol.FileMenuClick(Sender: TObject);
begin

end;

procedure TScrol.SynEdit1Change(Sender: TObject);
begin

end;

// SYNEDIT AND SYNTAX HIGHLIGHTING

procedure TScrol.SynEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then
  begin
    // Move cursor to end of the next line
    if SynEdit1.CaretY < SynEdit1.Lines.Count then
    begin
      SynEdit1.CaretXY := Point(
        Length(SynEdit1.Lines[SynEdit1.CaretY]) + 1, // End of next line
        SynEdit1.CaretY + 1
      );
      Key := 0; // Prevent default down arrow behavior
    end;
  end
  else if Key = VK_UP then
  begin
    // Optional: Same for up arrow
    if SynEdit1.CaretY > 1 then
    begin
      SynEdit1.CaretXY := Point(
        Length(SynEdit1.Lines[SynEdit1.CaretY - 2]) + 1, // End of previous line
        SynEdit1.CaretY - 1
      );
      Key := 0; // Prevent default up arrow behavior
    end;
  end;
end;

procedure TScrol.SynHighlightMenuItemClick(Sender: TObject);
begin

  if SynEdit1.Highlighter = SynPasSyn1 then
    SynEdit1.Highlighter := nil
  else
    SynEdit1.Highlighter := SynPasSyn1;

  SynEdit1.Invalidate;

  if Sender is TMenuItem then
    (Sender as TMenuItem).Checked := (SynEdit1.Highlighter = SynPasSyn1);
end;

procedure TScrol.SynEdit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  MousePos: TPoint;
  LineText: String;
  ClickedCharIndex: Integer;
  BufferZone: Integer;

begin
  if (Button = mbLeft) and not (ssShift in Shift) then
  begin
    MousePos := SynEdit1.PixelsToRowColumn(Point(X, Y));
    ClickedCharIndex := MousePos.X;
    LineText := SynEdit1.Lines[MousePos.Y - 1];

    BufferZone := 2;

    if ClickedCharIndex > Length(LineText) + BufferZone then
    begin
      SynEdit1.CaretXY := Point(Length(LineText) + 1, MousePos.Y);
    end;
  end;
  if (Button = mbMiddle) and not (ssShift in Shift) then
     SynEdit1.PasteFromClipboard();
  if (Button = mbRight) and not (ssShift in Shift) then
     SynEdit1.CopyToClipboard;
end;

procedure TScrol.SynEdit1StatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  StatusBar1.Panels[0].Text := ' ' + IntToStr(SynEdit1.CaretY) + ':' + IntToStr(SynEdit1.CaretX);
end;


end.

