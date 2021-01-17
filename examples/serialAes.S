//send "@"
addi x3, x0, 64
sb x0, x3, 513
//read plaintext
lb x1, x0, 512 //load status register to x1
andi x1, x1, 1 //x1 = x1&1
addi x2, x0, 1 //x2 = 1
bne x1, x2, -12  //goto lb instruction if x1!=x2
exlb x0, x0, 514 //load received data to x0(X0)
addi x4, x4, 1 // increment counter
addi x5, x0, 16 // if 16byte(128bit) received, go to next step
beq x4, x5, 8 //break
jal x0, -32 //loop 16 times
//read secret
addi x3, x0, 65
sb x0, x3, 513

addi x4, x0, 0
lb x1, x0, 512 //load status register to x1
andi x1, x1, 1 //x1 = x1&1
addi x2, x0, 1 //x2 = 1
bne x1, x2, -12  //goto lb instruction if x1!=x2
exlb x1, x0, 514 //load received data to x1(X1)
addi x4, x4, 1 // increment counter
addi x5, x0, 16 // if 16byte(128bit) received, go to next step
beq x4, x5, 8 //break
jal x0, -32 //loop 16 times
//encrypt
addi x3, x0, 66
sb x0, x3, 513
//encrypt
aesencrypt128 x2, x1, x0
//decrypt
aesdecrypt128 x3, x2, x0
//send decrypt data
addi x6, x0, 128
lb x1, x0, 512
andi x1, x1, 2 //x1 = x1&2
addi x2, x0, 2 //x2 = 2
beq x1, x2, -12  //goto lb instruction if x1!=x2
addi x6, x6, -8
xd2r x3, x2, x6
sb x0, x3, 513 //send data
beq x6, x0, 8
jal x0, -32
jal x0, 0
