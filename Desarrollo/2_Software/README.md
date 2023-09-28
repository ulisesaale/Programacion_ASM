![logos](/Desarrollo/assets/ISPC_portada.png)

<<<<<<< HEAD
### **Se realiza la codificacion en Assembler para el funcionamiento de una Estacion Metereologica donde nos muestra Temperatura, Humedad y Presión atmosférica.**

### Para este proyecto se utiliza el PIC18F4550.

### Ventajas:

* **Capacidad de procesamiento:** El PIC18F4550 tiene un núcleo PIC de 8 bits,  tiene una capacidad de procesamiento más avanzada y mayor cantidad de memoria Flash y RAM disponible. Esto permite una mayor flexibilidad en la programación y el manejo de datos, lo que puede ser beneficioso cuando se trabaja con múltiples sensores y dispositivos de visualización.

* **Compatibilidad USB:** El PIC18F4550 es conocido por su capacidad USB incorporada, lo que significa que puedes utilizarlo para conectar el sistema a una computadora o dispositivo USB. Esto podría ser útil si deseas realizar una comunicación bidireccional con un ordenador para la configuración, la recopilación de datos o la visualización en tiempo real.

* **Periféricos adicionales:** El PIC18F4550 también tiene una variedad de periféricos adicionales, como convertidores analógico-digitales (ADC) de 10 bits y UART, que pueden ser útiles en aplicaciones que requieren una mayor funcionalidad y flexibilidad en la adquisición de datos y la comunicación.

* **Código más eficiente:** Dado que el PIC18F4550 tiene más recursos de memoria y una arquitectura de instrucción más avanzada, podrías ser capaz de escribir un código más eficiente y optimizado, lo que podría ser especialmente útil cuando se trabaja con varios sensores y dispositivos.

![pic](/Desarrollo/assets/PIC18F4550.jfif)
=======

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
>>>>>>> 21033b3e4368c1b718f996578aa99afb0d6c9ada
