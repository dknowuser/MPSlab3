$MOD52

;"Бегущий огонь" реализован на выводах порта P1
; Слева-направо, горят 4 СИД
; Время свечения 0,5 с
; Режим 16-битного таймера
; Разрешение счёта обеспечивается битом GATE регистра TMOD
; INT0 - P3.2

LSB_POSITION EQU 30h; Адрес ячейки в РПД, хранящей позицию младшего бита горящих СИД
CALL_COUNT EQU 31h; Адрес ячейки в РПД, хранящей число вызовов обработчика прерывания T/C0

CSEG
ORG 00h
	jmp initial_set_up; "Прыгаем" через таблицу векторов прерываний

ORG 0Bh
	jmp timer0_handle; "Прыгаем" на обработчик прерывания таймера/счётчика T/C0

; Код настройки таймера T/C0 и соотвествующего прерывания
initial_set_up:
	;Стек растёт вверх - указатель указывает на первый байт после программы
	mov SP, #stack

	;Установка 16-битного режима работы таймера T/C0
	mov TMOD, #01h	
	
	;Устанавливаем высокий приоритет прерывания таймера T/C0
	mov IP, #02h
	
	;Начальное значение таймера
	mov TL0, #0BFh
	mov TH0, #0BFh
	
	;Переключаемся на первый регистровый банк
	setb PSW.3
	
	mov R0, #LSB_POSITION; Позиция младшего бита горящей четвёрки СИД
	mov R1, #CALL_COUNT; Число вызовов подпрограммы обработки прерывания
	
	;Начальные значения нулевые
	mov @R0, #00h
	mov @R1, #00h
	
	;Переключаемся на нулевой регистровый банк
	clr PSW.3
	
	;Разрешение прерывания таймера T/C0
	mov IE, #82h
	
	;Запуск таймера T/C0
	mov TCON, #10h
	
	;Конец основной программы
lp:
	jmp lp

;Обработчик прерывания таймера T/C0	
timer0_handle:
	mov TCON, #00h; Запрещаем счёт
	
	;Сохраняем в стеке используемые регистры
	push ACC
	push PSW
	
	;Переключаемся на первый регистровый банк
	setb PSW.3

	;Перезагружаем значение таймера
	mov TL0, #0BFh
	mov TH0, #0BFh
	
	;Проверяем, сколько раз была вызвана подпрограмма
	mov A, @R1
	clr C
	subb A, #00h
	jz change
	inc @R1
	jmp handler_end

change:	
	mov @R1, #00h; Сбрасываем счётчик вызовов подпрограммы

	;Инкрементируем значение позиции младшего бита бегущего огня
	mov A, @R0
	clr C
	subb A, #07h
	jz loop_lsb_pos; Позиция младшего бита может лежать только в пределах от 0 до 7 
	inc @R0
	jmp switch
	
loop_lsb_pos:
	mov @R0, #00h
	
switch:
	;Ветвление в зависимости от позиции младшего бита бегущего огня	
	clr C
	mov A, @R0
	subb A,  #00h
	jz lsb_at_zero_pos
	
	clr C
	mov A, @R0
	subb A,  #01h
	jz lsb_at_first_pos
	
	clr C
	mov A, @R0
	subb A,  #02h
	jz lsb_at_second_pos
	
	clr C
	mov A, @R0
	subb A,  #03h
	jz lsb_at_third_pos
	
	clr C
	mov A, @R0
	subb A,  #04h
	jz lsb_at_fourth_pos
	
	clr C
	mov A, @R0
	subb A,  #05h
	jz lsb_at_fifth_pos
	
	clr C
	mov A, @R0
	subb A,  #06h
	jz lsb_at_sixth_pos
	
	clr C
	mov A, @R0
	subb A,  #07h
	jz lsb_at_seventh_pos	

	;В зависимости от полученного значения переключаем светодиоды
lsb_at_zero_pos:
	mov P1, #0Fh
	jmp handler_end
lsb_at_first_pos:
	mov P1, #87h
	jmp handler_end
lsb_at_second_pos:
	mov P1, #0C3h
	jmp handler_end
lsb_at_third_pos:
	mov P1, #0E1h
	jmp handler_end
lsb_at_fourth_pos:
	mov P1, #0F0h
	jmp handler_end
lsb_at_fifth_pos:
	mov P1, #78h
	jmp handler_end
lsb_at_sixth_pos:
	mov P1, #3Ch
	jmp handler_end
lsb_at_seventh_pos:
	mov P1, #1Eh
	
handler_end:
	;Переключаемся на нулевой регистровый банк
	clr PSW.3
	
	;Приводим аккумулятор и PSW в состояние до вызова
	pop PSW
	pop ACC
	
	mov TCON, #10h; Разрешаем счёт

	reti;Выход из обработчика прерывания
	
stack:

END