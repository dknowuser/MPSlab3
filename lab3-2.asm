$MOD52

;Программа подсчёта внешних сигналов/событий
;Код числа сигналов выводится на порт P1 

;Адрес счётчика внешних сигналов в РПД
COUNTER EQU 30h

CSEG
ORG 00h
	jmp initial_set_up; "Прыгаем" через таблицу векторов прерываний
	
ORG 0Bh
	inc @R0
	mov P1, @R0	
	reti

initial_set_up:
	;Стек растёт вверх - указатель указывает на первый байт после программы
	mov SP, #stack

	;Установка 2 режима работы таймера T/C0 - счётчик
	mov TMOD, #06h	
	
	;Устанавливаем высокий приоритет прерывания
	mov IP, #01h
	
	;Начальное значение таймера
	mov TL0, #0F8h
	mov TH0, #0F8h
	
	mov R0, #COUNTER
	
	;Разрешение прерывания таймера T/C0
	mov IE, #82h
	
	;Запуск таймера T/C0
	;Генерация прерывания по срезу сигнала на INT0
	mov TCON, #11h

;Конец основной программы
lp:
	jmp lp
	
stack:


END