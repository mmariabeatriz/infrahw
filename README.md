
# Projeto de Infraestrutura de Hardware - 25.1

## Processador MIPS Multiciclo

Este projeto implementa um processador MIPS de 32 bits com arquitetura multiciclo, desenvolvido como parte da disciplina de Infraestrutura de Hardware.

### Características Principais
- **Arquitetura**: MIPS 32 bits multiciclo
- **Tipos de Instrução**: R-type, I-type, J-type
- **Estados da Máquina**: FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK
- **Linguagem**: Verilog HDL
- **Simulação**: Compatível com Icarus Verilog e GTKWave

## Arquitetura
### Estados da Máquina de Estados
1. **FETCH**: Busca a instrução da memória e incrementa o PC
2. **DECODE**: Decodifica a instrução e prepara os operandos
3. **EXECUTE**: Executa a operação específica baseada no tipo de instrução
4. **MEMORY**: Acessa a memória (para instruções load/store)
5. **WRITEBACK**: Escreve o resultado nos registradores

### Componentes Principais
- **Unidade de Controle** (`control_unit.v`): Máquina de estados que coordena toda a execução
- **Datapath**: Conjunto de multiplexadores, registradores e unidades funcionais
- **ULA**: Unidade Lógica e Aritmética de 32 bits
- **Banco de Registradores**: 32 registradores de 32 bits
- **Memória**: Memória unificada para instruções e dados
- **Unidades Aritméticas**: Multiplicação (MULT), Divisão (DIV) com algoritmos especializados
- **Unidades de Processamento**: Load Size (LS), Store Size (SS), Sign Extend (SE)

## Instruções Suportadas
### Instruções Tipo R
- `ADD`: Soma
- `SUB`: Subtração
- `AND`: AND lógico
- `SLT`: Set less than
- `SLL`: Shift left logical
- `SRA`: Shift right arithmetic
- `MULT`: Multiplicação
- `DIV`: Divisão
- `MFHI`: Move from HI
- `MFLO`: Move from LO
- `JR`: Jump register
- `XCHG`: Exchange (troca registradores)

### Instruções Tipo I
- `ADDI`: Add immediate
- `LW`: Load word
- `SW`: Store word
- `LB`: Load byte
- `SB`: Store byte
- `BEQ`: Branch if equal
- `BNE`: Branch if not equal
- `LUI`: Load upper immediate
- `SLLM`: Shift left logical memory

### Instruções Tipo J
- `J`: Jump
- `JAL`: Jump and link

## Estrutura do Projeto

```
infrahw/
├── parts_given/          # Componentes fornecidos
│   ├── Banco_reg.vhd     # Banco de registradores
│   ├── Memoria.vhd       # Memória
│   ├── ula32.vhd         # ULA 32 bits
│   └── instrucoes.mif    # Arquivo de instruções
├── parts_made/           # Componentes implementados
│   ├── control_unit.v    # Unidade de controle principal
│   ├── mult.v            # Unidade de multiplicação (algoritmo de Booth)
│   ├── div.v             # Unidade de divisão (subtração sucessiva)
│   ├── ls.v              # Load Size - controle de tamanho de carregamento
│   ├── ss.v              # Store Size - controle de tamanho de armazenamento
│   ├── se.v              # Sign Extend - extensão de sinal 16→32 bits
│   ├── mux/              # Multiplexadores para seleção de dados
│   ├── test/             # Testes organizados por tipo
│   │   ├── complete      # Testes gerais das instruções e exceções
│   │   └── debug         # Testes de debug dos módulos
│   └── *.v               # Outros módulos auxiliares
└── README.md             # Este arquivo
```

## Como testar
### Pré-requisitos
- Icarus Verilog (iverilog)
- GTKWave (para visualização de sinais)
- Make (opcional)

### Testes do Processador MIPS Multiciclo
Este diretório contém os testes especializados para validação completa do processador MIPS.

#### test_complete_processor.v
**Testbench completo do processador MIPS**
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
  - Logs detalhados de cada teste

#### Como executar os testes
##### Compilação
```bash
# Testbench completo (RECOMENDADO)
cd complete
iverilog -o test_complete_processor test_complete_processor.v ../control_unit.v ../mult.v ../div.v ../ls.v ../ss.v ../se.v
```

##### Execução
```bash
# Executar testbench completo (RECOMENDADO)
vvp test_complete_processor
```

##### Análise de sinais (ondas)
```bash
# Visualizar com GTKWave
gtkwave test_complete_processor.vcd
```

#### Arquivos Gerados
- **Executável**: `complete/test_complete_processor`
- **VCD File**: `complete/test_complete_processor.vcd`
- **Logs**: No terminal durante execução

#### Estrutura dos Testes
##### Tasks Comuns
- `reset_system()`: Reinicializa o sistema
- `wait_cycles(n)`: Aguarda n ciclos de clock
- `test_*_instruction()`: Testa tipos específicos de instrução

##### Sinais Monitorados
- **Estados**: `current_state`, `counter`
- **Controle**: `pc_write_enable`, `instruction_write`, `memory_write`, `register_write`
- **MUXes**: `mux_a`, `mux_b`, `mux_alu_1`, `mux_alu_2`, `mux_pc`, etc.
- **ALU**: `alu_control`, `shift_control`
- **Memória**: `load_size_control`, `store_size_control`
- **Registradores especiais**: `hi_write`, `lo_write`
- **Exceções**: `exception_control`

#### Como Criar Novos Testes
##### 1. Estrutura Básica de um Testbench
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

