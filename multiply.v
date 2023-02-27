`timescale 1ns / 1ps
//*************************************************************************
//   > �ļ���: multiply.v
//   > ����  ���˷���ģ�飬�޷��ŵ�32λ���г˷���������ȫ������ԪFAʵ��
//*************************************************************************
// module multiply(              // �˷���
//     input  [31:0] mult_op1,   // �˷�Դ������1
//     input  [31:0] mult_op2,   // �˷�Դ������2
//     output [63:0] product);    // �˻�
//     assign product = mult_op1 * mult_op2;
// endmodule

module multiply(              // ���г˷���
    input  [31:0] mult_op1,   // �˷�Դ������1
    input  [31:0] mult_op2,   // �˷�Դ������2
    output [63:0] product     // �˻�
 );

    genvar i,j;
    
    wire A[31:0][30:0];
    wire B[31:0][30:0];
    wire Ci[31:0][30:0];
    wire Co[31:0][30:0];
    wire So[31:0][30:0];
    
    //����B
    for(i=0;i<31;i=i+1) begin
        for(j=0;j<31;j=j+1) begin
            assign B[i][j] = mult_op1[j] & mult_op2[i+1];
        end
    end
    
    assign B[31][0] = 0;
    
    for(i=1;i<31;i=i+1) begin
        assign B[31][i] = B[31][i-1];
        assign Ci[31][i] = Co[31][i-1];
    end
    
    //����Ci,Co
    for(i=0;i<31;i=i+1) begin
        assign Ci[0][i] = 0;
    end
    
    for(i=0;i<31;i=i+1) begin
        for(j=0;j<31;j=j+1) begin
            assign Ci[i+1][j] =Co[i][j];
        end
    end
    
    //����A,So
    for(i=0;i<31;i=i+1) begin
        assign A[0][i] = mult_op1[i+1] & mult_op2[0];
        assign A[i+1][30] = mult_op1[31] & mult_op2[i+1];
    end
    
    for(i=0;i<31;i=i+1) begin
        for(j=0;j<30;j=j+1) begin
            assign A[i+1][j] = So[i][j+1];
        end
    end
    
    assign product[0] = mult_op1[0] & mult_op2[0];
    assign product[63] = Ci[31][30];
    for(i=0;i<31;i=i+1) begin
        assign product[i+1] = So[i][0];
        assign product[i+32] = So[31][i];
    end
    
    generate
        for(i=0;i<32;i=i+1) begin
            for(j=0;j<31;j=j+1) begin
                    adder_1 FA(
                    .a(A[i][j]),
                    .b(B[i][j]),
                    .ci(Ci[i][j]),
                    .co(Co[i][j]),
                    .so(So[i][j])
                    );
            end  
        end 
    endgenerate
 endmodule