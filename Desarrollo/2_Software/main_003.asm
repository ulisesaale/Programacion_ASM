;VISUALIZAR MENSAJE EN LCD CON PIC16F877A Y MEDIR BMP180 Y DHT22
;****************************************************************
PROCESSOR 16F877A
INCLUDE <P16F877A.INC>         ;LIBRERIA PIC16F877A

;CONFIGURACION DE BITS
__CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _CP_OFF  

; Definiciones para BMP180 y DHT22
BMP180_ADDR EQU 0xEE            ; Dirección I2C del BMP180 (depende de cómo esté configurado)
DHT22_PIN   EQU 2               ; Pin al que está conectado el DHT22

;CODIGO    
    ORG     0
    GOTO    INICIO
    ORG     5

; Variables globales
TEMP_LSB    EQU 0x0A            ; Variable para almacenar el valor LSB de la temperatura
TEMP_MSB    EQU 0x0B            ; Variable para almacenar el valor MSB de la temperatura
PRESS_LSB   EQU 0x0C            ; Variable para almacenar el valor LSB de la presión
PRESS_MSB   EQU 0x0D            ; Variable para almacenar el valor MSB de la presión
HUMIDITY    EQU 0x0E            ; Variable para almacenar la humedad del DHT22
TEMP_CEL    EQU 0x0F            ; Variable para almacenar la temperatura en grados Celsius

INICIO
    CLRF    PORTB
    CLRF    PORTD 		;LIMPIAR PORTB Y PORTD 
    BSF     STATUS,RP0
    BCF     STATUS,RP1
    CLRF    TRISB
    CLRF    TRISD  		;SELECIONAR PORTB Y PORTD COMO SALIDAS
    BCF     STATUS,RP0 

    ; Inicializar sensores BMP180 y DHT22 aquí (configurar I2C, etc.)

START
    CALL    LCD_Inicializa
    CALL    MEDIR_BMP180          ; Medir BMP180 y almacenar en TEMP_LSB, TEMP_MSB, PRESS_LSB y PRESS_MSB
    CALL    MEDIR_DHT22           ; Medir DHT22 y almacenar en HUMIDITY y TEMP_CEL
    CALL    MOSTRAR_DATOS         ; Mostrar los datos en el LCD
    GOTO    START

; Subrutina para medir BMP180
MEDIR_BMP180
    ; Código para leer datos del BMP180 y almacenarlos en TEMP_LSB, TEMP_MSB, PRESS_LSB y PRESS_MSB
    ; Utiliza I2C para comunicarse con el BMP180
    ; ...
    RETURN

; Subrutina para medir DHT22
MEDIR_DHT22
    ; Código para leer datos del DHT22 y almacenarlos en HUMIDITY y TEMP_CEL
    ; Utiliza el pin definido en DHT22_PIN para la comunicación
    ; ...
    RETURN

; Subrutina para mostrar datos en el LCD
MOSTRAR_DATOS
    ; Convierte los valores de TEMP_LSB, TEMP_MSB, PRESS_LSB, PRESS_MSB, HUMIDITY y TEMP_CEL a cadenas de caracteres
    ; Luego, muestra los datos en el LCD utilizando LCD_Envia
    ; ...
    RETURN

MENSAJE_2
    ; El código para mostrar mensajes en el LCD ya está en tu código original
    ; ...
    RETURN

INCLUDE<C:\Users\tecni\OneDrive\Documentos\Ulises\Carrera Tecnico en Telecomunicacion\EM\Proyecto Individual\LCD.INC>

    END
