# mips 编译器
# Author :YokDen
# Time   :2023/3

def translate(code: str):
    code = code.lower().split()
    for i, num in enumerate(code[1:]):
        code[i + 1] = str(bin(int(num)))[2:]
    tmp = ''
    if code[0] == "add":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100000"
    elif code[0] == "addi":
        tmp = f"001000{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "addu":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100001"
    elif code[0] == "addiu":
        tmp = f"001001{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "sub":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100010"
    elif code[0] == "subu":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100011"
    elif code[0] == "slt":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000101010"
    elif code[0] == "slti":
        tmp = f"001010{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "sltu":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000101011"
    elif code[0] == "sltiu":
        tmp = f"001011{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "div":
        tmp = f"000000{code[1].zfill(5) + code[2].zfill(5)}0000000000011010"
    elif code[0] == "divu":
        tmp = f"000000{code[1].zfill(5) + code[2].zfill(5)}0000000000011011"
    elif code[0] == "mult":
        tmp = f"000000{code[1].zfill(5) + code[2].zfill(5)}0000000000011000"
    elif code[0] == "multu":
        tmp = f"000000{code[1].zfill(5) + code[2].zfill(5)}0000000000011001"

    elif code[0] == "and":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100100"
    elif code[0] == "andi":
        tmp = f"001100{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "lui":
        tmp = f"00111100000{code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "nor":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100111"
    elif code[0] == "or":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100101"
    elif code[0] == "ori":
        tmp = f"001101{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "xor":
        tmp = f"000000{code[2].zfill(5) + code[3].zfill(5) + code[1].zfill(5)}00000100110"
    elif code[0] == "xori":
        tmp = f"001110{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(16)}"

    elif code[0] == "sllv":
        tmp = f"000000{code[3].zfill(5) + code[2].zfill(5) + code[1].zfill(5)}00000000100"
    elif code[0] == "sll":
        tmp = f"00000000000{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(5)}000000"
    elif code[0] == "srav":
        tmp = f"000000{code[3].zfill(5) + code[2].zfill(5) + code[1].zfill(5)}00000000111"
    elif code[0] == "sra":
        tmp = f"00000000000{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(5)}000011"
    elif code[0] == "srlv":
        tmp = f"000000{code[3].zfill(5) + code[2].zfill(5) + code[1].zfill(5)}00000000110"
    elif code[0] == "srl":
        tmp = f"00000000000{code[2].zfill(5) + code[1].zfill(5) + code[3].zfill(5)}000010"

    elif code[0] == "beq":
        tmp = f"000100{code[1].zfill(5) + code[2].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "bne":
        tmp = f"000101{code[1].zfill(5) + code[2].zfill(5) + code[3].zfill(16)}"
    elif code[0] == "bgez":
        tmp = f"000001{code[1].zfill(5)}00001{code[2].zfill(16)}"
    elif code[0] == "bgtz":
        tmp = f"000111{code[1].zfill(5)}00000{code[2].zfill(16)}"
    elif code[0] == "blez":
        tmp = f"000110{code[1].zfill(5)}00000{code[2].zfill(16)}"
    elif code[0] == "bltz":
        tmp = f"000001{code[1].zfill(5)}00000{code[2].zfill(16)}"
    elif code[0] == "bgezal":
        tmp = f"000001{code[1].zfill(5)}10001{code[2].zfill(16)}"
    elif code[0] == "bltzal":
        tmp = f"000001{code[1].zfill(5)}10000{code[2].zfill(16)}"
    elif code[0] == "j":
        tmp = f"000010{code[1].zfill(26)}"
    elif code[0] == "jal":
        tmp = f"000011{code[1].zfill(26)}"
    elif code[0] == "jr":
        tmp = f"000000{code[1].zfill(5)}000000000000000001000"
    elif code[0] == "jalr":
        tmp = f"000000{code[2].zfill(5)}00000{code[1].zfill(5)}00000001001"

    elif code[0] == "mfhi":
        tmp = f"0000000000000000{code[1].zfill(5)}00000010000"
    elif code[0] == "mflo":
        tmp = f"0000000000000000{code[1].zfill(5)}00000010010"
    elif code[0] == "mthi":
        tmp = f"000000{code[1].zfill(5)}000000000000000010001"
    elif code[0] == "mtlo":
        tmp = f"000000{code[1].zfill(5)}000000000000000010011"

    elif code[0] == "break":
        tmp = f"00000000000000000000000000001101"
    elif code[0] == "syscall":
        tmp = f"00000000000000000000000000001100"

    elif code[0] == "lb":
        tmp = f"100000{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lbu":
        tmp = f"100100{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lh":
        tmp = f"100001{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lhu":
        tmp = f"100101{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lw":
        tmp = f"100011{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lwl":
        tmp = f"100010{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "lwr":
        tmp = f"100110{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "sb":
        tmp = f"101000{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "sh":
        tmp = f"101001{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "sw":
        tmp = f"101011{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "swl":
        tmp = f"101010{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"
    elif code[0] == "swr":
        tmp = f"101110{code[3].zfill(5) + code[1].zfill(5) + code[2].zfill(16)}"

    elif code[0] == "eret":
        tmp = f"01000010000000000000000000011000"
    elif code[0] == "mfc0":
        tmp = f"01000000000{code[1].zfill(5) + code[2].zfill(5)}00000000{code[3].zfill(3)}"
    elif code[0] == "mtc0":
        tmp = f"01000000100{code[1].zfill(5) + code[2].zfill(5)}00000000{code[3].zfill(3)}"

    return tmp


def main():
    codes = """
            sll 0 0 0 
            addiu 1 0 17
            sll 2 1 4
            addu 3 2 1
            addu 3 2 1
            slt 4 1 2 
            slti 5 4 0
            subu 6 3 4
            subu 6 3 4
            multu 1 2
            divu 6 2
            lui 7 65535
            sra 8 7 4
            sra 8 7 4
            sllv 9 7 4
            srav 10 7 4
            srl 11 7 4
            srlv 12 7 4
            mfhi 13
            mflo 14
            mthi 7 
            mtlo 7 
            srl 7 11 12
            lui 15 4660
            addiu 16 15 22136
            and 17 7 16
            and 17 7 16
            andi 18 7 4660
            or 19 7 16
            ori 20 7 4660
            nor 21 7 16
            xor 22 7 16
            xori 23 7 4660
            mult 8 1
            div 8 6
            add 24 11 12
            addi 25 8 65535
            syscall
            lw 26 24 0
            jal 55
            break
            """
    codes = codes.splitlines()
    print(codes)
    for code in codes:
        code = code.strip()
        if code:
            tmp = translate(code)
            if len(tmp) == 32:
                print(hex(eval('0b'+tmp))[2:].upper().zfill(8))
                # print(tmp)
            else:
                print("指令错误")


if __name__ == "__main__":
    main()


