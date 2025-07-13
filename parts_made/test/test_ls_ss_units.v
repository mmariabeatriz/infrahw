// Teste das unidades LS e SS adaptadas conforme especificação
// Este teste verifica se as unidades LS e SS estão funcionando corretamente
// com os novos sinais de controle de 2 bits

`timescale 1ns / 1ps

module test_ls_ss_units;

    // Sinais para teste da unidade LS
    reg [1:0] ls_control;
    reg [31:0] reg_mdr_out;
    wire [31:0] ls_control_out;
    
    // Sinais para teste da unidade SS
    reg [1:0] ss_control;
    reg [31:0] reg_b_out;
    reg [31:0] reg_mdr_out_ss;
    wire [31:0] ss_control_out;
    
    // Instanciação da unidade LS
    ls uut_ls (
        .LSControl(ls_control),
        .RegMDROut(reg_mdr_out),
        .LSControlOut(ls_control_out)
    );
    
    // Instanciação da unidade SS
    ss uut_ss (
        .RegSSControl(ss_control),
        .RegBOut(reg_b_out),
        .RegMDROut(reg_mdr_out_ss),
        .SSControlOut(ss_control_out)
    );
    
    // Configuração para dump VCD
    initial begin
        $dumpfile("test_ls_ss_units.vcd");
        $dumpvars(0, test_ls_ss_units);
    end
    
    // Testes principais
    initial begin
        $display("=== TESTE DAS UNIDADES LS E SS ADAPTADAS ===");
        
        // === TESTE DA UNIDADE LS ===
        $display("\n=== TESTE DA UNIDADE LS (Load Size) ===");
        
        // Valor de teste na memória
        reg_mdr_out = 32'hAABBCCDD;
        
        // Teste Load Byte (LSControl = 00)
        ls_control = 2'b00;
        #10;
        $display("Load Byte (LSControl=00):");
        $display("  RegMDROut: 0x%h", reg_mdr_out);
        $display("  LSControlOut: 0x%h (esperado: 0x000000DD)", ls_control_out);
        
        // Teste Load Halfword (LSControl = 01)
        ls_control = 2'b01;
        #10;
        $display("Load Halfword (LSControl=01):");
        $display("  RegMDROut: 0x%h", reg_mdr_out);
        $display("  LSControlOut: 0x%h (esperado: 0x0000CCDD)", ls_control_out);
        
        // Teste Load Word (LSControl = 10)
        ls_control = 2'b10;
        #10;
        $display("Load Word (LSControl=10):");
        $display("  RegMDROut: 0x%h", reg_mdr_out);
        $display("  LSControlOut: 0x%h (esperado: 0xAABBCCDD)", ls_control_out);
        
        // === TESTE DA UNIDADE SS ===
        $display("\n=== TESTE DA UNIDADE SS (Store Size) ===");
        
        // Valores de teste
        reg_b_out = 32'h12345678;      // Novo valor a ser salvo
        reg_mdr_out_ss = 32'hAABBCCDD; // Valor antigo na memória
        
        // Teste Store Byte (SSControl = 00)
        ss_control = 2'b00;
        #10;
        $display("Store Byte (SSControl=00):");
        $display("  RegBOut: 0x%h", reg_b_out);
        $display("  RegMDROut: 0x%h", reg_mdr_out_ss);
        $display("  SSControlOut: 0x%h (esperado: 0xAABBCC78)", ss_control_out);
        
        // Teste Store Halfword (SSControl = 01)
        ss_control = 2'b01;
        #10;
        $display("Store Halfword (SSControl=01):");
        $display("  RegBOut: 0x%h", reg_b_out);
        $display("  RegMDROut: 0x%h", reg_mdr_out_ss);
        $display("  SSControlOut: 0x%h (esperado: 0xAABB5678)", ss_control_out);
        
        // Teste Store Word (SSControl = 10)
        ss_control = 2'b10;
        #10;
        $display("Store Word (SSControl=10):");
        $display("  RegBOut: 0x%h", reg_b_out);
        $display("  RegMDROut: 0x%h", reg_mdr_out_ss);
        $display("  SSControlOut: 0x%h (esperado: 0x12345678)", ss_control_out);
        
        // === TESTE DE CASOS EXTREMOS ===
        $display("\n=== TESTE DE CASOS EXTREMOS ===");
        
        // Teste com valores zero
        reg_mdr_out = 32'h00000000;
        reg_b_out = 32'h00000000;
        reg_mdr_out_ss = 32'hFFFFFFFF;
        
        ls_control = 2'b00; // Load byte de zero
        ss_control = 2'b00; // Store byte de zero
        #10;
        $display("Load Byte de zero: 0x%h (esperado: 0x00000000)", ls_control_out);
        $display("Store Byte de zero: 0x%h (esperado: 0xFFFFFF00)", ss_control_out);
        
        // Teste com valores máximos
        reg_mdr_out = 32'hFFFFFFFF;
        reg_b_out = 32'hFFFFFFFF;
        reg_mdr_out_ss = 32'h00000000;
        
        ls_control = 2'b10; // Load word máximo
        ss_control = 2'b10; // Store word máximo
        #10;
        $display("Load Word máximo: 0x%h (esperado: 0xFFFFFFFF)", ls_control_out);
        $display("Store Word máximo: 0x%h (esperado: 0xFFFFFFFF)", ss_control_out);
        
        $display("\n=== TESTE DAS UNIDADES LS E SS CONCLUÍDO ===");
        $finish;
    end
    
endmodule