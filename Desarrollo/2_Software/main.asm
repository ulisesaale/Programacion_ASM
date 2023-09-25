;====================================================================
; Archivo Main.asm generado por el asistente de nuevo proyecto
;
; Creado:   mar. sep. 5 2023
; Procesador: PIC18F4550
; Compilador: MPASM (Proteus)
;====================================================================
;====================================================================
; DEFINICIONES
;====================================================================
#include "p18f4550.inc" ; Incluye el archivo de definición de registros
;====================================================================
; VARIABLES
;====================================================================
; Definición de constantes
LCD_RS  EQU 0x1B    ; Puerto para RS del LCD
LCD_E   EQU 0x1A    ; Puerto para E del LCD
LCD_D4  EQU 0x1D    ; Puerto para D4 del LCD
LCD_D5  EQU 0x1C    ; Puerto para D5 del LCD
LCD_D6  EQU 0x1F    ; Puerto para D6 del LCD
LCD_D7  EQU 0x1E    ; Puerto para D7 del LCD
BMP280_SDI EQU 0x33 ; Puerto para SDI del BMP280
BMP280_SDO EQU 0x34 ; Puerto para SDO del BMP280
BMP280_SCK EQU 0x35 ; Puerto para SCK del BMP280
BMP280_CSB EQU 0x36 ; Puerto para CSB del BMP280
DHT22_PIN  EQU 0x17  ; Puerto para el DHT22
; Zona de Datos
CBLOCK 0x20
    Temp_BMP280         ; Variable para la temperatura del BMP280
    Presion_BMP280     ; Variable para la presión del BMP280
    Humedad_DHT22      ; Variable para la humedad del DHT22
    Delay1             ; Variable para el retardo
    Delay2             ; Variable para el retardo
    Delay3             ; Variable para el retardo
ENDC
;====================================================================
; PROGRAMA PRINCIPAL
;====================================================================
ORG 0x00
GOTO Inicio
;====================================================================
; Rutinas para LCD LM016L, BMP280 y DHT22 (con datos simulados)
;====================================================================
; Rutina para inicializar el LCD LM016L
Inicio:
    ; Configurar pines del LCD como salida
    BCF STATUS, RP0       ; Cambiar al banco 0 de registros
    MOVLW 0x00            ; Puerto A como salida
    MOVWF TRISA
    MOVLW 0xF0            ; Puerto C como salida
    MOVWF TRISC
    BCF STATUS, RP0       ; Volver al banco 0 de registros
    ; Inicializar el LCD
    CALL EsperarMs         ; Esperar un tiempo para la inicialización
    MOVLW 0x03             ; Modo de 4 bits
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    CALL EsperarMs         ; Esperar un tiempo para la inicialización
    MOVLW 0x03             ; Modo de 4 bits
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    CALL EsperarMs         ; Esperar un tiempo para la inicialización
    MOVLW 0x03             ; Modo de 4 bits
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    MOVLW 0x02             ; Cambiar a modo de 8 bits
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    MOVLW 0x28             ; Configurar el LCD en 2 líneas, 5x8 caracteres
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    MOVLW 0x0C             ; Mostrar cursor, no parpadear
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    MOVLW 0x06             ; Desplazar cursor a la derecha
    CALL EnviarInstruccion ; Enviar instrucción al LCD
    MOVLW 0x01             ; Borrar pantalla
    CALL EnviarInstruccion ; Enviar instrucción al LCD
Loop:
    ; Leer datos del BMP280 y DHT22
    CALL LeerBMP280
    CALL LeerDHT22
    ; Mostrar datos en el LCD
    CALL MostrarDatosLCD
    GOTO Loop
; Rutina para enviar una instrucción al LCD
EnviarInstruccion:
    ; Configurar RS = 0 (Instrucción)
    BCF PORTA, LCD_RS
    ; Enviar el dato al LCD
    MOVWF PORTC
    ; Habilitar el LCD (E = 1)
    BSF PORTA, LCD_E
    ; Esperar un corto tiempo (puedes ajustarlo según tus necesidades)
    CALL EsperarUs
    ; Deshabilitar el LCD (E = 0)
    BCF PORTA, LCD_E
    ; Esperar un corto tiempo (puedes ajustarlo según tus necesidades)
    CALL EsperarUs
    RETURN
; Rutina para esperar un tiempo en microsegundos
EsperarUs:
    ; Inserta aquí tu código para generar un retraso de microsegundos
    RETURN
; Rutina para esperar un tiempo en milisegundos
EsperarMs:
    ; Inserta aquí tu código para generar un retraso de milisegundos
    RETURN
; Rutina para leer datos simulados del BMP280
LeerBMP280:
    ; Leer datos simulados del BMP280 y almacenarlos en Temp_BMP280 y Presion_BMP280
    ; Reemplaza esto con tus datos simulados
    MOVLW 25
    MOVWF Temp_BMP280
    MOVLW 1000
    MOVWF Presion_BMP280
    RETURN
; Rutina para leer datos simulados del DHT22
LeerDHT22:
    ; Leer datos simulados del DHT22 y almacenar la humedad en Humedad_DHT22
    ; Reemplaza esto con tus datos simulados
    MOVLW 60
    MOVWF Humedad_DHT22
    RETURN
; Rutina para mostrar datos en el LCD
MostrarDatosLCD:
    ; Mostrar datos en el LCD
    ; Posicionar cursor en la primera línea
    MOVLW 0x80
    CALL EnviarInstruccion
    ; Mostrar temperatura
    MOVLW 'T'
    CALL EnviarDato
    MOVLW 'e'
    CALL EnviarDato
    MOVLW 'm'
    CALL EnviarDato
    MOVLW 'p'
    CALL EnviarDato
    MOVLW ':'
    CALL EnviarDato
    ; Convertir el valor de temperatura a texto y mostrarlo
    CALL ConvertirTexto
    ; Posicionar cursor en la segunda línea
    MOVLW 0xC0
    CALL EnviarInstruccion
    ; Mostrar humedad
    MOVLW 'H'
    CALL EnviarDato
    MOVLW 'u'
    CALL EnviarDato
    MOVLW 'm'
    CALL EnviarDato
    MOVLW ':'
    CALL EnviarDato
    ; Convertir el valor de humedad a texto y mostrarlo
    CALL ConvertirTexto
    RETURN
; Rutina para enviar un dato al LCD
EnviarDato:
    ; Configurar RS = 1 (Dato)
    BSF PORTA, LCD_RS
    ; Enviar el dato al LCD
    MOVWF PORTC
    ; Habilitar el LCD (E = 1)
    BSF PORTA, LCD_E
    ; Esperar un corto tiempo (puedes ajustarlo según tus necesidades)
    CALL EsperarUs
    ; Deshabilitar el LCD (E = 0)
    BCF PORTA, LCD_E
    ; Esperar un corto tiempo (puedes ajustarlo según tus necesidades)
    CALL EsperarUs
    RETURN
; Rutina para convertir un valor numérico a texto y mostrarlo en el LCD
ConvertirTexto:
    ; Inserta aquí tu código para convertir el valor numérico a texto
    RETURN
; Otras rutinas y subrutinas necesarias
END