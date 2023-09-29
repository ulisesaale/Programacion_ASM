;*********************************************************************************
;							**
;** --------------------------------------------------------------------------- **
;** DESCRIPCIÓN													**
;** Pone digitos de 0-9 en display 7-segmentos de 4_digitos, en el digito 4	**
;**   el MOD_7S_4D_L (2009-05-06) conecta al PORTD segmentos y al PORTE digitos **
;*********************************************************************************

    list        p=16f877a   		; directiva para definir procesador
    #include    <p16f877a.inc>  	; definiciones de variables especificas del procesador
    
    __CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_ON & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

     cblock 0x20	;separa epacio para 20 registros, 
				; define 3 registros para retardo
delay1              ; retardo 1
delay2              ; retardo 2
delay3			; retardo 3
contador			; contador de digito
     endc

#define	_kte_delay3	h'13'
#define	_kte_delay2	h'13'
#define	_kte_delay1	h'13'	

     org 0
Start:
	clrf		PORTB		; apaga PUERTO D segmentos
	clrf		PORTC		; apaga PUERTO E digitos

	bsf    	STATUS,RP0     ; selecciona Banco 1
	clrf		TRISB		; configura PUERTO D, salidas	
	clrf		TRISC		; configura PUERTO E, salidas	
	bcf    	STATUS,RP0     ; selecciona Banco 0

	bsf		PORTC,2		; prende Digito 4

	clrf		contador		; borre contador
Main:
	movf		contador,W		; cargue contador a W 
	call		Tabla_code_7_seg	; llame a Tabla codigo de 7 segmentos
	movwf	PORTB			; pongalo en PUERTO D
	
	movlw	_kte_delay3	; carga valor a 
	movwf	delay3		; Retardo 3 de ALTO nivel
	
	movlw	_kte_delay2	; carga valor a 
	movwf	delay2		; Retardo 2 de ALTO nivel
	
	movlw	_kte_delay1	; carga valor a 
	movwf	delay1		; Retardo 1 de ALTO nivel

Loop:
	decfsz  	delay1,f       ; decremente Retardo de BAJO nivel  
	goto    	Loop    		; hay 3 ciclos por loop * 256 loopss = 768 instrucciones
	decfsz  	delay2,f       ; decremente Retardo de MEDIO nivel  
	goto    	Loop    		; hay por loop (768 + 3) * 256 cilcos = 197.376 ciclos
	decfsz  	delay3,f       ; decremente Retardo de ALTO nivel
	goto    	Loop    		; hay por loop (197.376 + 3) * 31 cilcos = 6.118.749 ciclos        

	incf		contador		; sigueinte numero
	movlw	.10			; cargue 10
	xorwf	contador,W	; compara contador con 10
	btfsc	STATUS,Z		; comparación NO es igual a 10
	clrf		contador		; contador a 0

	goto    	Main       	; haga ciclo

Tabla_code_7_seg 			; Tabla para display de 7 segmentos.
	addwf 	PCL,F

	retlw 3Fh 	; numero "0".
	retlw 06h 	; numero "1".
	retlw 5Bh 	; numero "2".
	retlw 4Fh 	; numero "3".
	retlw 66h 	; numero "4".
	retlw 6Dh 	; numero "5".
	retlw 7Dh 	; numero "6".
	retlw 07h 	; numero "7".
	retlw 7Fh 	; numero "8".
	retlw 67h 	; numero "9".
    
	end