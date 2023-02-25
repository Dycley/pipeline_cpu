`timescale 1ns / 1ps
//*************************************************************************
//   > �ļ���: mem.v
//   > ����  :�弶��ˮCPU�ķô�ģ��
//   > ����  : LOONGSON
//   > ����  : 2016-04-14
//*************************************************************************
module mem(                          // �ô漶
    input              clk,          // ʱ��
    input              MEM_valid,    // �ô漶��Ч�ź�
    input      [156:0] EXE_MEM_bus_r,// EXE->MEM����
    input      [ 31:0] dm_rdata,     // �ô������
    output     [ 31:0] dm_addr,      // �ô��д��ַ
    output reg [  3:0] dm_wen,       // �ô�дʹ��
    output reg [ 31:0] dm_wdata,     // �ô�д����
    output             MEM_over,     // MEMģ��ִ�����
    output     [118:0] MEM_WB_bus,   // MEM->WB����
    
    //5����ˮ�����ӿ�
    input              MEM_allow_in, // MEM�������¼�����
    output     [  4:0] MEM_wdest,    // MEM��Ҫд�ؼĴ����ѵ�Ŀ���ַ��
     
    //չʾPC
    output     [ 31:0] MEM_pc
);
//-----{EXE->MEM����}begin
    //�ô���Ҫ�õ���load/store��Ϣ
    wire [5 :0] mem_control;  //MEM��Ҫʹ�õĿ����ź�
    wire [31:0] store_data;   //store�����Ĵ������
    
    //EXE�����HI/LO����
    wire [31:0] exe_result;
    wire [31:0] lo_result;
    wire        hi_write;
    wire        lo_write;
    
    //д����Ҫ�õ�����Ϣ
    wire mfhi;
    wire mflo;
    wire mtc0;
    wire mfc0;
    wire [7 :0] cp0r_addr;
    wire       syscall;   //syscall��eret��д�ؼ�������Ĳ��� 
    wire       eret;
    wire       break;
    wire       rf_wen;    //д�صļĴ���дʹ��
    wire [4:0] rf_wdest;  //д�ص�Ŀ�ļĴ���
    
    //pc
    wire [31:0] pc;    
    assign {mem_control,
            store_data,
            exe_result,
            lo_result,
            hi_write,
            lo_write,
            mfhi,
            mflo,
            mtc0,
            mfc0,
            cp0r_addr,
            syscall,
            eret,
            rf_wen,
            rf_wdest,
            pc,
            break         } = EXE_MEM_bus_r;  
//-----{EXE->MEM����}end

//-----{load/store�ô�}begin
    wire inst_load;  //load����
    wire inst_store; //store����
    wire [2:0] ls_word;    //load/storeΪ�ֽڻ�����,0:byte;1:word
    wire lb_sign;    //loadһ�ֽ�Ϊ�з���load
    assign {inst_load,inst_store,ls_word,lb_sign} = mem_control;

    //�ô��д��ַ
    assign dm_addr = exe_result;
    
    //store������дʹ��
    always @ (*)    // �ڴ�дʹ���ź�
    begin
        if (MEM_valid && inst_store) // �ô漶��Чʱ,��Ϊstore����
        begin
            case (ls_word[2:0])
                3'd0:       // SB
                    begin // SBָ���Ҫ���ݵ�ַ����λ��ȷ����Ӧ��дʹ��
                        case (dm_addr[1:0])
                            2'b00   : dm_wen <= 4'b0001;
                            2'b01   : dm_wen <= 4'b0010;
                            2'b10   : dm_wen <= 4'b0100;
                            2'b11   : dm_wen <= 4'b1000;
                            default : dm_wen <= 4'b0000;
                        endcase
                    end
                3'd1:       // SW
                begin  // SWָ��
                    if(dm_addr[1:0])
                    begin
                        $display("Error: unaligned address!");
                        // ades <= 1;// ��ַ��� 2 λ��Ϊ 0��������ַ������ades
                        dm_wen <= 4'b0000;
                    end
                    else
                    begin
                        dm_wen <= 4'b1111; // �洢��ָ�дʹ��ȫ1
                    end
                end
                3'd2:       // SH
                    begin // SHָ���Ҫ���ݵ�ַ����λ��ȷ����Ӧ��дʹ��
                        if(dm_addr[0])
                        begin
                            $display("Error: unaligned address!");
                            // ades <= 1;// ��ַ��� 1 λ��Ϊ 0��������ַ������ades
                            dm_wen <= 4'b0000;
                        end
                        else
                        begin
                            case (dm_addr[1])
                                1'b0   : dm_wen <= 4'b0011;
                                1'b1   : dm_wen <= 4'b1100;
                                default : dm_wen <= 4'b0000;
                            endcase
                        end
                    end
                3'd3:       // SWL
                    case (dm_addr[1:0])
                        2'b00   : dm_wen <= 4'b1000;
                        2'b01   : dm_wen <= 4'b1100;
                        2'b10   : dm_wen <= 4'b1110;
                        2'b11   : dm_wen <= 4'b1111;
                        default : dm_wen <= 4'b0000;
                    endcase
                3'd4:       // SWR
                    case (dm_addr[1:0])
                        2'b00   : dm_wen <= 4'b1111;
                        2'b01   : dm_wen <= 4'b0111;
                        2'b10   : dm_wen <= 4'b0011;
                        2'b11   : dm_wen <= 4'b0001;
                        default : dm_wen <= 4'b0000;
                    endcase
                default: dm_wen <= 4'b0000;
            endcase
        end   
    end 
    
    //store������д����
    always @ (*)  
    begin
        case (ls_word[2:0])
            3'd0:       // ����SBָ���Ҫ���ݵ�ַ����λ���ƶ�store���ֽ�����Ӧλ��
            begin
                case (dm_addr[1:0])
                    2'b00   : dm_wdata <= store_data;
                    2'b01   : dm_wdata <= {16'd0, store_data[7:0], 8'd0};
                    2'b10   : dm_wdata <= {8'd0, store_data[7:0], 16'd0};
                    2'b11   : dm_wdata <= {store_data[7:0], 24'd0};
                    default : dm_wdata <= store_data;
                endcase
            end
            3'd1:       // SW
            begin
                dm_wdata <= store_data;
            end
            3'd2:       // SH
            begin
                case (dm_addr[1])
                    1'b0   : dm_wdata <= {16'd0,store_data[15:0]};
                    1'b1   : dm_wdata <= {store_data[7:0], 16'd0};
                    default : dm_wdata <= store_data;
                endcase
            end
            3'd3:       // SWL
            begin
                case (dm_addr[1:0])
                    2'b00   : dm_wdata <= {dm_rdata[31:8], store_data[31:24]};
                    2'b01   : dm_wdata <= {dm_rdata[31:16], store_data[31:16]};
                    2'b10   : dm_wdata <= {dm_rdata[31:24], store_data[31:8]};
                    2'b11   : dm_wdata <= {store_data[31:0]};
                    default : dm_wdata <= store_data;
                endcase
            end
            3'd4:       // SWR
            begin
                case (dm_addr[1:0])
                    2'b00   : dm_wdata <= {store_data[31:0]};
                    2'b01   : dm_wdata <= {store_data[23:0],dm_rdata[7:0]};
                    2'b10   : dm_wdata <= {store_data[15:0],dm_rdata[15:0]};
                    2'b11   : dm_wdata <= {store_data[7:0],dm_rdata[23:0]};
                    default : dm_wdata <= store_data;
                endcase
            end
            default: dm_wdata <= store_data;
        endcase
        
    end
    
    //load����������
    // wire        load_sign;
    reg [31:0] load_result;
    always @(*) begin
        case (ls_word[2:0])
            3'd0:       // LB/LBU
                case (dm_addr[1:0])
                    2'd0: load_result <= {{24{lb_sign & dm_rdata[7]}}, dm_rdata[ 7:0 ]};
                    2'd1: load_result <= {{24{lb_sign & dm_rdata[15]}}, dm_rdata[15:8 ]};
                    2'd2: load_result <= {{24{lb_sign & dm_rdata[23]}}, dm_rdata[23:16]};
                    default: load_result <= {{24{lb_sign & dm_rdata[31]}}, dm_rdata[31:24]};
                endcase
            3'd1:       // LW
                if (dm_addr[1:0] == 2'b0) begin
                    // ���ݵ�ַ�ĵڶ�λ��ȷ���Ӵ洢���ж�ȡ�������ֽڣ�����չ��32λ
                    load_result <= dm_rdata;               
                end else begin
                    // ��ַ�����룬������쳣����
                    $display("Error: unaligned address!");
                end 
            3'd2:       // LH/LHU
                if (dm_addr[0] == 1'b0) begin
                    // ���ݵ�ַ�ĵڶ�λ��ȷ���Ӵ洢���ж�ȡ�������ֽڣ�����չ��32λ
                    case (dm_addr[1])
                        1'b0: load_result <= {{16{dm_rdata[15] & lb_sign}} , dm_rdata[15:0]}; // ��ȡ�������ֽڲ�������չ
                        1'b1: load_result <= {{16{dm_rdata[31] & lb_sign}} , dm_rdata[31:16]}; // ��ȡ�������ֽڲ�������չ
                    endcase 
                end else begin
                    // ��ַ�����룬������쳣����
                    $display("Error: unaligned address!");
                end 
            3'd3:       // LWL
                case (dm_addr[1:0])
                    2'd0: load_result <= {dm_rdata[ 7:0 ], store_data[23:0]};
                    2'd1: load_result <= {dm_rdata[15:0 ], store_data[15:0]};
                    2'd2: load_result <= {dm_rdata[23:0 ], store_data[7:0] };
                    default: load_result <= {dm_rdata[31:0]};
                endcase
            3'd4:       // LWR
                case (dm_addr)
                    2'd0: load_result <= {dm_rdata[31:0 ]};
                    2'd1: load_result <= {store_data[31:24], dm_rdata[31:8]};
                    2'd2: load_result <= {store_data[31:16], dm_rdata[31:16]};
                    default: load_result <= {store_data[31:8], dm_rdata[31:24]};
                endcase
            default: load_result <= dm_rdata; 
        endcase
    end
    // assign load_sign = ls_word[2:0] == 3'd0 ? 
    //                         ((dm_addr[1:0]==2'd0) ? dm_rdata[ 7] :
    //                         (dm_addr[1:0]==2'd1) ? dm_rdata[15] :
    //                         (dm_addr[1:0]==2'd2) ? dm_rdata[23] : dm_rdata[31]):
    //                         (dm[1] == 1'b0 ? dm_rdata[15] : dm_rdata[31]);
    // assign load_result[7:0] = (dm_addr[1:0]==2'd0) ? dm_rdata[ 7:0 ] :
    //                           (dm_addr[1:0]==2'd1) ? dm_rdata[15:8 ] :
    //                           (dm_addr[1:0]==2'd2) ? dm_rdata[23:16] :
    //                                                  dm_rdata[31:24] ;
    // assign load_result[31:8]= ls_word[2:0] == 3'd1 ? dm_rdata[31:8] :           // LW
    //                           ls_word[2:0] == 3'd0 ?{24{lb_sign & load_sign}}:  // LB/LBU
    //                           ;
//-----{load/store�ô�}end

//-----{MEMִ�����}begin
    //��������RAMΪͬ����д��,
    //�ʶ�loadָ�ȡ����ʱ����һ����ʱ
    //������ַ����һ��ʱ�Ӳ��ܵõ�load������
    //��mem�ڽ���load����ʱ����Ҫ����ʱ�����ȡ������
    //����������������ֻ��Ҫһ��ʱ��
    reg MEM_valid_r;
    always @(posedge clk)
    begin
        if (MEM_allow_in)
        begin
            MEM_valid_r <= 1'b0;
        end
        else
        begin
            MEM_valid_r <= MEM_valid;
        end
    end
    assign MEM_over = inst_load ? MEM_valid_r : MEM_valid;
    //�������ramΪ�첽���ģ���MEM_valid����MEM_over�źţ�
    //��loadһ�����
//-----{MEMִ�����}end

//-----{MEMģ���destֵ}begin
   //ֻ����MEMģ����Чʱ����д��Ŀ�ļĴ����Ų�������
    assign MEM_wdest = rf_wdest & {5{MEM_valid}};
//-----{MEMģ���destֵ}end

//-----{MEM->WB����}begin
    wire [31:0] mem_result; //MEM����WB��resultΪload�����EXE���
    assign mem_result = inst_load ? load_result : exe_result;
    
    assign MEM_WB_bus = {rf_wen,rf_wdest,                   // WB��Ҫʹ�õ��ź�
                         mem_result,                        // ����Ҫд�ؼĴ���������
                         lo_result,                         // �˷���32λ�����������̣�����
                         hi_write,lo_write,                 // HI/LOдʹ�ܣ�����
                         mfhi,mflo,                         // WB��Ҫʹ�õ��ź�,����
                         mtc0,mfc0,cp0r_addr,syscall,eret,  // WB��Ҫʹ�õ��ź�,����
                         pc,                                // PCֵ
                         break};                            // WB��Ҫʹ�õ��ź�,����
//-----{MEM->WB����}begin

//-----{չʾMEMģ���PCֵ}begin
    assign MEM_pc = pc;
//-----{չʾMEMģ���PCֵ}end
endmodule

