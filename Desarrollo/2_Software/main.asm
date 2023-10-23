;====================================================================
; Main.asm file for PIC16F84A with 4-digit 7-segment display
;
; Created:   lun. sep. 25 2023
; Processor: PIC16F84A
; Compiler:  MPASM (Proteus)
; Autor: Ulises Ale
;====================================================================

;====================================================================
; DEFINITIONS
;====================================================================

LIST P=PIC16F84A			; Pic a usar
#INCLUDE <P16F84A.INC>			; Lista de etiquetas de microchip

		__CONFIG    _CP_OFF & _PWRTE_ON & _WDT_OFF & _XT_OSC   

;====================================================================
; Variables
;====================================================================		

FRAC_INI	equ	D'12'		; Constante para inicio cuenta de fracciones de segundo
SEGS_INI	equ	D'196'		; Constante para inicio cuenta de segundos
MINS_INI	equ	D'196'		; Constante para inicio cuenta de minutos
HORS_INI	equ	D'244'		; Constante para cuenta de horas
HORS_12H	equ	D'243'		; Constante para cuenta de horas

ADJMIN		equ	D'9'		; Número de "frac_sec" que se necesita sumar cada minuto
					; para ajustar el tiempo
ADJHOR		equ	D'34'		; Número de "frac_sec" que se necesita restar cada hora
					; para ajustar el tiempo
ADJDIA		equ	D'3'		; Número de "frac_sec" que se necesita sumar cada 12 horas
					; para ajustar el tiempo

; Activación de RB1-3 para las entradas de los pulsadores
PULSADOR	equ	B'00001110'	; RB1, RB2 y RB3

; Asignación de banderas. Los pulsadores activos proporcionan un "1"

CHG		equ	H'03'		; Indica que se ha activado un pulsador o que es necesario
					; actualizar los valores de la hora que tienen que mostrarse
					; en los displays
PSEG		equ	H'04'		; Pulsador A, modo segundero.
PMIN		equ	H'05'		; Pulsador B, avance rápido minutos.
PHOR		equ	H'06'		; Pulsador C, avance rápido horas.
P_ON		equ	H'07'		; Un pulsador ha sido activado

DSPOFF		equ	B'11111111'	; Displays apagados (PORTA)
					; gfedcbap
CERO		equ	H'7E'		; 01111110
UNO		equ	H'0C'		; 00001100
DOS		equ	H'B6'		; 10110110
TRES		equ	H'9E'		; 10011110
CUATRO		equ	H'CC'		; 11001100
CINCO		equ	H'DA'		; 11011010
SEIS		equ	H'FA'		; 11111010
SIETE		equ	H'0E'		; 00001110
OCHO		equ	H'FE'		; 11111110
NUEVE		equ	H'DE'		; 11011110
SEGM_OFF	equ	H'00'		; Todos los segmentos apagados. Separador entre horas
					; y minutos apagado (RB0).

frac_sec	equ	H'0C'		; Fracciones de segundo (1/244)
segundos	equ	H'0D'		; Segundos
minutos		equ	H'0E'		; Minutos
horas		equ	H'0F'		; Horas
conta1		equ	H'10'		; Variable 1 para bucle contador
;
display		equ	H'11'		; Indicador de display que debe actualizarse
digito1		equ	H'12'		; Display unidad de minuto / unidad de segundo
digito2		equ	H'13'		; Display decena de minuto / decena de segundo
digito3		equ	H'14'		; Display unidad de hora
digito4		equ	H'15'		; Display decena de hora
banderas	equ	H'16'		; Banderas; 3-CHG, 4-PSEG, 5-PMIN, 6-PHOR, 7-P_ON

;====================================================================
; Inicio
;====================================================================
	ORG	0x00			;Vector de Reset
	goto	INICIO
	org	0x05			;Salva el vector de interrupción

;**************************************************************
; SUBRUTINAS
;**************************************************************
CODIGO_7S				; Devuelve el código 7 segmentos
	addwf	PCL,F
	retlw	CERO
	retlw	UNO
	retlw	DOS
	retlw	TRES
	retlw	CUATRO
	retlw	CINCO
	retlw	SEIS
	retlw	SIETE
	retlw	OCHO
	retlw	NUEVE

;**************************************************************
; Comienzo del programa
;**************************************************************
INICIO
;  Configurar puertos como salidas, blanquear display
	bsf	STATUS,RP0		; Activa el banco de memoria 1.
	movlw	B'10000011'		; Configuración del registro Option, RB Pull Up desconectadas
	movwf	OPTION_REG		; TMR0 en modo temporizador (uso de pulsos de reloj internos, Fosc/4)
					; prescaler TMR0 a 1:16
	movlw	B'00000000'
	movwf	TRISA			; Pone todas las patillas del puerto A como salidas
	movwf	TRISB			; Pone todas las patillas del puerto B como salidas
	bcf	STATUS,RP0		; Activa el banco de memoria 0.

; Establecer estados iniciales de las salidas
	movlw	DSPOFF
	movwf	PORTA			; Apaga los displays
	movlw	B'00000001'		; Todos los segmentos apagados. Separador
	movwf	PORTB			; entre horas y minutos encendido (RB0).

; Inicialización de variables:
	movlw	H'01'
	movwf	TMR0			; Pone 01h en TMR0
	movlw	B'11111110'	
	movwf	display			; Inicia display seleccionando decena de hora
	movlw	CERO
	movwf	digito1			; Aparecerá un "0" en el display unidad de minutos
	movwf	digito2			; Aparecerá un "0" en el display decena de minutos
	movlw	DOS
	movwf	digito3			; Aparecerá un "2" en el display unidad de hora
	movlw	UNO
	movwf	digito4			; Aparecerá un "1" en el display decena de hora
	movlw	B'00000000'
	movwf	banderas		; Coloca todas las banderas a 0

; Inicia las variables de tiempo
	movlw	FRAC_INI
	movwf	frac_sec		; 12
	movlw	SEGS_INI
	movwf	segundos		; 196
	movlw	MINS_INI
	movwf	minutos			; 196
	movlw	D'255'
	movwf	horas			; Las horas comienzan con 12 por lo que "horas" ha de ser 255

;**************************************************************
; Rutina principal cíclica
;**************************************************************
PRINCIPAL
;  Esperar al desbordamiento de TMR0
TMR0_LLENO
;	4 MHz -> 1 MHz
;   1.000.000 Hz / 16 = 62.500 Hz
;   62.500 Hz / 256 = 244,140625 Hz -> 4,096 ms
	movf	TMR0,W
	btfss	STATUS,Z		; TMR0 cuenta libremente para no perder ciclos del reloj
					; escribiendo valores
	goto	TMR0_LLENO

; Se ha desbordado TMR0 y se han contado 256.
; Tarda en desbordarse 4.096 ciclos de reloj, 4,096 ms
	incfsz	frac_sec,F		; Se añade 1 a frac_sec
	goto	COMPROBAR_CHG		; Se comprueba el estado de “CHG” por si se ha activado
					; algún pulsador o es necesario actualizar los valores
					; de la hora que tienen que mostrarse en los displays

; Se ha desbordado frac_sec y se han contado 244 "frac_sec", 1 segundo.
; Tarda en desbordarse 4.096 ciclos de reloj, 4,096 ms * 244 = 999,424 ms
; Al no consegirse exactamente 1 segundo sino 0,999424 s, luego se necesitan ajustes
	bsf	PORTB,0			; Se activa separador horas-minutos
	movlw	FRAC_INI
	movwf	frac_sec		; Restaura la variable frac_sec para la próxima vuelta

COMPROBAR_PUL				; Comprueba variables pulsadores
	btfss	banderas,P_ON		; Si no se ha pulsado nada, se pasa a INC_HORA
	goto	INC_HORA		; Incrementa segundos, minutos y horas. Ajustes y “CHG” a 1
	btfsc	banderas,PSEG		; Comprobar si se ha pulsado PSEG (Pulsador segundos)
	goto	INC_HORA		; Se ha pulsado PSEG, (Pul A) y se mostrarán
					; los segundos en el display

PONER_RELOJ
	movlw	SEGS_INI		; 196d
	movwf	segundos		; Inicia los segundos cuando se pone el reloj en hora

PONER_MINUTOS
	btfss	banderas,PMIN		; Comprobar si se ha pulsado PMIN (Pulsador minutos)
	goto	PONER_HORAS		; No se ha pulsado PMIN, ir a comprobar estado de PHOR
	movlw	H'AF'			; 175d
	movwf	frac_sec	    	; Avance rápido del tiempo cuando se ajustan minutos frac_sec = 175
	incfsz	minutos,F		; Incrementar los minutos
	goto	PONER_HORAS
	movlw	MINS_INI
	movwf	minutos			; Iniciar minutos si al incrementar se han desbordado

PONER_HORAS
	btfss	banderas,PHOR		; Comprobar si se ha pulsado PHOR (Pulsador horas)
	goto	OBTENER_H_M		; No se ha pulsado PHOR, no se cambian las horas
	movlw	H'7F'			; 127d
	movwf	frac_sec		; Avance rápido del tiempo cuando se ajustan horas frac_sec = 127
	incfsz	horas,F			; Incrementar la hora
	goto	OBTENER_H_M
	movlw	HORS_INI
	movwf	horas			; Iniciar la hora si al incrementar se han desbordado
	goto	OBTENER_H_M 		

INC_HORA				; Incrementar segundos, minutos y horas
					; Ajustes cada minuto, hora y 12 horas
	bsf	banderas,CHG		; Se especifica que se ha producido un cambio

	incfsz	segundos,F 		; Como ha pasado un segundo se incrementa "segundos"
	goto	COMPROBAR_CHG
	movlw	SEGS_INI   		; Se ha desbordado "segundos" y se reestablece el valor inicial
	movwf	segundos		; de "segundos" para la próxima vuelta

	movlw	ADJMIN			; Se resta 9 a "frac_sec" cada minuto para los ajustes de tiempo
	subwf	frac_sec,F 		; El minuto será 9 "frac_sec" más largo

	incfsz	minutos,F  		; Se añade 1 minuto
	goto	COMPROBAR_CHG
	movlw	MINS_INI		; Se ha desbordado "minutos" y Se reestablece el valor inicial
	movwf	minutos	  		; de "minutos" para la próxima vuelta

	movlw	ADJHOR			; Se suma 34 a "frac_sec" cada hora para los ajustes de tiempo
	addwf	frac_sec,F		; La hora será 34 "frac_sec" más corta

	incfsz	horas,F	  		; Se añade 1 hora
	goto	COMPROBAR_CHG
	movlw	HORS_INI		; Se ha desbordado "horas" y se reestablece el valor inicial
	movwf	horas	  		; de "horas" para la próxima vuelta
	movlw	ADJDIA			; Se resta 3 a "frac_sec" cada 12 horas para los ajustes de tiempo
	subwf	frac_sec,F 		; Cada 12 horas se añadirán 3 "frac_sec"

; Se comprueba el estado de “CHG” por si se ha activado
; algún pulsador o es necesario actualizar los valores
; de la hora que tienen que mostrarse en los displays
; Se actualiza hora, displays y pulsadores cada 4,096 ms (244 veces por segundo)
COMPROBAR_CHG 	
	btfss	banderas,CHG		; Si no se han activado pulsadores ni ha cambiado la hora
 	goto	DISPLAY_PUL		; se salta a DISPLAY_PUL, que principalmente refresca uno de los
					; displays cada vez que se accede a ella y escanea pulsadores.

COMPROBAR_SEG				;  Se comprueba si se activo el pulsador de segundos (Pul A)
					; para mostrar los segundos en el display
	btfss	banderas,PSEG
	goto	OBTENER_H_M		; No estaba pulsado PSEG
	movlw	H'00'			; Se mostrarán los segundos en el display de minutos
	movwf	digito2			; Variables "digito2" a 0
	movwf	digito3			; Variables "digito3" a 0
	movwf	digito4			; Variables "digito4" a 0
	movlw	SEGS_INI
	subwf	segundos,W
	movwf	digito1			; Se guarda temporalmente el número de segundos en “digito1”
	goto	DIV_DIGITOS		

OBTENER_H_M
	movlw	HORS_12H
	subwf	horas,W
	movwf	digito3			; La variable digito3 almacena temporalmente el valor para las horas
	movlw	MINS_INI
	subwf	minutos,W
	movwf	digito1			; La variable digito1 almacena temporalmente el valor para los minutos

DIV_DIGITOS				; Divide los segundos o los minutos y las horas en dígitos independientes
					; ejemplo, [14] lo pasa a [1]-[4]
	movlw	H'00'
	movwf	digito4			; Se ponen a cero las posiciones de las decenas
	movwf	digito2			; para el caso de que no se incrementen
	movlw	H'02'
	movwf	conta1			; Bucle para convertir cada número (segundos o minutos y horas)
	movlw	digito1			; Dirección de digito1 en FSR para usar INDF
	movwf	FSR			; La primera vez, FSR = digito1 (minutos o segundos) y la segunda vez FSR = digito3 (horas)
	goto	LOOP		

LOOP2	; Este LOOP se utiliza para las horas después de trabajar con los minutos o los segundos
	movlw	digito3
	movwf	FSR			

LOOP	; Este LOOP se utiliza primero para los minutos o los segundos y después para las horas
	movlw	D'10'			; Averiguar cuantas "decenas" hay en el número
	subwf	INDF,F			; En cada LOOP restar 10 al número
	btfsc	STATUS,C        	; Se comprueba "C", que se pone a 1 si en la resta no se ha
					; producido llevada
	goto	INC_DECENAS   		; C = 1 por lo que se añade 1 a la posición de las decenas
	addwf	INDF,F			; C = 0, no se incrementan las decenas y se suma 10 para restaurar
					; las unidades
	goto	PROX_NUM

INC_DECENAS
	incf	FSR,F			; El puntero apunta a la primera posición de las decenas
	incf	INDF,F			; Se añade 1 a las decenas
	decf	FSR,F	  		; Se restaura el valor de INDF para apuntar al número
	goto    LOOP			; para la próxima resta hasta que se termine
					; Con "goto LOOP" se vuelve a comprobar si es necesario
					; sumar uno a la decena cada vez que esta se ha incrementado

PROX_NUM				; Próximo número, primero ha sido segundos o minutos y luego horas
	decfsz	conta1,F
	goto	LOOP2

CONVER_COD_7S				; Convierte cada dígito a código 7 segmentos para los displays
	movlw	digito1	
	movwf	FSR			; Coloca la dirección del primer digito (digito1) en FSR
	movlw	H'04'
	movwf	conta1			; Prepara la variable conta1 para el bucle de los 4 displays

PROX_DIGITO
	movf	INDF,W			; Obtener el valor de la variable "digito" actual
	call	CODIGO_7S		; LLamar a la rutina de conversión a código 7 segmentos
	movwf	INDF			; Colocar en la variable "digito" el código 7 segmentos devuelto
	incf	FSR,F			; Incremente INDF para el próximo "digito"
	decfsz	conta1,F		; Permitir que conta1 de sólo 4 vueltas
	goto	PROX_DIGITO


BORRAR_CERO_SEG
	btfss	banderas,PSEG		; Si está pulsado PSEG no se muestra nada en el display de la
	goto	DISPLAY_PUL		; posición de la unidad de hora.
	movlw	SEGM_OFF		; Contando con BORRAR_CERO, esto significa que sólo se
	movwf	digito3			; mostrarán los segundos.
	movwf	digito4

DISPLAY_PUL				; Se borran los bits de flag para actualizar su estado
					; Escanea pulsadores, si alguno está pulsado se pone a 1
					; el pulsador que le correspoda así como "P_ON" y "CHG"
					; Muestra los dígitos correspondientes a los segundos o a
					; los minutos y horas en el display que corresponda.

	movlw	B'00000000'
	movwf	banderas		; Se borran los bits de flag para actualizar su estado

	; Apagar los displays
	movlw	DSPOFF
	movwf	PORTA		

	; Apagar los segmentos respetando separador horas-minutos
	movlw	SEGM_OFF		; Respeta valor RB0
	xorwf	PORTB, w
	andlw	B'11111110'		;  Poner "1" el la posición del bit a copiar
	xorwf	PORTB, f

	; Configurar los bits 1, 2 y 3 de PORTB como entrada
	bsf	STATUS,RP0		; Activa el banco 1.
	movlw	PULSADOR
	movwf	TRISB			; Se configuran los bits 1, 2 y 3 de PORTB como entrada
	bcf	STATUS,RP0		; Activa el banco 0.
	nop				; Las instrucciones "nop" pueden no ser necesarias.
	nop				; En principio proporcionan el tiempo suficiente para que los
	nop				; estados anteriores de las salidas se actualicen a través de
	nop				; las resistencias de 10K (y de las de 820 ohm si está activado
	nop				; algún pulsador) antes de leer las patillas del puerto.

COMPROBAR_PSEG	; Se comprueba Pulsador PSEG
	btfss	PORTB,1
	goto	COMPROBAR_PMIN
	bsf	banderas,CHG
	bsf	banderas,PSEG
	bsf	banderas,P_ON

COMPROBAR_PMIN	; Se comprueba Pulsador PMIN
	btfss	PORTB,2
	goto	COMPROBAR_PHOR
	bsf	banderas,CHG
	bsf	banderas,PMIN
	bsf	banderas,P_ON

COMPROBAR_PHOR	; Se comprueba Pulsador PHOR
	btfss	PORTB,3
	goto	ACTIVAR_SEGM
	bsf	banderas,CHG
	bsf	banderas,PHOR
	bsf	banderas,P_ON

ACTIVAR_SEGM	; Se coloca en PORTB el valor para los segmentos del display actual
	bsf	STATUS,RP0		; Activa el banco 1.
	movlw	H'00'
	movwf	TRISB			; Puerto B como salida
	bcf	STATUS,RP0		; Activa el banco 0.

	; Se determina que display debe actualizarse, es decir, que dato debe
	; presentarse en el puerto B y se establece el siguiente display
	btfss	display,0		; Si es el primer display (decena de hora) tomar digito4
	movf	digito4,W
	btfss	display,1		; Si es el segundo display (unidad de hora) tomar valor digito3
	movf	digito3,W
	btfss	display,2		; Si es el tercer display (decena de min/seg) tomar valor digito2
	movf	digito2,W
	btfss	display,3		; Si es el cuarto display (unidad de min/seg) tomar valor digito1
	movf	digito1,W

	; Entregar el valor en puerto B y respetar valor RB0
	xorwf	PORTB, w
	andlw	B'11111110'		;  Poner "1" el la posición del bit a copiar
	xorwf	PORTB, f

	btfsc	frac_sec,7		; Establecer el separador de horas y minutos a un 50%
	bcf	PORTB,0			; del ciclo (1/2 segundo encendido, 1/2 segundo apagado)

	movf	display,W		; Tomar el valor del display que debe habilitarse
	movwf	PORTA			; Cada display se “enciende” con una cadencia de 244 Hz / 4 = 61 Hz  
	; Cada display se “enciende” con una cadencia de 244 Hz / 4 = 61 Hz  
	; En este momento están encendidos los segmentos correspondientes

	rlf	display,F		; Rota display 1 bit a la próxima posición
	bsf	display,0		; Asegura un 1 en la posición más baja de display (luego se hará 0 si es necesario)
	btfss	display,4		; Comprueba si el último display fue actualizado
	bcf	display,0		; Si lo fue, se vuelve a habilitar el primer display
					; La variable display va cambiando:
					;	1111 1101
					;	1111 1011
					;	1111 0111
					;	1110 1110
					;	1101 1101
					;	1011 1011
					;	0111 0111
					;	1110 1110
					; Sólo valen los 4 bits menos significativos

	goto    PRINCIPAL		; Volver a realizar todo el proceso

    END