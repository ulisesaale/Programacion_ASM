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
    
      PROCESSOR 16F84A 			;Definimos el micro que vamos a usar
      #INCLUDE <P16F84A.INC> 		;Se incluye el archivo de definiciones

      __CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _XT_OSC

;====================================================================
; Variables
;====================================================================
cblock 0x0C
    Hora
    DecenasHora
    UnidadesHora
    DecenasMinutos
    UnidadesMinutos
    DireccionDigito  			; Variable para controlar el dígito a mostrar (0-3)
    COUNT            			; Variable de contador para esperar aproximadamente 1 segundo
endc

;====================================================================
; Inicio
;====================================================================
    
    ORG 0x00
    GOTO Inicio

;====================================================================
; Rutina para mostrar un dígito en el display
;====================================================================
MostrarDigito:
    ; Tabla de segmentos para mostrar los números del 0 al 9 en display de 7 segmentos
    
    MOVF DireccionDigito, W   		; Cargar la dirección del dígito a mostrar
    ADDWF PCL, F             		; Saltar a la dirección correcta en la tabla
    RETLW 0xC0      			; número "0".
    RETLW 0xF9      			; número "1".
    RETLW 0xA4      			; número "2".
    RETLW 0xB0      			; número "3".
    RETLW 0x99      			; número "4".
    RETLW 0x92      			; número "5".
    RETLW 0x82      			; número "6".
    RETLW 0xF8      			; número "7".
    RETLW 0x80      			; número "8".
    RETLW 0x90      			; número "9".

;====================================================================
; Rutina para esperar aproximadamente 1 segundo
;====================================================================
Esperar1Segundo:
    MOVLW 	D'19'   		; Cargar un valor para aproximadamente 1 segundo
    MOVWF 	COUNT     		; Usar registro COUNT para contar

EsperarLoop:
    DECFSZ 	COUNT, F 		; Decrementar COUNT y saltar si es cero
    GOTO 	EsperarLoop 		; Repetir el bucle si COUNT no es cero
    RETURN

;====================================================================
; Rutina para incrementar los minutos y las horas
;====================================================================
IncrementarMinutos:
    MOVLW 	0x00      		; Cargar 0 en W (limpiar unidades de minutos)
    MOVWF 	UnidadesMinutos 	; Limpiar unidades de minutos
    MOVLW 	0x01      		; Cargar 1 en W (incremento)
    ADDWF 	DecenasMinutos, F 	; Incrementar decenas de minutos
    BTFSC 	STATUS, Z 	        ; Comprobar si Z se establece (llegó a 6, 60 minutos)
    GOTO 	IncrementarHoras 	; Saltar a IncrementarHoras si llegó a 60 minutos
    RETURN          			; Retornar si no es necesario cambiar horas

IncrementarHoras:
    MOVLW 	0x00      		; Cargar 0 en W (limpiar decenas de minutos)
    MOVWF 	DecenasMinutos 	        ; Limpiar decenas de minutos
    MOVLW 	0x01      		; Cargar 1 en W (incremento)
    ADDWF 	UnidadesHora, F	        ; Incrementar unidades de horas
    BTFSC 	STATUS, Z	        ; Comprobar si Z se establece (llegó a 10)
    MOVLW    	0x00	       	        ; Cargar cero en W si llegó a diez horas.
    MOVWF 	UnidadesHora 	        ; Limpiar unidades de horas.
    RETURN      		        ; Retornar.

;====================================================================
; Puertos
;====================================================================
Inicio:
    ; Configura los puertos
    BSF 	STATUS, RP0 		; Accede al banco de registros 1
    MOVLW 	b'00000000' 		; Configurar todos los pines de PORTB como salida
    MOVWF 	TRISA 			; Configurar el puerto B como salida
    CLRF 	TRISB			;Pongo este registro a 0 para configurarlo como salida
    BCF		STATUS, RP0		;Salgo del banco 1 
   

    ; Inicializa las variables
    MOVLW 	0x0000 			; Cargar 00:00 en W (HHMM)
    MOVWF 	Hora 			; Establecer la hora inicial en Hora (HHMM)
    MOVLW 	0x00   			; Inicializar la dirección del primer dígito
    MOVWF 	DireccionDigito

    CLRF 	Hora                   	; Inicializar variables.
    CLRF 	DecenasHora 
    CLRF 	UnidadesHora 
    CLRF 	DecenasMinutos 
    CLRF 	UnidadesMinutos 
    CLRF 	DireccionDigito 
    CLRF 	COUNT 

;====================================================================
; Principal
;====================================================================   
BuclePrincipal:
   CALL 	Esperar1Segundo           ; Incrementar los minutos cada segundo.
   CALL 	IncrementarMinutos 

   MOVLW 	0x00                     ; Mostrar las unidades de los minutos en el primer dígito
   MOVWF 	DireccionDigito 
   CALL 	MostrarDigito 
   MOVF 	UnidadesMinutos, W 
   MOVWF 	PORTB 

   MOVLW 	0x01                      ; Mostrar las decenas de los minutos en el segundo dígito
   MOVWF 	DireccionDigito 
   CALL 	MostrarDigito 
   MOVF 	DecenasMinutos, W 
   MOVWF 	PORTB 

   MOVLW 	0x02                      ; Mostrar las unidades de las horas en el tercer dígito
   MOVWF 	DireccionDigito 
   CALL 	MostrarDigito 
   MOVF 	UnidadesHora, W 
   MOVWF 	PORTB 

   MOVLW 	0x03                      ; Mostrar las decenas de las horas en el cuarto dígito
   MOVWF 	DireccionDigito 
   CALL 	MostrarDigito 
   MOVF 	DecenasHora, W 
   MOVWF 	PORTB 

   GOTO BuclePrincipal             	  ; Repetir el bucle principal indefinidamente.

END                              	  ; Fin del programa.
