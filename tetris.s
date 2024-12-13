# Versión completa del tetris 
# Sincronizada con tetris.s:r3705
        
	.data	

pantalla:
	.word	0
	.word	0
	.space	1024

campo:
	.word	0
	.word	0
	.space	1024

pieza_actual:
	.word	0
	.word	0
	.space	1024
	
pieza_siguiente:
	.word	0
	.word	0
	.space	1024
	
puntos:
	.word	0
	
pieza_actual_x:
	.word 0

pieza_actual_y:
	.word 0

imagen_auxiliar:
	.word	0
	.word	0
	.space	1024

pieza_jota:
	.word	2
	.word	3
	.ascii	"\0#\0###\0\0"

pieza_ele:
	.word	2
	.word	3
	.ascii	"#\0#\0##\0\0"

pieza_barra:
	.word	1
	.word	4
	.ascii	"####\0\0\0\0"

pieza_zeta:
	.word	3
	.word	2
	.ascii	"##\0\0##\0\0"

pieza_ese:
	.word	3
	.word	2
	.ascii	"\0####\0\0\0"

pieza_cuadro:
	.word	2
	.word	2
	.ascii	"####\0\0\0\0"
	
pieza_te:
	.word	3
	.word	2
	.ascii		"\0#\0###\0\0"

piezas:
	.word	pieza_jota
	.word	pieza_ele
	.word	pieza_zeta
	.word	pieza_ese
	.word	pieza_barra
	.word	pieza_cuadro
	.word	pieza_te
	

imagen_fin_partida:
	.word 19
	.word 4
	.ascii		"+-----------------+"
	.ascii		"| FIN DE PARTIDA  |"
	.ascii		"| Pulse una tecla |"
	.ascii		"+-----------------+"
	
	
recuadro_pieza_siguiente:
	.word 8
	.word 8
	.ascii		"+------+"
	.ascii		"|      |"
	.ascii		"|      |"
	.ascii		"|      |"
	.ascii		"|      |"
	.ascii		"|      |"
	.ascii		"|      |"
	.ascii		"+------+"
	
pieza_siguiente_pantalla:
	.word 0
	.word 0
	.space 1024

acabar_partida:
	.byte	0
	.align	2
	
game_over:
	.byte	0				#variable que controla si no caben mas piezas
	.align	2
	
procesar_entrada.opciones:
	.byte	'x'
	.space	3
	.word	tecla_salir
	.byte	'j'
	.space	3
	.word	tecla_izquierda
	.byte	'l'
	.space	3
	.word	tecla_derecha
	.byte	'k'
	.space	3
	.word	tecla_abajo
	.byte	'i'
	.space	3
	.word	tecla_rotar
	.byte	't'
	.space	3
	.word	tecla_truco

str000:
	.asciiz		"Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n"
str001:
	.asciiz		"\n¡Adiós!\n"
str002:
	.asciiz		"\nOpción incorrecta. Pulse cualquier tecla para seguir.\n"
	.align 0
strpuntuacion:
	.asciiz		"Puntuación: "
strpuntos:
	.space	256	
	

	.text	

imagen_pixel_addr:			# ($a0, $a1, $a2) = (imagen, x, y)
					# pixel_addr = &data + y*ancho + x
    	lw	$t1, 0($a0)		# $a0 = dirección de la imagen 
					# $t1 ← ancho
    	mul	$t1, $t1, $a2		# $a2 * ancho
    	addu	$t1, $t1, $a1		# $a2 * ancho + $a1
    	addiu	$a0, $a0, 8		# $a0 ← dirección del array data
    	addu	$v0, $a0, $t1		# $v0 = $a0 + $a2 * ancho + $a1
    	jr	$ra

imagen_get_pixel:			# ($a0, $a1, $a2) = (img, x, y)
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)		# guardamos $ra porque haremos un jal
	jal	imagen_pixel_addr	# (img, x, y) ya en ($a0, $a1, $a2)
	lbu	$v0, 0($v0)		# lee el pixel a devolver
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

imagen_set_pixel:		
	# a0 = imagen
	# a1 = x
	# a2 = y
	# a3= color ( es un char por lo que ocupa un byte )
	addiu	$sp,$sp,-8
	sw	$ra,0($sp)
	sb	$a3,4($sp)
	jal	imagen_pixel_addr
	
	lb	$t1,4($sp) 		
	sb	$t1, 0($v0)		# *pixel = color
	lw	$ra,0($sp)
	addiu	$sp,$sp,8
	jr $ra

imagen_clean:
	# a0 = imagen
	# a1 = fondo ( es un char por lo que ocupa un byte )
	addiu	$sp,$sp,-20
	sw	$ra,0($sp)
	sw	$a0,16($sp)
	sb	$a1,12($sp)
	sw	$0,4($sp) # y=0
	sw	$0,8($sp) # x=0
for1_imagen_clean:
	lw	$t0,4($sp) # Sacamos la y
	lw	$t2,16($sp)
	lw	$t1,4($t2) # Sacamos img-> alto
	bge	$t0,$t1,fin_for1_imagen_clean
	
for2_imagen_clean:
	lw	$t0,8($sp) # Sacamos la x
	lw	$t2,16($sp)
	lw	$t1,0($t2) # Sacamos img-> ancho
	bge	$t0,$t1,fin_for2_imagen_clean
	lw	$a0,16($sp) # sacamos img
	lw	$a1,8($sp) # Sacamos la x
	lw	$a2,4($sp) # Sacamos la y
	lb	$a3,12($sp) # Sacamos el valor de fondo
	jal	imagen_set_pixel # a0 = imagen a1 = x a2 = y a3= fondo
	
	lw	$t0,8($sp) 
	addi	$t0,$t0,1 # x++
	sw	$t0,8($sp) 
	
	j for2_imagen_clean
	
fin_for2_imagen_clean:
	
	sw	$0,8($sp) # x=0
	lw	$t0,4($sp) 
	addi	$t0,$t0,1 # y++
	sw	$t0,4($sp) 
	j	for1_imagen_clean
	
fin_for1_imagen_clean:
	
	lw	$ra,($sp)
	addiu	$sp,$sp,20
	jr $ra
        
imagen_init:
	# a0 = imagen
	# a1 = ancho
	# a2 = alto
	# a3 =  valor de relleno ( un byte )
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	sw	$a1, 0($a0)
	sw	$a2, 4($a0)
	move	$a1, $a3
	jal	imagen_clean
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
imagen_copy:
	# a0 = imagen dst
	# a1 = imagen src
	addiu	$sp,$sp,-24
	sw	$ra,0($sp)
	lw	$t0, 0($a1)
	sw	$t0, 0($a0)
	lw	$t0, 4($a1)
	sw	$t0, 4($a0)
	sw	$a1,16($sp) # Guardamos en memoria $a1
	sw	$a0,20($sp) # Guardamos en memoria $a0
	sw	$0,4($sp) # y=0
	sw	$0,8($sp) # x=0
for1_imagen_copy:
	lw	$t0,4($sp) # Sacamos la y
	lw	$t2,16($sp)
	lw	$t1,4($t2) # Sacamos src -> alto
	bge	$t0,$t1,fin_for1_imagen_copy
	
for2_imagen_copy:
	lw	$t0,8($sp) 	# Sacamos la x
	lw	$t2,16($sp) 
	lw	$t1,0($t2)	# Sacamos src -> ancho
	bge	$t0,$t1,fin_for2_imagen_copy
	lw	$a0, 16($sp)
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	jal	imagen_get_pixel
	sb	$v0, 12($sp) # valor de p
	lw	$a0,20($sp) # sacamos dst
	lw	$a1,8($sp) # Sacamos la x
	lw	$a2,4($sp) # Sacamos la y
	lb	$a3,12($sp) # Sacamos el valor de p
	jal	imagen_set_pixel # a0 = imagen a1 = x a2 = y a3= p
	
	lw	$t0,8($sp) 
	addi	$t0,$t0,1 # x++
	sw	$t0,8($sp) 
	
	j for2_imagen_copy
	
fin_for2_imagen_copy:
	
	sw	$0,8($sp) # x=0
	lw	$t0,4($sp) 
	addi	$t0,$t0,1 # y++
	sw	$t0,4($sp) 
	j	for1_imagen_copy
	
fin_for1_imagen_copy:
	
	lw	$ra,($sp)
	addiu	$sp,$sp,24
	jr	$ra
	

imagen_print:				# $a0 = img
	addiu	$sp, $sp, -24
	sw	$ra, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a0
	lw	$s3, 4($s0)		# img->alto
	lw	$s4, 0($s0)		# img->ancho
        #  for (int y = 0; y < img->alto; ++y)
	li	$s1, 0			# y = 0
B6_2:	bgeu	$s1, $s3, B6_5		# acaba si y ≥ img->alto
	#    for (int x = 0; x < img->ancho; ++x)
	li	$s2, 0			# x = 0
B6_3:	bgeu	$s2, $s4, B6_4		# acaba si x ≥ img->ancho
	move	$a0, $s0		# Pixel p = imagen_get_pixel(img, x, y)
	move	$a1, $s2
	move	$a2, $s1
	jal	imagen_get_pixel
	move	$a0, $v0		# print_character(p)
	jal	print_character
	addiu	$s2, $s2, 1		# ++x
	j	B6_3
	#    } // for x
B6_4:	li	$a0, 10			# print_character('\n')
	jal	print_character
	addiu	$s1, $s1, 1		# ++y
	j	B6_2
	#  } // for y
B6_5:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$ra, 20($sp)
	addiu	$sp, $sp, 24
	jr	$ra

imagen_dibuja_imagen:
	# a0 = dst
	# a1 = src
	# a2 = dst_x
	# a3 = dst_y
	addiu	$sp,$sp,-32
	sw	$ra,0($sp)
	sw	$a0,4($sp) # dst
	sw	$a1,8($sp) # src
	sw	$a2,12($sp)
	sw	$a3,16($sp)
	sw	$0,20($sp) # x=0
	sw	$0,24($sp) # y=0
	
for1_imagen_dibuja_imagen:
	lw	$t0,24($sp) # Sacamos la y
	lw	$t2,8($sp)
	lw	$t1,4($t2) # Sacamos src -> alto
	bge	$t0,$t1,fin_for1_imagen_dibuja_imagen
for2_imagen_dibuja_imagen:
	lw	$t0,20($sp) # Sacamos la x
	lw	$t2,8($sp)
	lw	$t1,0($t2) # Sacamos src -> ancho
	bge	$t0,$t1,fin_for2_imagen_dibuja_imagen
	
	lw	$a0, 8($sp)
	lw	$a1, 20($sp)
	lw	$a2, 24($sp)
	jal	imagen_get_pixel
	move	$t0,$v0
	sb	$t0,28($sp) # p inicializado
	beq	$t0,$0,fin_if_imagen_dibuja_imagen #if (p != PIXEL_VACIO)
	lw	$a0, 4($sp) # dst
	lw	$a1, 12($sp) # Sacamos dst_x
	lw	$t0,20($sp) # Sacamos la x
	add	$a1,$a1,$t0 # dst_x + x
	lw	$a2, 16($sp) # Sacamos dst_y
	lw	$t0, 24($sp) # Sacamos la y
	add	$a2,$a2,$t0 # dst_y + y
	lb	$a3,28($sp) # p
	jal	imagen_set_pixel
	
fin_if_imagen_dibuja_imagen:
	
	lw	$t0,20($sp) 
	addi	$t0,$t0,1 # x++
	sw	$t0,20($sp)
	j	for2_imagen_dibuja_imagen

fin_for2_imagen_dibuja_imagen:
	
	sw	$0,20($sp) # x=0
	lw	$t0,24($sp) 
	addi	$t0,$t0,1 # y++
	sw	$t0,24($sp)
	j	for1_imagen_dibuja_imagen
fin_for1_imagen_dibuja_imagen:
	lw	$ra,0($sp)
	addiu	$sp,$sp,32
	jr $ra

imagen_dibuja_imagen_rotada:
	addiu	$sp, $sp, -36
	sw	$ra, 0($sp)
	sw	$a0, 20($sp)	# dst->20($sp)
	sw	$a1, 24($sp)	# src->24($sp)
	sw	$a2, 28($sp)	# dst_x->28($sp)
	sw	$a3, 32($sp)	# dst_y->32($sp)	
	lw	$t2, 4($a1)
	sw	$t2, 12($sp)	# src->alto = 12($sp)
	lw	$t3, 0($a1)
	sw	$t3, 16($sp)	# src->ancho = 16($sp)		
	sw	$0, 4($sp)	# y=0 = 4($sp)
	sw	$0, 8($sp)	# x=0 = 8($p)
for1_imagen_dibuja_imagen_rotada:
	lw	$t0, 4($sp)
	lw	$t2, 12($sp)
	bge	$t0, $t2, fin_for1_imagen_dibuja_imagen_rotada
for2_imagen_dibuja_imagen_rotada:
	lw	$t1, 8($sp)
	lw	$t3, 16($sp)
	bge	$t1, $t3, fin_for2_imagen_dibuja_imagen_rotada
	lw	$a0, 24($sp)
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	jal	imagen_get_pixel
	move	$a3,$v0 	# $a3 = p
	beq	$v0, $0, finif_imagen_dibuja_imagen_rotada
	lw	$t0, 4($sp)	# $t0 = y
	lw	$t1, 8($sp)	# $t1 = x
	lw	$t2, 12($sp)	# $t2 = src->alto
	lw	$t5, 28($sp)	# $t5 = dst_x
	lw	$t6, 32($sp)	# $t6 = dst_y
	lw	$a0, 20($sp)	# $a0 = dst
	add	$a1, $t2, $t5   # dst_x + src->alto
	subi	$a1, $a1, 1
	sub	$a1,$a1,$t0
	add	$a2, $t6, $t1
	jal	imagen_set_pixel	
	
finif_imagen_dibuja_imagen_rotada:	
	lw	$t1, 8($sp)
	addi	$t1, $t1, 1 # x++
	sw	$t1, 8($sp)
	j	for2_imagen_dibuja_imagen_rotada	
fin_for2_imagen_dibuja_imagen_rotada:
	sw	$0,8($sp)	# x=0
	lw	$t0, 4($sp)
	addi	$t0, $t0, 1 # y++
	sw	$t0, 4($sp)
	j	for1_imagen_dibuja_imagen_rotada
fin_for1_imagen_dibuja_imagen_rotada:	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 36 
	jr	$ra

integer_to_string:
        move    $t0, $a1
       	beqz	$a0, B9_6
        abs     $t1, $a0
        li      $t3, 10
B9_3:   blez	$t1, B9_4
	div	$t1, $t3
	mflo	$t1	
	mfhi	$t2	
	addiu	$t2, $t2, '0'
        sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_3
B9_4:	bgez	$a0, B9_7
	li	$t2, '-'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
	j	B9_7
B9_6:	li	$t2, '0'
	sb	$t2, 0($t0)
	addiu	$t0, $t0, 1
B9_7:	sb	$zero, 0($t0)
	addiu	$t0, $t0, -1
B9_9:   ble     $t0, $a1, B9_10
        lbu	$t2, 0($a1)
	lbu	$t3, 0($t0)
	sb	$t3, 0($a1)
	sb	$t2, 0($t0)
	addiu	$t0, $t0, -1
	addiu	$a1, $a1, 1
	j       B9_9
B9_10:	jr	$ra

imagen_dibuja_cadena:			#($a0, $a1, $a2, $a3)=(pantalla, x, y, string)
	addiu	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$a0, 4($sp) # pantalla
	sw	$a1, 8($sp) # x
	sw	$a2, 12($sp) # y 
	sw	$a3, 16($sp) # string
	
bucle_imagen_dibuja_cadena:
	
	lw 	$t1, 16($sp)
	lb	$t0, 0($t1)
	beq 	$t0, '\0', fin_bucle_imagen_dibuja_cadena
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$a2, 12($sp)
	lb	$a3, 0($t1)
	jal	imagen_set_pixel
	lw	$t0,8($sp)	
	addi	$t0, $t0, 1 # x++
	sw	$t0, 8($sp)
	
	lw	$t0,16($sp)	
	addi	$t0, $t0, 1 # string++
	sw	$t0, 16($sp)
	j 	bucle_imagen_dibuja_cadena
fin_bucle_imagen_dibuja_cadena:
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 20
	jr 	$ra
comprobar_linea_llena:			
	addiu	$sp, $sp, -16
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)	# y
	sw	$0, 8($sp)	# x =0	
	la	$t0, campo
	lw	$t1, 0($t0)		
	sw	$t1,12($sp)	# campo->ancho
for1_comprobar_linea_llena:
	lw	$t0,8($sp)	# sacamos x
	lw	$t1,12($sp)	# sacamos campo->ancho			
	bge $t0, $t1, true_comprobar_linea_llena	#for(x< campo->ancho; x++) 
if_comprobar_linea_llena:				#if(imagen_get_pixel(campo, x, y)== PIXEL_VACIO)
	la	$a0, campo
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	jal 	imagen_get_pixel
	bnez 	$v0, for2_comprobar_linea_llena
	j	fin_if_comprobar_linea_llena			#return false
for2_comprobar_linea_llena:
	lw	$t0,8($sp)	
	addi	$t0,$t0,1	# x++
	sw	$t0,8($sp)	
	j for1_comprobar_linea_llena			
true_comprobar_linea_llena:
	li $v0, 1			#return true
fin_if_comprobar_linea_llena:			
	lw	$ra, 0($sp)		# Sacamos el valor de $ra para volver con jr
	addiu	$sp, $sp, 16 
	jr 	$ra	
	
pieza_aleatoria:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$a0, 0
	li	$a1, 7
	jal	random_int_range	# $v0 ← random_int_range(0, 7)
	sll	$t1, $v0, 2
	la	$v0, piezas
	addu	$t1, $v0, $t1		# $t1 = piezas + $v0*4
	lw	$v0, 0($t1)		# $v0 ← piezas[$v0]
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra
	
	
eliminar_linea:				
	addiu 	$sp, $sp, -16
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)		# y
	la	$t0, campo
	lw	$t1, 0($t0)		
	sw	$t1, 12($sp)		# campo -> ancho
for1_eliminar_linea:			#for(y>= 0; y= y-1)
	lw	$t0, 4($sp)
	beqz	$t0, eliminar_linea0
	sw	$0, 8($sp)		# x=0
for2_eliminar_linea:
	lw	$t0,  8($sp)		# sacamos la x
	lw	$t1, 12($sp)		# sacamos campo->ancho
	bge	$t0, $t1, fin_for2_eliminar_linea		#for(x<=anchocampo; x++)
	la	$a0, campo
	lw 	$a1, 8($sp)
	lw	$a2, 4($sp)
	addi	$a2, $a2, -1
	jal	imagen_get_pixel
	la	$a0, campo
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	move	$a3, $v0
	jal	imagen_set_pixel
	lw	$t0,8($sp)
	addi	$t0,$t0,1	# x++
	sw	$t0,8($sp)
	j	for2_eliminar_linea
fin_for2_eliminar_linea:
	lw	$t0,4($sp)	
	addi    $t0, $t0, -1 	# y = y-1
	sw	$t0,4($sp)
	j	for1_eliminar_linea
eliminar_linea0:
	sw	$0, 8($sp)				#x=0
for3_eliminar_linea:	
	lw	$t0,  8($sp)		# sacamos la x
	lw	$t1, 12($sp)		# sacamos campo->ancho
	bge	$t0, $t1, fin_eliminar_linea	#for (x<=anchocampo; x++)
	la	$a0, campo
	lw 	$a1, 8($sp)
	lw	$a2, 4($sp)
	move	$a3, $0
	jal	imagen_set_pixel
	lw	$t0,8($sp)
	addi	$t0,$t0,1	# x++
	sw	$t0,8($sp)
	j	for3_eliminar_linea
fin_eliminar_linea:
	lw	$ra, 0($sp)		# Sacamos el valor de $ra para volver con jr
	addiu	$sp, $sp, 16
	jr	$ra
	
actualizar_pantalla:
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s2, 4($sp)
	sw	$s1, 0($sp)
	la	$s2, campo
	la	$a0, pantalla
	li	$a1, ' '
	jal	imagen_clean		# imagen_clean(pantalla, ' ')
        # for (int y = 0; y < campo->alto; ++y) {
	li	$s1, 0			# y = 0
B10_2:	lw	$t1, 4($s2)		# campo->alto
	bge	$s1, $t1, B10_3		# sigue si y < campo->alto
	la	$a0, pantalla
	li	$a1, 0                  # pos_campo_x - 1
	addi	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, 0, y, '|')
	la	$a0, pantalla
	lw	$t1, 0($s2)		# campo->ancho
	addiu	$a1, $t1, 1		# campo->ancho + 1
	addiu	$a2, $s1, 2             # y + pos_campo_y
	li	$a3, '|'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, campo->ancho + 1, y, '|')
        addiu	$s1, $s1, 1		# ++y
        j       B10_2
        # } // for y
	# for (int x = 0; x < campo->ancho + 2; ++x) { 
B10_3:	li	$s1, 0			# x = 0
B10_5:  lw	$t1, 0($s2)		# campo->ancho
        addiu   $t1, $t1, 2             # campo->ancho + 2
        bge	$s1, $t1, B10_6		# sigue si x < campo->ancho + 2
	la	$a0, pantalla
	move	$a1, $s1                # pos_campo_x - 1 + x
        lw	$t1, 4($s2)		# campo->alto
	addiu	$a2, $t1, 2		# campo->alto + pos_campo_y
	li	$a3, '-'
	jal	imagen_set_pixel	# imagen_set_pixel(pantalla, x, campo->alto + 1, '-')
	addiu	$s1, $s1, 1		# ++x
	j       B10_5
        # } // for x
B10_6:	la	$a0, pantalla
	move	$a1, $s2
	li	$a2, 1                  # pos_campo_x
	li	$a3, 2                  # pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, campo, 1, 2)

		
#cargar pieza_siguiente y recuadro_pieza_siguiente en pieza_siguiente_pantalla
	la	$a0, pieza_siguiente_pantalla
	la	$a1, recuadro_pieza_siguiente
	jal	imagen_copy
	la	$a0, pieza_siguiente_pantalla
	la	$a1, pieza_siguiente
	li	$a2, 3
	li	$a3, 2
	jal 	imagen_dibuja_imagen		
	
	la	$a0, pantalla
	la	$a1, pieza_actual
	lw	$t1, pieza_actual_x
	addiu	$a2, $t1, 1		# pieza_actual_x + pos_campo_x
	lw	$t1, pieza_actual_y
	addiu	$a3, $t1, 2		# pieza_actual_y + pos_campo_y
	jal	imagen_dibuja_imagen	# imagen_dibuja_imagen(pantalla, pieza_actual, pieza_actual_x + pos_campo_x, pieza_actual_y + pos_campo_y)
	
	la	$a0, pantalla
	li	$a1, 0
	li	$a2, 0
	la	$a3, strpuntuacion
	jal 	imagen_dibuja_cadena
	
	lw	$a0, puntos
	la	$a1, strpuntos
	jal 	integer_to_string
	
	la	$a0, pantalla
	li	$a1, 12
	li	$a2, 0
	la	$a3, strpuntos
	jal	imagen_dibuja_cadena
	
#cargar pieza_siguiente_pantalla en su lugar
	la	$a0, pantalla
	la	$a1, pieza_siguiente_pantalla
	lw	$a2, campo		#$a2=campo->ancho
	addi	$a2, $a2, 3		#desplazar la caja un pixel a la derecha
	li	$a3, 3
	jal	imagen_dibuja_imagen	
	
	jal	clear_screen		# clear_screen()
	la	$a0, pantalla
	jal	imagen_print		# imagen_print(pantalla)
	lw	$s1, 0($sp)
	lw	$s2, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

nueva_pieza_actual:
	addiu	$sp, $sp, -8
	sw	$ra,0($sp)
	la	$a0, pieza_actual
	la	$a1, pieza_siguiente
	jal	imagen_copy			#pieza_actual = pieza_siguiente
	jal	pieza_aleatoria			
	sw	$v0, 4($sp)
	move 	$a0, $v0
	li	$a1, 8
	li	$a2, 0
	jal	probar_pieza			#probamos la siguiente pieza en (8,0) para ver si se tiene que acabar
	beqz	$v0, fin_if_nueva_pieza_actual	#if(probar_pieza(pieza_aleatoria,8,0)==0)-->acabar_partida
	la	$a0, pieza_siguiente
	lw	$a1, 4($sp)
	jal	imagen_copy			#pieza_siguiente = pieza_aleatoria
	la	$t0,pieza_actual_x
	li	$t1,8
	sw	$t1,0($t0) 		# pieza_actual_x = 8
	la	$t0,pieza_actual_y
	sw	$0,0($t0)  		# pieza_actual_y = 0
	j	fin_nueva_pieza_actual
fin_if_nueva_pieza_actual:	
	li	$t0, 1
	sb	$t0, acabar_partida		#acabar_partida = 1
	li	$t0, 1
	sb	$t0, game_over			#game_over = 1
fin_nueva_pieza_actual:
	lw	$ra,0($sp)
	addiu	$sp, $sp, 8
	jr	$ra

probar_pieza:				# ($a0, $a1, $a2) = (pieza, x, y)
	addiu	$sp, $sp, -32
	sw	$ra, 28($sp)
	sw	$s7, 24($sp)
	sw	$s6, 20($sp)
	sw	$s4, 16($sp)
	sw	$s3, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	move	$s0, $a2		# y
	move	$s1, $a1		# x
	move	$s2, $a0		# pieza
	li	$v0, 0
	bltz	$s1, B12_13		# if (x < 0) return false
	lw	$t1, 0($s2)		# pieza->ancho
	addu	$t1, $s1, $t1		# x + pieza->ancho
	la	$s4, campo
	lw	$v1, 0($s4)		# campo->ancho
	bltu	$v1, $t1, B12_13	# if (x + pieza->ancho > campo->ancho) return false
	bltz	$s0, B12_13		# if (y < 0) return false
	lw	$t1, 4($s2)		# pieza->alto
	addu	$t1, $s0, $t1		# y + pieza->alto
	lw	$v1, 4($s4)		# campo->alto
	bltu	$v1, $t1, B12_13	# if (campo->alto < y + pieza->alto) return false
	# for (int i = 0; i < pieza->ancho; ++i) {
	lw	$t1, 0($s2)		# pieza->ancho
	beqz	$t1, B12_12
	li	$s3, 0			# i = 0
	#   for (int j = 0; j < pieza->alto; ++j) {
	lw	$s7, 4($s2)		# pieza->alto
B12_6:	beqz	$s7, B12_11
	li	$s6, 0			# j = 0
B12_8:	move	$a0, $s2
	move	$a1, $s3
	move	$a2, $s6
	jal	imagen_get_pixel	# imagen_get_pixel(pieza, i, j)
	beqz	$v0, B12_10		# if (imagen_get_pixel(pieza, i, j) == PIXEL_VACIO) sigue
	move	$a0, $s4
	addu	$a1, $s1, $s3		# x + i
	addu	$a2, $s0, $s6		# y + j
	jal	imagen_get_pixel
	move	$t1, $v0		# imagen_get_pixel(campo, x + i, y + j)
	li	$v0, 0
	bnez	$t1, B12_13		# if (imagen_get_pixel(campo, x + i, y + j) != PIXEL_VACIO) return false
B12_10:	addiu	$s6, $s6, 1		# ++j
	bltu	$s6, $s7, B12_8		# sigue si j < pieza->alto
        #   } // for j
B12_11:	lw	$t1, 0($s2)		# pieza->ancho
	addiu	$s3, $s3, 1		# ++i
	bltu	$s3, $t1, B12_6 	# sigue si i < pieza->ancho
        # } // for i
B12_12:	li	$v0, 1			# return true
B12_13:	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s6, 20($sp)
	lw	$s7, 24($sp)
	lw	$ra, 28($sp)
	addiu	$sp, $sp, 32
	jr	$ra

intentar_movimiento:
	addiu	$sp,$sp, -20
	sw	$ra,0($sp)
	sw	$a0,4($sp) # x
	sw	$a1,8($sp) # y
	la	$t0,pieza_actual_x
	sw	$t0,12($sp) # direccion pieza_actual_x
	la	$t0,pieza_actual_y
	sw	$t0,16($sp) # direccion pieza_actual_y
	
	la 	$a0,pieza_actual
	lw	$t1,4($sp)
	move	$a1,$t1
	lw	$t1,8($sp)
	move	$a2,$t1
	jal	probar_pieza
	beq	$v0,$0,fin_if_intentar_movimiento
	li	$t0,1
	move	$v0,$t0 # return true
	lw	$t0,4($sp) # sacdamos x
	lw	$t1,12($sp) # sacamos la direccion de pieza_actual_x
	sw	$t0,0($t1) # pieza_actual_x = x
	lw	$t0,8($sp) # sacdamos y
	lw	$t1,16($sp) # sacamos la direccion de pieza_actual_y
	sw	$t0,0($t1) # pieza_actual_y = y
fin_if_intentar_movimiento:
	# return false
	lw	$ra,0($sp)
	addiu	$sp,$sp, 20
	jr	$ra

bajar_pieza_actual:
	
	addiu	$sp,$sp, -16
	sw	$ra,0($sp)
	
	la	$t0,pieza_actual_x	
	lw	$t1,0($t0)
	sw	$t1,4($sp)
	move	$a0,$t1
	la	$t0,pieza_actual_y	
	lw	$t1,0($t0)
	sw	$t1,8($sp)
	move	$a1,$t1
	addi	$a1,$a1,1
	jal	intentar_movimiento
	li	$t0,1
	beq	$v0,$t0,fin_if1_bajar_pieza_actual
	
	lw 	$t0, puntos		#t0= puntos (puntos totales de la partida)
	addi	$t0, $t0, 1
	sw	$t0, puntos		#puntos++
	
	la 	$a0,campo
	la	$a1,pieza_actual
	lw	$a2,4($sp)
	lw	$a3,8($sp)
	jal	imagen_dibuja_imagen
	lw	$t2,8($sp)
	la	$t0, pieza_actual
	lw	$t1, 4($t0)
	add	$t2, $t2, $t1		#$s1= pieza_actual_y+ pieza_actual->alto
	sw	$t2,12($sp)
for_bajar_pieza_actual:			#for(y< pieza_actual_y+ pieza_actual->alto; y++)
	lw	$t0,8($sp)
	lw	$t1,12($sp)
	bge	$t0, $t1, fin_for_bajar_pieza_actual
if2_bajar_pieza_actual:			#if(comprobar_linea_llena(y))
	lw	$a0, 8($sp)
	jal	comprobar_linea_llena
	beqz	$v0, fin_if2_bajar_pieza_actual
	lw 	$t0, puntos
	addiu	$t0, $t0, 10		#puntos= puntos +10
	sw  	$t0, puntos
	lw	$a0, 8($sp)
	jal 	eliminar_linea
fin_if2_bajar_pieza_actual:
	lw	$t0,8($sp)
	addi	$t0,$t0,1		# y++
	sw	$t0,8($sp)
	j 	for_bajar_pieza_actual
fin_for_bajar_pieza_actual:	
	jal	nueva_pieza_actual	
fin_if1_bajar_pieza_actual:	
	lw	$ra, 0($sp)		#Almacenamos el valor de $ra para volver con jr
	addiu	$sp, $sp, 16
	jr	$ra

intentar_rotar_pieza_actual:
	addiu	$sp, $sp, -8
	sw	$ra, 0($sp)
	la	$a0, imagen_auxiliar
	sw	$a0, 4($sp)		# &imagen_auxiliar --> 4($sp)
	la	$t0, pieza_actual	# como la imagen se va a rotar 90 grados, se intercambian el ancho y el alto.
	lw	$a1, 4($t0)
	lw	$a2, 0($t0)
	move	$a3, $0
	jal	imagen_init
	lw	$a0, 4($sp) # pieza _rotada = &imagen_auxiliar --> 4($sp)
	la	$a1, pieza_actual
	move	$a2, $0
	move	$a3, $0
	jal	imagen_dibuja_imagen_rotada
	
	# if (probar_pieza(pieza_rotada, pieza_actual_x, pieza_actual_y)
	lw	$a0, 4($sp)
	lw	$a1, pieza_actual_x
	lw	$a2, pieza_actual_y
	jal	probar_pieza
	beqz	$v0, fin_if_intentar_rotar_pieza_actual
	la	$a0, pieza_actual
	lw	$a1, 4($sp)
	jal	imagen_copy
fin_if_intentar_rotar_pieza_actual:	

	lw	$ra, 0($sp)
	addiu	$sp, $sp, 8
	jr	$ra

tecla_salir:
	li	$v0, 1
	sb	$v0, acabar_partida	# acabar_partida = true
	jr	$ra

tecla_izquierda:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, -1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x - 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_derecha:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$a1, pieza_actual_y
	lw	$t1, pieza_actual_x
	addiu	$a0, $t1, 1
	jal	intentar_movimiento	# intentar_movimiento(pieza_actual_x + 1, pieza_actual_y)
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_abajo:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	bajar_pieza_actual	# bajar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_rotar:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	intentar_rotar_pieza_actual	# intentar_rotar_pieza_actual()
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

tecla_truco:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s2, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
       	li	$s4, 18
	#  for (int y = 13; y < 18; ++y) {         
	li	$s0, 13
	#  for (int x = 0; x < campo->ancho - 1; ++x) {
B21_1:	li	$s1, 0
B21_2:	lw	$t1, campo
	addiu	$t1, $t1, -1
	bge	$s1, $t1, B21_3
	la	$a0, campo
	move	$a1, $s1
	move	$a2, $s0
	li	$a3, '#'
	jal	imagen_set_pixel	# imagen_set_pixel(campo, x, y, '#'); 
	addiu	$s1, $s1, 1	# 245   for (int x = 0; x < campo->ancho - 1; ++x) { 
	j	B21_2
B21_3:	addiu	$s0, $s0, 1
	bne	$s0, $s4, B21_1
	la	$a0, campo
	li	$a1, 10
	li	$a2, 16
	li	$a3, 0
	jal	imagen_set_pixel	# imagen_set_pixel(campo, 10, 16, PIXEL_VACIO); 
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

procesar_entrada:
	addiu	$sp, $sp, -20
	sw	$ra, 16($sp)
	sw	$s4, 12($sp)
	sw	$s3, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	jal	keyio_poll_key
	move	$s0, $v0		# int c = keyio_poll_key()
        # for (int i = 0; i < sizeof(opciones) / sizeof(opciones[0]); ++i) { 
	li	$s1, 0			# i = 0, $s1 = i * sizeof(opciones[0]) // = i * 8
	la	$s3, procesar_entrada.opciones	
	li	$s4, 48			# sizeof(opciones) // == 5 * sizeof(opciones[0]) == 5 * 8
B22_1:	addu	$t1, $s3, $s1		# procesar_entrada.opciones + i*8
	lb	$t2, 0($t1)		# opciones[i].tecla
	bne	$t2, $s0, B22_3		# if (opciones[i].tecla != c) siguiente iteración
	lw	$t2, 4($t1)		# opciones[i].accion
	jalr	$t2			# opciones[i].accion()
	jal	actualizar_pantalla	# actualizar_pantalla()
B22_3:	addiu	$s1, $s1, 8		# ++i, $s1 += 8
	bne	$s1, $s4, B22_1		# sigue si i*8 < sizeof(opciones)
        # } // for i
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$s3, 8($sp)
	lw	$s4, 12($sp)
	lw	$ra, 16($sp)
	addiu	$sp, $sp, 20
	jr	$ra

jugar_partida:
	addiu	$sp, $sp, -12	
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)
	la	$a0, pantalla
	li	$a1, 30
	li	$a2, 22
	li	$a3, 32
	jal	imagen_init		# imagen_init(pantalla, 20, 22, ' ')
	la	$a0, campo
	li	$a1, 14
	li	$a2, 18
	li	$a3, 0
	jal	imagen_init		# imagen_init(campo, 14, 18, PIXEL_VACIO)
	jal 	pieza_aleatoria
	la	$a0, pieza_siguiente
	move	$a1, $v0
	jal	imagen_copy
	jal	nueva_pieza_actual	# nueva_pieza_actual()
	sb	$zero, acabar_partida	# acabar_partida = false
	jal	get_time		# get_time()
	move	$s0, $v0		# Hora antes = get_time()
	la	$t1, puntos
	sw	$zero, 0($t1)		#puntos=0
	jal	actualizar_pantalla	# actualizar_pantalla()
	j	B23_2
        # while (!acabar_partida) { 
B23_2:	lbu	$t1, acabar_partida
	bnez	$t1, B23_5		# if (acabar_partida != 0) sale del bucle
	jal	procesar_entrada	# procesar_entrada()
	jal	get_time		# get_time()
	move	$s1, $v0		# Hora ahora = get_time()
	subu	$t1, $s1, $s0		# int transcurrido = ahora - antes
	ble	$t1, 1000, B23_2	# if (transcurrido < pausa) siguiente iteración
B23_1:	jal	bajar_pieza_actual	# bajar_pieza_actual()
	jal	actualizar_pantalla	# actualizar_pantalla()
	move	$s0, $s1		# antes = ahora
        j	B23_2			# siguiente iteración
       	# } 
B23_5:	
	lbu	$t0, game_over
	beqz	$t0, finj_jugar_partida		# if (game_over==1)->mostrar mensaje
	la	$a0, pantalla			
	la	$a1, imagen_fin_partida
	li	$a2, 1
	li	$a3, 8
	jal	imagen_dibuja_imagen		#se guarda el mensaje
	jal 	clear_screen
	la	$a0, pantalla
	jal	imagen_print			#se imprime el mensaje
	jal	read_character			#espera a que se pulse una tecla para finalizar
finj_jugar_partida:
	lw	$s0, 0($sp)
	lw	$s1, 4($sp)
	lw	$ra, 8($sp)
	addiu	$sp, $sp, 12
	jr	$ra

	.globl	main
main:					# ($a0, $a1) = (argc, argv) 
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
B24_2:	jal	clear_screen		# clear_screen()
	la	$a0, str000
	jal	print_string		# print_string("Tetris\n\n 1 - Jugar\n 2 - Salir\n\nElige una opción:\n")
	jal	read_character		# char opc = read_character()
	beq	$v0, '2', B24_1		# if (opc == '2') salir
	bne	$v0, '1', B24_5		# if (opc != '1') mostrar error
	jal	jugar_partida		# jugar_partida()
	j	B24_2
B24_1:	la	$a0, str001
	jal	print_string		# print_string("\n¡Adiós!\n")
	li	$a0, 0
	jal	mips_exit		# mips_exit(0)
	j	B24_2
B24_5:	la	$a0, str002
	jal	print_string		# print_string("\nOpción incorrecta. Pulse cualquier tecla para seguir.\n")
	jal	read_character		# read_character()
	j	B24_2
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra

#
# Funciones de la librería del sistema
#

print_character:
	li	$v0, 11
	syscall	
	jr	$ra

print_string:
	li	$v0, 4
	syscall	
	jr	$ra

get_time:
	li	$v0, 30
	syscall	
	move	$v0, $a0
	move	$v1, $a1
	jr	$ra

read_character:
	li	$v0, 12
	syscall	
	jr	$ra

clear_screen:
	li	$v0, 39
	syscall	
	jr	$ra

mips_exit:
	li	$v0, 17
	syscall	
	jr	$ra

random_int_range:
	li	$v0, 42
	syscall	
	move	$v0, $a0
	jr	$ra

keyio_poll_key:
	li	$v0, 0
	lb	$t0, 0xffff0000
	andi	$t0, $t0, 1
	beqz	$t0, keyio_poll_key_return
	lb	$v0, 0xffff0004
keyio_poll_key_return:
	jr	$ra
