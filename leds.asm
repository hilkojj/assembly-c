
; ATmega 328p (Arduino UNO)

.org 0

.def temp = r16
.def output = r17

rjmp init

.org OC1Aaddr
rjmp TIMER1_COMP_ISR ; adres ISR (Timer1 Output Compare Match)

init:
	ldi output, 0b01
	ldi temp, 0xff
	out DDRD, temp	; set PORTD as output

	; init stack pointer
	ldi r16, high(RAMEND)
	out SPH, r16
	ldi r16, low(RAMEND)
	out SPL, r16

	; init Output Compare Register
	; 0.5 sec = (256/16.000.000) * 31250
	ldi temp, high(31250)
	sts OCR1AH, temp
	ldi temp, low(31250)
	sts OCR1AL, temp

	; prescaler: 256  timer mode: CTC
	ldi temp, (1 << CS12) | (1 << WGM12)
	sts TCCR1B, temp

	; enable interrupt
	ldi temp, (1 << OCIE1A)
	sts TIMSK1, temp

	sei ; enable all interrupts

loop: rjmp loop

TIMER1_COMP_ISR:
	lsl output
	ldi temp, 0
	cpse output, temp
	rjmp setOutput

	ldi output, 0b01

	setOutput:
	out PORTD, output
	reti
