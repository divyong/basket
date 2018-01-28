uses wingraph, wincrt, sysutils;

const

	// Константы для считывания клавиш
	up = #72;
	left = #75;
	right = #77;
	down = #80;
	esc = #27;
	c = #99;
	enter = #13;

	// Количество фруктов
	fc = 9;

	// Растояние шага для корзинки
	dx = 15;
	dy = 15;

	file_n: array[1..fc] of string = ( 'img/apple.bmp', 'img/banana.bmp', 'img/orange.bmp', 'img/apple.bmp', 'img/banana.bmp', 'img/orange.bmp', 'img/apple.bmp', 'img/banana.bmp', 'img/orange.bmp' );
	type mas = array[1..fc] of integer;

var
		sizef: array[1..fc] of longint;
		pf: array[1..fc] of pointer;	// Указатель для фруктов

		menuItems: array[1..3] of string;

		gd, gm: smallint;
		ch: char;
		xb, yb: integer;	// Координаты для доски
		myFilePath: string;	// Путь к папке
		i :integer;
		pSize: longint;
		pb: pointer;
		xf, yf, dyf: mas;	// Координаты фруктов
		score: integer;	// Счет
		menuCursor: integer;	// Меню

function loader( fileName: string; var size: longint ): pointer;
var f: file; p: pointer;
begin

	assign( f, myFilePath + fileName);
	reset( f, 1 );
	size:= fileSize( f );
	getmem( p, size );
	blockread( f, p^, size );

	close( f );
	loader:= p;

end;

// Прцедура инициализации изображений
procedure initImage; begin

	myFilePath:= ExtractFilePath( paramstr(0) );
	pb:= loader( 'basket.bmp', pSize );
	for i:= 1 to fc do
		pf[i]:= loader( file_n[i], sizef[i] );

end;

// Входные данные
procedure initData; begin

	setTextStyle( boldFont, 0, 60 );

	score:= 0;

	xb:= getmaxx div 2;
	yb:= getmaxy - 50;

	for i:= 1 to fc do begin
		xf[i]:= random( getmaxX - 40 );
		yf[i]:= 0;
		dyf[i]:= 1 + random(6);
		putImage( xf[i], yf[i], pf[i]^, xorPut );
	end;

end;

// Отирисовка корзины
procedure basket( xb, yb: integer ); begin

	putImage( xb, yb, pb^, xorput );

end;

// Процедура движения корзины
procedure basketMove; begin

	ch:= readkey;

	if ch = #0 then begin

		basket( xb, yb );
		ch:= readkey;

		case ch of

			left: if xb > dx then begin
				xb:= xb - dx;
			end;

			right: if xb < getMaxX - 50 then begin
				xb:= xb + dx;
			end; 
		end;
		basket( xb, yb );
	end;

end;

// Процедура падения фруктов
procedure fall( var x, y, dy: integer; p: pointer ); begin

	putImage( x, y, p^, xorPut );
	y:= y + dy;

	if y >= GetMaxY then begin
		x:= Random( getMaxX - 40 );
		y:= 0;
		dy:= 1 + random(4);
	end;

	putImage( x, y, p^, xorPut );

end;

procedure check; begin

		for i:= 1 to fc do begin

			if ( (yf[i] + 40 >= yb + 29) and (yf[i] + 40 < yb + 50) )
				and ( (xf[i] >= xb) and (xf[i] < xb + 70) ) then begin
					inc( Score );
					putImage( xf[i], yf[i], pf[i]^, xorPut );
					yf[i]:= getMaxY;
			end;

		end;

end;

// Завершение игры
procedure gameOver; begin

	clearDevice;
	setTextStyle( BoldFont, 0, 60 );

	if score = 10 then
		outTextXY(getMaxX div 2, getMaxY div 2, 'You win');
		readkey;
		clearDevice;

end;



// Процедура игрового процесса
procedure game; begin

	initimage;
	initdata;
	basket( xb, yb );

	repeat

		delay(5);
		for i:= 1 to fc do
			fall( xf[i], yf[i], dyf[i], pf[i] );
		if keypressed then
			basketMove;

		check;
		outTextXY( 0, 0, 'Score: ' + intToStr(Score) );

	until (ch = esc) or (score = 3);



	clearDevice;
	if score = 3 then gameOver;
end;

procedure help; begin

outTextXY( 0, 0, 'You need to catch the fruits' );
outTextXY( 0, 25, 'Use Left and Right to move the basket' );
outTextXY( 0, 50, 'If you want to win, you need to catch the 10 fruits for 30 seconds' );

readkey;
clearDevice;

end;

procedure menu; begin

	menuItems[1]:= 'Play';
	menuItems[2]:= 'Help';
	menuItems[3]:= 'Exit';

	setTextStyle( boldFont, 0, 100 );
	setWriteMode( opaque );


	menuCursor:= 1;
	setColor( yellow );
	outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 1, menuItems[1] );

	setColor( white );

	for i:= 2 to 3 do begin
		outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * i, menuItems[i] );
	end;


	ch:= readkey;


	if ch = #0 then begin

		repeat

			ch:= readkey;

			case ch of
				up: if menuCursor > 1 then begin
							setColor( yellow );
							menuCursor:= menuCursor - 1;
						end;

				down: if menuCursor < 3 then begin
								setColor( yellow );
								menuCursor:= menuCursor + 1;
							end;
			end;

			if menuCursor = 1 then begin
				setColor( yellow );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * menuCursor, menuItems[menuCursor] );
				setColor( white );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 2, menuItems[2] );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 3, menuItems[3] );
			end;

			if menuCursor = 2 then begin
				setColor( yellow );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * menuCursor, menuItems[menuCursor] );
				setColor( white );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 1, menuItems[1] );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 3, menuItems[3] );
			end;

			if menuCursor = 3 then begin
				setColor( yellow );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * menuCursor, menuItems[menuCursor] );
				setColor( white );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 1, menuItems[1] );
				outTextXY( getMaxX div 2, (getMaxY div 2) + 15 * 2, menuItems[2] );
			end;

		until readkey = enter;
		clearDevice;
		if menuCursor = 1 then game;
		if menuCursor = 2 then help;
		if menuCursor = 3 then closeGraph;

	end;

end;



begin

	gd:= NoPalette;
	gm:= mFullScr;
	randomize;
	initGraph( gd, gm, '' );
	repeat
		menu;
	until (readkey = esc) or (menuCursor = 3);
	closeGraph;

end.