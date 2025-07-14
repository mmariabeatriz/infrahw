# Testes do Processador MIPS Multiciclo
Este diretório contém os testes especializados para validação completa do processador MIPS. Os testes foram organizados de forma modular por tipo de instrução.

## Status dos Arquivos de Teste

- `complete/test_complete_processor.v` - **Testbench completo e abrangente**

### 1. test_r_type.v
**Teste específico p/ instruções R-type**
- **Cobertura**:
  - Operações aritméticas (ADD, SUB, SLT)
  - Operações lógicas (AND)
  - Operações de shift (SLL, SRA)
  - Operações especiais (JR, MFHI, MFLO, MULT, DIV, XCHG)
  - Verificação de sinais de controle específicos

### 2. test_i_type.v
**Teste específico p/ instruções I-type**
- **Cobertura**:
  - Operações aritméticas imediatas (ADDI)
  - Instruções de load (LW, LB)
  - Instruções de store (SW, SB)
  - Instruções de branch (BEQ, BNE)
  - Instruções especiais (LUI, SLLM)
  - Verificação de extensão de sinal e MUXes

### 3. test_j_type.v
**Teste específico p/ instruções J-type**
- **Propósito**: Teste focado exclusivamente em instruções J-type
- **Cobertura**:
  - Jump incondicional (J)
  - Jump and Link (JAL)
  - Verificação de endereçamento
  - Sequências de estados específicas
  - Timing e múltiplos jumps consecutivos

### 4. test_complete_processor.v
**Testbench completo e abrangente do processador MIPS**
- **Localização**: `complete/test_complete_processor.v`
- **Propósito**: Teste integrado de todas as funcionalidades do processador
- **Cobertura completa**:
  - **Instruções R-type**: ADD, SUB, AND, SLT, SLL, SRA, MULT, DIV, MFHI, MFLO, JR
  - **Instruções I-type**: ADDI, LUI, LW, LB, SW, SB, BEQ, BNE, SLLM
  - **Instruções J-type**: J, JAL
  - **Tratamento de exceções**: Overflow, Divisão por Zero, Opcode Inválido
  - **Módulos auxiliares**: Load Size (ls.v), Store Size (ss.v), Sign Extend (se.v)
- **Características**:
  - Testa todos os 27 casos implementados
  - Instancia todos os módulos do processador
  - Verifica sinais de controle e transições de estado
  - Execução controlada sem loops infinitos
  - Logs detalhados de cada teste

## Como Executar os Testes
### Compilação
```bash
# Teste R-type
cd R-type
iverilog -o test_r_type test_r_type.v ../../control_unit.v

# Teste I-type
cd ../I-type
iverilog -o test_i_type test_i_type.v ../../control_unit.v

# Teste J-type
cd ../J-type
iverilog -o test_j_type test_j_type.v ../../control_unit.v

# Testbench completo (RECOMENDADO)
cd complete
iverilog -o test_complete_processor test_complete_processor.v ../control_unit.v ../mult.v ../div.v ../ls.v ../ss.v ../se.v
```

### Execução
```bash
# Executar testes disponíveis
cd R-type && vvp test_r_type
cd ../I-type && vvp test_i_type
cd ../J-type && vvp test_j_type

# Executar testbench completo (RECOMENDADO)
cd complete && vvp test_complete_processor
```

### Análise de sinais (ondas)
```bash
# Visualizar com GTKWave (se disponível)
cd R-type && gtkwave test_r_type.vcd
cd ../I-type && gtkwave test_i_type.vcd
cd ../J-type && gtkwave test_j_type.vcd
cd complete && gtkwave test_complete_processor.vcd
```

## Arquivos Gerados
- **Executáveis**: `R-type/test_r_type`, `I-type/test_i_type`, `J-type/test_j_type`, `complete/test_complete_processor`
- **VCD Files**: `R-type/test_r_type.vcd`, `I-type/test_i_type.vcd`, `J-type/test_j_type.vcd`, `complete/test_complete_processor.vcd`
- **Logs**: No terminal durante execução

## Estrutura dos Testes
### Tasks Comuns
- `reset_system()`: Reinicializa o sistema
- `wait_cycles(n)`: Aguarda n ciclos de clock
- `test_*_instruction()`: Testa tipos específicos de instrução

### Sinais Monitorados
- **Estados**: `current_state`, `counter`
- **Controle**: `pc_write_enable`, `instruction_write`, `memory_write`, `register_write`
- **MUXes**: `mux_a`, `mux_b`, `mux_alu_1`, `mux_alu_2`, `mux_pc`, etc.
- **ALU**: `alu_control`, `shift_control`
- **Memória**: `load_size_control`, `store_size_control`
- **Registradores especiais**: `hi_write`, `lo_write`
- **Exceções**: `exception_control`

## Estados da Máquina
- **FETCH (000)**: Busca da instrução
- **DECODE (001)**: Decodificação da instrução
- **EXECUTE (010)**: Execução da operação
- **MEMORY (011)**: Acesso à memória (load/store)
- **WRITEBACK (100)**: Escrita no banco de registradores

## Como Criar Novos Testes

### 1. Estrutura Básica de um Testbench
```verilog
module test_nome;
    // Declaração de sinais
    reg clk, reset;
    wire [31:0] instruction;
    wire [2:0] current_state;
    
    // Instanciação do módulo a ser testado
    control_unit uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .current_state(current_state)
        // ... outras conexões
    );
    
    // Geração de clock
    always #5 clk = ~clk;
    
    // Bloco inicial de teste
    initial begin
        // Inicialização
        clk = 0;
        reset = 1;
        #10 reset = 0;
        
        // Seus testes aqui
        test_sua_instrucao();
        
        // Finalização
        $finish;
    end
    
    // Tasks para organizar os testes
    task test_sua_instrucao;
        begin
            instruction = 32'h01234567; // Sua instrução
            #20; // Aguardar ciclos
            // Verificações
            if (current_state == 3'b010) begin
                $display("Teste passou!");
            end else begin
                $display("Teste falhou!");
            end
        end
    endtask
endmodule
```

### 2. Passos para Criar um Novo Teste
1. **Defina o objetivo**: Qual funcionalidade será testada?
2. **Identifique os módulos**: Quais módulos precisam ser instanciados?
3. **Declare os sinais**: Entradas (reg) e saídas (wire)
4. **Instancie os módulos**: Conecte os sinais corretamente
5. **Implemente os testes**: Use tasks para organizar
6. **Adicione verificações**: Compare resultados esperados
7. **Compile e execute**: Verifique se funciona corretamente

### 3. Boas Práticas
- Use tasks para organizar diferentes tipos de teste
- Adicione displays informativos para acompanhar a execução
- Verifique sempre os sinais de controle relevantes
- Aguarde ciclos suficientes para a operação completar
- Use nomes descritivos para sinais e tasks
- Documente o propósito de cada teste

### 4. Exemplo de Verificação
```verilog
task verificar_resultado;
    input [31:0] esperado;
    input [31:0] obtido;
    input [50*8:1] nome_teste;
    begin
        if (esperado == obtido) begin
            $display("[PASS] %s: %h == %h", nome_teste, esperado, obtido);
        end else begin
            $display("[FAIL] %s: esperado %h, obtido %h", nome_teste, esperado, obtido);
        end
    end
endtask
```

## Compatibilidade
- Sintaxe Verilog padrão
- Compatível com Icarus Verilog
- Geração de VCD para análise visual
- Testado no Windows com PowerShell