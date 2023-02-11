//�ָ���������
module division 
(  
input[31:0] dividend,       // ������
input[31:0] divisor,        // ����
output reg [31:0] shang,    // ��
output reg [31:0] yushu
);  
  
reg[31:0] tempa;  
reg[31:0] tempb;  
reg[63:0] temp_a;  
reg[63:0] temp_b;  
  
integer i;  

always @(dividend or divisor)  
begin  
    tempa <= dividend;  
    tempb <= divisor;  
end  
  
always @(tempa or tempb)  
begin
    if(tempb!=0) begin
        temp_a = {32'h00000000,tempa};  
        temp_b = {tempb,32'h00000000};  
        for(i = 0;i < 32;i = i + 1)  
            begin  
                temp_a = {temp_a[62:0],1'b0};  
                if(temp_a[63:32] >= tempb)  
                    temp_a = temp_a - temp_b + 1'b1;  
                else  
                    temp_a = temp_a;  
            end  
        shang = temp_a[31:0];  
        yushu = temp_a[63:32]; 
    end 
    else begin                      //����Ϊ��ʱ�������Ϊ���ֵ
        shang = 32'h00000000;  
        yushu = 32'hFFFFFFFF; 
    end 
end  
endmodule