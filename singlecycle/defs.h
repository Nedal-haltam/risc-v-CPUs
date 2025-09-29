
`ifndef DEFS_H
`define DEFS_H

    `define reset 4
    `define BIT_WIDTH [63:0]
    `define RA 5'd1
    `ifndef simulate
        `define IM_INIT_FILE_PATH "./test/Generated/IM_INIT.INIT"
        `define DM_INIT_FILE_PATH "./test/Generated/DM_INIT.INIT"
    `else
        `define IM_INIT_FILE_PATH "IM_INIT.INIT"
        `define DM_INIT_FILE_PATH "DM_INIT.INIT"
    `endif // simulate

    `ifndef MEMORY_SIZE
        `define MEMORY_SIZE (8192)
    `endif // MEMORY_SIZE

    `ifndef MEMORY_BITS
        `define MEMORY_BITS (13)
    `endif // MEMORY_BITS

    `define ALU_OPCODE_ADD   (6'd1)
    `define ALU_OPCODE_SUB   (6'd2)
    `define ALU_OPCODE_MUL   (6'd3)
    `define ALU_OPCODE_SLL   (6'd4)
    `define ALU_OPCODE_SLT   (6'd5)
    `define ALU_OPCODE_SEQ   (6'd6)
    `define ALU_OPCODE_SNE   (6'd7)
    `define ALU_OPCODE_SLTU  (6'd8)
    `define ALU_OPCODE_XOR   (6'd9)
    `define ALU_OPCODE_DIV   (6'd10)
    `define ALU_OPCODE_SRL   (6'd11)
    `define ALU_OPCODE_SRA   (6'd12)
    `define ALU_OPCODE_DIVU  (6'd13)
    `define ALU_OPCODE_OR    (6'd14)
    `define ALU_OPCODE_REM   (6'd15)
    `define ALU_OPCODE_AND   (6'd16)
    `define ALU_OPCODE_REMU  (6'd17)

    `define LOAD_BYTE               (4'd1)
    `define LOAD_HALFWORD           (4'd2)
    `define LOAD_WORD               (4'd3)
    `define LOAD_DOUBLEWORD         (4'd4)
    `define LOAD_BYTE_UNSIGNED      (4'd5)
    `define LOAD_HALFWORD_UNSIGNED  (4'd6)

    `define STORE_BYTE        (3'd1)
    `define STORE_HALFWORD    (3'd2)
    `define STORE_WORD        (3'd3)
    `define STORE_DOUBLEWORD  (3'd4)

    `define EXIT_ECALL  (64'd93)

`endif // DEFS_H
