# Testes do Módulo Control_Unit Refatorado
Este diretório contém os testes especializados para o módulo `control_unit` refatorado. Os testes foram organizados de forma modular.

## Status dos Arquivos de Teste
- `test_states.v` - Teste de estados da máquina
- `test_r_type.v` - Teste de instruções R-type
- `test_i_type.v` - Teste de instruções I-type
- `test_j_type.v` - Teste de instruções J-type

### 1. test_states.v
**Teste específico de estados**
- **Cobertura**:
  - Transições entre estados (FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK)
  - Sequências de estados para diferentes tipos de instrução
  - Contadores internos e timing

### 2. test_r_type.v
**Teste específico p/ instruções R-type**
- **Cobertura**:
  - Operações aritméticas (ADD, SUB, SLT)
  - Operações lógicas (AND)
  - Operações de shift (SLL, SRA)
  - Operações especiais (JR, MFHI, MFLO, MULT, DIV, XCHG)
  - Verificação de sinais de controle específicos

### 3. test_i_type.v
**Teste específico p/ instruções I-type**
- **Cobertura**:
  - Operações aritméticas imediatas (ADDI)
  - Instruções de load (LW, LB)
  - Instruções de store (SW, SB)
  - Instruções de branch (BEQ, BNE)
  - Instruções especiais (LUI, SLLM)
  - Verificação de extensão de sinal e MUXes

### 4. test_j_type.v
**Teste Eespecífico p/ instruções J-type**
- **Propósito**: Teste focado exclusivamente em instruções J-type
- **Cobertura**:
  - Jump incondicional (J)
  - Jump and Link (JAL)
  - Verificação de endereçamento
  - Sequências de estados específicas
  - Timing e múltiplos jumps consecutivos

## Como Executar os Testes
### Compilação
```bash
# Teste de estados
iverilog -o test_states test_states.v ../control_unit.v

# Teste R-type
iverilog -o test_r_type test_r_type.v ../control_unit.v

# Teste I-type
iverilog -o test_i_type test_i_type.v ../control_unit.v

# Teste J-type
iverilog -o test_j_type test_j_type.v ../control_unit.v
```

### Execução
```bash
# Executar testes disponíveis
vvp test_states
vvp test_r_type
vvp test_i_type
vvp test_j_type
```

### Análise de sinais (ondas)
```bash
# Visualizar com GTKWave (se disponível)
gtkwave test_states.vcd
gtkwave test_r_type.vcd
gtkwave test_i_type.vcd
gtkwave test_j_type.vcd
```

## Arquivos Gerados
- **Executáveis**: `test_states`, `test_r_type`, `test_i_type`, `test_j_type`
- **VCD Files**: `test_states.vcd`, `test_r_type.vcd`, `test_i_type.vcd`, `test_j_type.vcd`
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

## Resultados Esperados
### Compilação Bem-sucedida
- Código de saída 0 do iverilog
- Nenhum erro de sintaxe
- Geração dos executáveis

### Execução Bem-sucedida
- Todos os testes reportam "OK"
- Estados corretos em cada fase
- Sinais de controle apropriados
- Nenhuma exceção inesperada

### Compatibilidade
- Sintaxe Verilog padrão
- Compatível com Icarus Verilog
- Geração de VCD para análise visual