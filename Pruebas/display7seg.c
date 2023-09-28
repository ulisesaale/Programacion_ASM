void main()
{ 
Ticker = FRECUENCIA_TIMER1;                    //  Frecuencia _Timer1 tiene el valor de 1000000 se carga ticker con ese valor
setup_timer_1( T1_INTERNAL | T1_DIV_BY_1 );    // initializa TIMER1 para interrupción 
enable_interrupts( INT_TIMER1 );               // habilita LA interrupción (CUANDO LLEGA A SU VALOR MAXIMO 65536 ) TIMER1
enable_interrupts(GLOBAL); 
CVRCON=0;                   //DESABILITA EL COMPARADOR ANALOGICO PARA QUE EL PIN A2 SE PUEDA UTILIZAR COMO ENTRADA SALIDA DIGITAL.
CMCON=7;                    //APAGA LOS COMPARADORES PARA QUE LOS PINES RA3 Y RA4 SE PUEDAN UTILIZAR COMO ENTRADAS Y SALIDAS DIGITALES.
TRISA=0B00010000;           // todo el puerto A como salida expeto el PIN RA4 del pulsador
TRISB=0B10000000;           // todo el puerto B como salida exepto el PIN RB7 del pulsador


while(1)
{
//*****************************************************************************************************************************   
   if (input (pin_b7)==1)                    // PULSO 1 DE SETEO DE MINUTOS RELOJ
  { 
    output_b(0b01111111);
    delay_ms(200);                           // ANTIREBOTE
    while (true)                          
   {  
   showminuto();                     
   if (input (pin_a4)==1)           
            {
            delay_ms(200);
            minuto++;
            if(minuto > 59)
            minuto = 0;
            }
//*****************************************************************************************************************************
   if (input (pin_b7)==1)                    // PULSO 2 DE SETEO DE HORAS RELOJ
  { 
    output_b(0b01111111);
    delay_ms(200);                          // ANTIREBOTE
    while (true)                          
   {  
   showhora();                     
   if (input (pin_a4)==1)           
            {
            delay_ms(200);
            hora++;
            if(hora > 23)
            hora = 0;
            }
            
          if(input(pin_b7) == 1)             
            {
             delay_ms(200);                     
             goto salida;                       
            }          
//*****************************************************************************************************************************
   }}}
  }  
//************************************************* FIN DEL IF DE PULSACIONES *************************************************  
  
salida:
display();
}
}


//********************************************* FUNCIONES DEL PROGRAMA ********************************************************

//******************* LIMPIA ES USADO POR EL BOTON DE SETEADO *****************************
void limpia()                   
{
  output_b(0b01111111);
}
void numero(int dato)
{
   switch( (dato))   //   DECENAS
    {         
     case 0:PORTB=0x40;break;     // MUESTRA EL ARREGLO POR EL PUERTO B
     case 1:PORTB=0x79;break;    
     case 2:PORTB=0x24;break;      
     case 3:PORTB=0x30;break;       
     case 4:PORTB=0x19;break;      
     case 5:PORTB=0x12;break;
     case 6:PORTB=0x02;break;
     case 7:PORTB=0x78;break;
     case 8:PORTB=0x00;break;
     case 9:PORTB=0x10;break;
    }
    delay_us(500);               // RETARDO QUE PERMITE QUE SE VISUALICE EL NUMERO EN EL DISPLAY 
    limpia();                    // LIMPIA EL PUERTO B 
}

void clear ()
{
PORTB=0b01111111;                  // ARREGLO QUE APAGA EL CAJON DEL DISPLAY 
delay_us(500);               // espero para que se VEA (en este caso CAJON APAGADO)  
}

void display (void)
{
//*****************************************************************************************************************//
PORTA=0b00000001;
numero(minuto%10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00000010;
numero(minuto/10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00000100;
numero(hora%10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00001000;
numero(hora/10);
delay_us(500);
PORTA=0b00000000;
}

void showminuto()
{
//*****************************************************************************************************************//
PORTA=0b00000001;
numero(minuto%10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//   
PORTA=0b00000010;
numero(minuto/10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00000100;
PORTB=0b01111111;
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00001000;
PORTB=0b01111111;
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
}

void showhora()  
{
//*****************************************************************************************************************//
PORTA=0b00000001;
PORTB=0b01111111;
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//   
PORTA=0b00000010;
PORTB=0b01111111;
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00000100;
numero(hora%10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
PORTA=0b00001000;
numero(hora/10);
delay_us(500);
PORTA=0b00000000;
//*****************************************************************************************************************//
}