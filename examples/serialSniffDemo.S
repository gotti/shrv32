//TODO: 注意，BOFできます後で直す

//set random number to X4
lb x1, x0, 512 //load status register to x1
andi x1, x1, 16
addi x2, x0, 16
beq x1, x2, -12
exlbi x4, x4, 515
addi x4, x4, 1
addi x5, x0, 16
beq x4, x5, 8 //break
jal x0, -32 //loop 16 times

exaddi x4, x4, 1

//多倍長readSerial
addi x4, x0, 0
lb x1, x0, 512 //load status register to x1
andi x1, x1, 1
addi x2, x0, 1
bne x1, x2, -12  //goto lb instruction if x1!=x2
lb x3, x0, 514 //load received data to x3
addi x5, x0, 4 //if receive ^D, end
beq x3, x5, 16 //break
sb x4, x3, 0 //0 to n
addi x4, x4, 1 // increment counter
jal x0, -36
//save counter value to x8 for next use
addi x8, x4, 0

//X3 = X4;
exaddi x3, x4, 0

//send IV
addi x7, x0, 128
lb x1, x0, 512
andi x1, x1, 2 //x1 = x1&2
addi x2, x0, 2 //x2 = 2
beq x1, x2, -12  //goto lb instruction if x1!=x2
addi x7, x7, -8
xd2r x3, x3, x7
sb x0, x3, 513 //send data
beq x7, x0, 8
jal x0, -32
//load opposite IV
//x10 is a pointer to receive buffer
addi x10, x0, 0

//X0 = load16byte(a), this is opposite IV
exxor x0, x0, x0
addi x4, x0, 0
exlb x0, x0, x10
addi x4, x4, 1 // increment counter
addi x10, x10, 1 // increment counter
addi x5, x0, 16 // if 16byte(128bit) received, go to next step
beq x4, x5, 8 //break
jal x0, -20 //loop 16 times

//X1 = load16byte(a), this is received ciphertext
exxor x1, x1, x1
addi x4, x0, 0
exlb x1, x1, x10
addi x4, x4, 1 // increment counter
addi x10, x10, 1 // increment counter
addi x5, x0, 16 // if 16byte(128bit) received, go to next step
beq x4, x5, 8 //break
jal x0, -20 //loop 16 times


aesdecrypt128 x2, x1, x5

exxor x2, x2, x0
//ここでX2は平文

exxor x2, x2, x3

aesencrypt128 x2, x2, x5

//serialSend(X2)
addi x7, x0, 128
lb x1, x0, 512
andi x1, x1, 2 //x1 = x1&2
addi x2, x0, 2 //x2 = 2
beq x1, x2, -12  //goto lb instruction if x1!=x2
addi x7, x7, -8
xd2r x3, x2, x7
sb x0, x3, 513 //send data
beq x7, x0, 8
jal x0, -32

exaddi x0, x1, 0
exaddi x3, x2, 0
bge x10, x8, 8
jal x0, -100
//back to exaddi x4, x0, 1
jalr x0, x0, 36
