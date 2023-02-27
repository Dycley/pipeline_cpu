`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: multiply.v
//   > 描述  ：乘法器模块，无符号的32位并行乘法器，采用全加器单元FA实现
//*************************************************************************
// module multiply(              // 乘法器
//     input  [31:0] mult_op1,   // 乘法源操作数1
//     input  [31:0] mult_op2,   // 乘法源操作数2
//     output [63:0] product);    // 乘积
//     assign product = mult_op1 * mult_op2;
// endmodule

module multiply(              // 阵列乘法器
    input  [31:0] mult_op1,   // 乘法源操作数1
    input  [31:0] mult_op2,   // 乘法源操作数2
    output [63:0] product     // 乘积
 );

    genvar i,j;
    
    wire A[31:0][30:0];
    wire B[31:0][30:0];
    wire Ci[31:0][30:0];
    wire Co[31:0][30:0];
    wire So[31:0][30:0];
    
    //关联B
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
    
    //关联Ci,Co
    for(i=0;i<31;i=i+1) begin
        assign Ci[0][i] = 0;
    end
    
    for(i=0;i<31;i=i+1) begin
        for(j=0;j<31;j=j+1) begin
            assign Ci[i+1][j] =Co[i][j];
        end
    end
    
    //关联A,So
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