.data
	A: .space 10			# Tao mang A luu String1
	B: .space 10			# Tao mang B luu String2
	C: .word 0:10			# Mang trung gian chua cac ky tu 0 
	string_output: .asciiz "So luong ky tu giong nhau la: "
	Nhap1: .asciiz "Nhap xau 1: "
	Nhap2: .asciiz  "Nhap xau 2: "
	error1: .asciiz "Error1 : Please enter data - do not click cancel"
	error2: .asciiz "Error2 : Please enter data then click OK"
	error3: .asciiz "Error3 : character length is less than 10"
.text
main:	
array_a:
	# Nhap mang A
	li $v0, 54     			#show dialog
	la $a0, Nhap1			#goi nhap1	
	la $a1, A			#nhap gia tri vao mang A
	li $a2, 10			#so ki tu toi da la 10
	syscall
	
	beq $a1, 0, array_b		# Nhap thanh cong gia tri mang A thi chuyen den nhap mang B
	beq $a1, -2, show_error1_1	# click cancel
	beq $a1, -3, show_error1_2	# click Ok nhung ko co du lieu dau vao
	beq $a1, -4, show_error1_3	# nhap so ki tu lon hon do dai cua mang
show_error1_1:
	li $v0, 55			#in ra hop thoai
	la $a0, error1			#bao loi error1
	syscall				
	j array_a			#nhap lai mang A	
show_error1_2:
	li $v0, 55			#in ra hop thoai	
	la $a0, error2			#bao loi error2
	syscall				
	j array_a			#nhap lai mang A	
show_error1_3:	
	li $v0, 55			#in ra hop thoai
	la $a0, error3			#bao loi error3
	syscall
	j array_a			#nhap lai mang A	

array_b:
	# Nhap mang B
	li $v0, 54			
	la $a0, Nhap2
	la $a1, B
	li $a2, 10
	syscall	
	
	beq $a1, 0, start		# nhap thanh cong gia tri mang B thi chuyen den start
	beq $a1, -2, show_error2_1	# click cancel
	beq $a1, -3, show_error2_2	# click Ok nhung ko co du lieu dau vao
	beq $a1, -4, show_error2_3	# nhap so ki tu lon hon do dai cua mang
show_error2_1:
	li $v0, 55			#in ra hop thoai
	la $a0, error1			#bao loi error1	
	syscall
	j array_b			#nhap lai mang B
show_error2_2:
	li $v0, 55
	la $a0, error2
	syscall
	j array_b
show_error2_3:	
	li $v0, 55
	la $a0, error3
	syscall
	j array_b
	
start:			
	
	la $a0, A 				# gan dia chi string1 vao a0
	jal strLength 				# chuyen den ham strLength
	add $t6, $zero, $v0			# $t6 la do dai cua string1 
	
	la $a0, B 				# gan dia chi string2 vao a0
	jal strLength 				# chuyen den ham strLength		
	add $t7, $zero, $v0			# $t7 la do dai cua string2
#===================Ma gia=====================#
# for (i = 0 ; i < length(A); i++)
# 	for(j = 0; j < length(B); j++)
#		if(A[i] == B[j] && C[j] == 0)
#			count ++;
#			C[j] = 1;
#==============================================#
		
	la $s0, A				#luu dia chi cua A
	la $s1, B				#luu dia chi cua B
	la $s2, C				#luu dia chi cua C

	add $t3, $s0, $zero			# $t3 = dia chi cua A
	
	addi $s3, $zero, 0			# count = 0
	
	addi $t0, $zero, 0			# $t0 = i = 0 cua loop1
loop1:
	sge $t2, $t0, $t6			# if i>=t6 thi chuyen den end_loop1
	bnez $t2, end_loop1		
	
	addi $t1, $zero, 0			# $t1 = j = 0 cua loop2
	
	add $t4, $s1, $zero			# $t4 = dia chi cua B
	add $t5, $s2, $zero			# $t5 = dia chi cua C


loop2:
	sge $t2, $t1, $t7			# if j >= t7 thi chuyen den end_loop2
	bnez $t2, end_loop2
if:
	lb $s4, 0($t3)				# $s4 = A[i]
	lb $s5, 0($t4)				# $s5 = B[j]
	lw $s6, 0($t5)				# $s6 = C[j]
	seq $t2, $s4, $s5			# if A[i] = B[j]
	beqz $t2, end_if			# then true
	bnez $s6, end_if			# if C[j] = 0 then true
	addi $s3, $s3, 1			# count++
	addi $s6, $zero, 1			# C[j] = $s6 = 1
	sw $s6, 0($t5)			
	j end_loop2
end_if:
	addi $t1, $t1, 1			# j++
	addi $t4, $t4, 1			# Get address of B[j]
	addi $t5, $t5, 4			# Get address of C[j]
	j loop2					#quay tro lai loop2
end_loop2:
	addi $t0, $t0, 1			# i++
	addi $t3, $t3, 1			# Get address of A[i]
	j loop1
end_loop1:
end_main:
	li $v0, 56				# in ra hop thoai 
	la $a0, string_output			
	add $a1, $s3, $zero
	syscall					# output count
	
	li $v0, 10				#ket thuc chuong trinh
	syscall


#Funtion strLength

strLength:
	add $v0, $zero, $zero  			# v0=i=0 
L1:
	add $t1, $v0, $a0  			# lay dia chi cua a[i] luu vao t1
	lb $t2, 0($t1)  			# gia tri cua a[i] luu vao t2
	beq $t2, 10, end_strLength 		# if (t2 == "\n") thi end L1
	addi $v0, $v0, 1			#i++
	j L1					#quay lai vong lap
end_strLength:				
	jr $ra 					#nhay den cau lenh jal
