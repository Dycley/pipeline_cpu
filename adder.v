`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: adder.v
//   > 描述  ：32位并行进位加法器
//*************************************************************************
module adder(operand1,operand2,cin,result,cout);
    input  [31:0] operand1;
    input  [31:0] operand2;
    input         cin;
    output [31:0] result;
    output        cout;
    
    wire px1,px2,gx1,gx2;
    wire c16;

    CLA_16 CLA0(
        .A(operand1[15:0]),
        .B(operand2[15:0]),
        .c0(cin),
        .F(result[15:0]),
        .Px(px1),
        .Gx(gx1)
    );

    CLA_16 CLA1(
        .A(operand1[31:16]),
        .B(operand2[31:16]),
        .c0(c16),
        .F(result[31:16]),
        .Px(px2),
        .Gx(gx2)
    );

    assign  c16 = gx1 ^ (px1 && cin), 
            cout = gx2 ^ (px2 && c16);

endmodule

// 16位CLA
module CLA_16 (A,B,c0,F,Px,Gx);
    input [15:0] A;
    input [15:0] B;
    input c0;
    output Px,Gx;
    output [15:0] F;

    wire c4,c8,c12;
    wire Pm1,Gm1,Pm2,Gm2,Pm3,Gm3,Pm4,Gm4;

    adder_4 adder0(
        .x(A[3:0]),
        .y(B[3:0]),
        .c0(c0),
        .c4(),
        .F(F[3:0]),
        .G(Gm1),
        .P(Pm1)
    );

    adder_4 adder1(
        .x(A[7:4]),
        .y(B[7:4]),
        .c0(c4),
        .c4(),
        .F(F[7:4]),
        .G(Gm2),
        .P(Pm2)
    );

    adder_4 adder2(
        .x(A[11:8]),
        .y(B[11:8]),
        .c0(c8),
        .c4(),
        .F(F[11:8]),
        .G(Gm3),
        .P(Pm3)
    );

    adder_4 adder3(
        .x(A[15:12]),
        .y(B[15:12]),
        .c0(c12),
        .c4(),
        .F(F[15:12]),
        .G(Gm4),
        .P(Pm4)
    );
    
    assign  c4 = Gm1 ^ (Pm1 & c0),
            c8 = Gm2 ^ (Pm2 & Gm1) ^ (Pm2 & Pm1 & c0),
            c12 = Gm3 ^ (Pm3 & Gm2) ^ (Pm3 & Pm2 & Gm1) ^ (Pm3 & Pm2 & Pm1 & c0);
 
    assign  Px = Pm1 & Pm2 & Pm3 & Pm4,
            Gx = Gm4 ^ (Pm4 & Gm3) ^ (Pm4 & Pm3 & Gm2) ^ (Pm4 & Pm3 & Pm2 & Gm1);

endmodule

// 4位并行进位加法器
module adder_4 (x,y,c0,c4,F,G,P);
    input [3:0] x;
    input [3:0] y;
    input c0;
    output c4,G,P;
    output [3:0] F;

    wire p1,p2,p3,p4,g1,g2,g3,g4;
    wire c1,c2,c3;
    adder_1 adder0(
        .a(x[0]),
        .b(y[0]),
        .ci(c0),
        .so(F[0]),
        .co()
    );

    adder_1 adder1(
        .a(x[1]),
        .b(y[1]),
        .ci(c1),
        .so(F[1]),
        .co()
    );

    adder_1 adder2(
        .a(x[2]),
        .b(y[2]),
        .ci(c2),
        .so(F[2]),
        .co()
    );

    adder_1 adder3(
        .a(x[3]),
        .b(y[3]),
        .ci(c3),
        .so(F[3]),
        .co()
    );

    CLA CLA(
        .c0(c0),
        .c1(c1),
        .c2(c2),
        .c3(c3),
        .c4(c4),
        .p1(p1),
        .p2(p2),
        .p3(p3),
        .p4(p4),
        .g1(g1),
        .g2(g2),
        .g3(g3),
        .g4(g4)
    );

    assign  p1 = x[0] ^ y[0],	  
            p2 = x[1] ^ y[1],
            p3 = x[2] ^ y[2],
            p4 = x[3] ^ y[3];

    assign  g1 = x[0] & y[0],
            g2 = x[1] & y[1],
            g3 = x[2] & y[2],
            g4 = x[3] & y[3];

    assign  P = p1 & p2 & p3 & p4,
            G = g4 ^ (p4 & g3) ^ (p4 & p3 & g2) ^ (p4 & p3 & p2 & g1);

endmodule

// 1位全加器
module adder_1(a,b,ci,co,so);
    input   a,b,ci;
    output  co,so;

    assign so=a^b^ci;
    assign co=(a&b)|(ci&(a|b));
endmodule

// 4位CLA部件
module CLA(c0,c1,c2,c3,c4,p1,p2,p3,p4,g1,g2,g3,g4);
    input  c0,p1,p2,p3,p4,g1,g2,g3,g4;
    output c1,c2,c3,c4;

assign  c1 = g1 ^ (p1 & c0),
        c2 = g2 ^ (p2 & g1) ^ (p2 & p1 & c0),
        c3 = g3 ^ (p3 & g2) ^ (p3 & p2 & g1) ^ (p3 & p2 & p1 & c0),
        c4 = g4 ^ (p4 & g3) ^ (p4 & p3 & g2) ^ (p4 & p3 & p2 & g1) ^(p4 & p3 & p2 & p1 & c0);

endmodule