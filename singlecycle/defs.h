
`ifndef DEFS_H
`define DEFS_H

    `define reset 4
    `define BIT_WIDTH [63:0]
    `define RA 5'd1
    `define IM_INIT_FILE_PATH "./test/Generated/IM_INIT.INIT"
    `define DM_INIT_FILE_PATH "./test/Generated/DM_INIT.INIT"

    `ifndef MEMORY_SIZE
        `define MEMORY_SIZE 8192
    `endif // MEMORY_SIZE

    `ifndef MEMORY_BITS
        `define MEMORY_BITS 13
    `endif // MEMORY_BITS
`endif // DEFS_H
