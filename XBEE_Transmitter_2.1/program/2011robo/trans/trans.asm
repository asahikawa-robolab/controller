
;****************** ���@�̌��t(ATmega168p) ******************

.include "m1284pdef.inc"

;.def	STACK	=	R16
.def	RWREG	=	R17
.def	SDATA	=	R18


;.EQU ENAME	=	0
.EQU	STA_C	=	0
.EQU	STA_Z	=	1
.EQU	STA_N	=	2
.EQU	STA_V	=	3
.EQU	STA_X	=	4
.EQU	STA_H	=	5
.EQU	STA_T	=	6
.EQU	STA_I	=	7

;.dseg	data:	.BYTE	10
;.dseg
;	dSDATA:	.BYTE	7

.CSEG
	RJMP	INIT
.ORG	0x001A
	RJMP	TIM1_OVF

INIT:
	
	CLI	
	
	LDI		RWREG	,0B00000000
	OUT		DDRA	,RWREG
	LDI		RWREG	,0B11110000
	OUT		DDRB	,RWREG
	LDI		RWREG	,0B00000000
	OUT		DDRC	,RWREG
	LDI		RWREG	,0B11000011
	OUT		DDRD	,RWREG
	LDI		RWREG	,0B00000000
	OUT		PORTA	,RWREG
	LDI		RWREG	,0B00000000
	OUT		PORTB	,RWREG
	LDI		RWREG	,0B00000000
	OUT		PORTC	,RWREG
	LDI		RWREG	,0B00000000
	OUT		PORTD	,RWREG

;******** USART�ݒ� ********
	LDI 	RWREG	,64
	STS		UBRR0L	,RWREG
	LDI		RWREG	,0
	STS		UBRR0H	,RWREG

	LDS		RWREG	,UCSR0C
	SBR		RWREG	,((1<<UCSZ01)|(1<<UCSZ00))
	STS		UCSR0C	,RWREG

	LDS		RWREG	,UCSR0B
	SBR		RWREG	,(1<<TXEN0)
	STS		UCSR0B	,RWREG

;******** A/D�ݒ� ********
	LDI		RWREG	,0B01100000
	STS		ADMUX	,RWREG
	LDI		RWREG	,((1<<ADEN)|(1<<ADIF)|0B100)
	STS		ADCSRA	,RWREG
	LDI		RWREG	,0B00000000
	STS		ADCSRB	,RWREG

;********�^�C�}�ݒ�********
	;----A0_B0:�m�[�}�� A0_B8:CTC(��r)----
	LDI		RWREG	,0x00
	STS		TCCR1A	,RWREG
	;----�v���X�P�[��----
	LDI		RWREG	,0x09
	STS		TCCR1B	,RWREG
	;----�����l----
	;10M 50ms -> 20000 = 4E20
	;//FFFF - 4E20 = B1DF
	LDI		RWREG	,0x4E
	STS		OCR1AH	,RWREG
	LDI		RWREG	,0x20
	STS		OCR1AL	,RWREG
	;----�^�C�}���荞�݋���----
	LDS		RWREG	,TIMSK1
	SBR		RWREG	,(1<<OCIE1A) ;(1<<TOIE1)
	STS		TIMSK1	,RWREG

	;----�S���荞�݋���----
	SEI
	
	RJMP	MAIN

;********************* ���@�̌��t����� *********************

SENDDATA:
	LDS		RWREG	,UCSR0A
	SBRS	RWREG	,UDRE0
	RJMP	SENDDATA
	STS		UDR0	,SDATA
	
	RET

TIM1_OVF:
;	IN		STACK	,SREG

;	LDI		RWREG	,0x00
;	STS		TCNT1H	,RWREG
;	STS		TCNT1L	,RWREG

;Byte0
	IN		R2		,PINC
;	SWAP	R2
;Byte1
	IN		R3		,PIND
	LSL		R3
	LSL		R3
	LDI		RWREG	,0xF0
	AND		R3		,RWREG
	IN		RWREG	,PINB
	ANDI	RWREG	,0x0F
	OR		R3		,RWREG
	SWAP	R3
	MOV		RWREG	,R3
	LSL		RWREG
	LSL		RWREG
	ANDI	RWREG	,0B11001100
	PUSH	RWREG
	MOV		RWREG	,R3
	LSR		RWREG
	LSR		RWREG
	ANDI	RWREG	,0B00110011
	MOV		R3		,RWREG
	POP		RWREG
	OR		R3		,RWREG
;Byte2
	LDI		RWREG	,(0B01100000 | 5)
	STS		ADMUX	,RWREG
	LDS		RWREG	,ADCSRA
	SBR		RWREG	,(1<<ADSC)
	STS		ADCSRA	,RWREG
AD0:
	LDS		RWREG	,ADCSRA
	SBRC	RWREG	,ADSC
	RJMP	AD0
	LDS		R4		,ADCH
;Byte3
	LDI		RWREG	,(0B01100000 | 6)
	STS		ADMUX	,RWREG
	LDS		RWREG	,ADCSRA
	SBR		RWREG	,(1<<ADSC)
	STS		ADCSRA	,RWREG
AD1:
	LDS		RWREG	,ADCSRA
	SBRC	RWREG	,ADSC
	RJMP	AD1
	LDS		R5		,ADCH
;Byte4
	LDI		RWREG	,(0B01100000 | 0)
	STS		ADMUX	,RWREG
	LDS		RWREG	,ADCSRA
	SBR		RWREG	,(1<<ADSC)
	STS		ADCSRA	,RWREG
AD5:
	LDS		RWREG	,ADCSRA
	SBRC	RWREG	,ADSC
	RJMP	AD5
	LDS		R6		,ADCH
;Byte5
	LDI		RWREG	,(0B01100000 | 1)
	STS		ADMUX	,RWREG
	LDS		RWREG	,ADCSRA
	SBR		RWREG	,(1<<ADSC)
	STS		ADCSRA	,RWREG
AD6:
	LDS		RWREG	,ADCSRA
	SBRC	RWREG	,ADSC
	RJMP	AD6
	LDS		R7		,ADCH
;Byte6
	CLR		R8
	IN		RWREG	,PINA
	BST		RWREG	,2
	BLD		R8		,2
	BST		RWREG	,7
	BLD		R8		,3
	LSL		RWREG
	SWAP	RWREG
	ANDI	RWREG	,0x03
	OR		R8		,RWREG

	;debug
	IN		RWREG	,PORTD
	SBR		RWREG	,0xc0
	OUT		PORTD	,RWREG

	IN		RWREG	,PORTD
	LSR		RWREG
	LSR		RWREG
	ANDI	RWREG	,0x30
	OR		R8		,RWREG

	MOV		RWREG	,R8
	LSL		RWREG
	ANDI	RWREG	,0B00101010
	PUSH	RWREG
	MOV		RWREG	,R8
	LSR		RWREG
	ANDI	RWREG	,0B00010101
	MOV		R8		,RWREG
	POP		RWREG
	OR		R8		,RWREG


	LDI		SDATA	,'S'
	RCALL	SENDDATA
	MOV		SDATA	,R2
	RCALL	SENDDATA
	MOV		SDATA	,R3
	RCALL	SENDDATA
	MOV		SDATA	,R4
	RCALL	SENDDATA
	MOV		SDATA	,R5
	RCALL	SENDDATA
	MOV		SDATA	,R6
	RCALL	SENDDATA
	MOV		SDATA	,R7
	RCALL	SENDDATA
	MOV		SDATA	,R8
	RCALL	SENDDATA
	LDI		SDATA	,'M'
	RCALL	SENDDATA
	MOV		SDATA	,R2
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R3
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R4
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R5
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R6
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R7
	COM		SDATA
	RCALL	SENDDATA
	MOV		SDATA	,R8
	COM		SDATA
	RCALL	SENDDATA
	LDI		SDATA	,'E'
	RCALL	SENDDATA

	RETI

MAIN:

	CLR		R2
	CLR		R3
	CLR		R4
	CLR		R5
	CLR		R6
	CLR		R7
	CLR		R8


MAIN1:
	RJMP	MAIN1
