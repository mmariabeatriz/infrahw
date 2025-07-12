# Testes das Instruções R-type

Este diretório contém os testes para as instruções R-type do processador MIPS.

## Arquivos de Teste

1. **test_r_type.v** - Teste básico de todas as instruções R-type individuais
2. **test_r_type_comprehensive.v** - Teste abrangente com sequências de instruções completas

## Como Executar os Testes

### Teste Básico (test_r_type.v)
```bash
iverilog -o test_r_type test_r_type.v ../../../control_unit.v
vvp test_r_type
```

### Teste Abrangente (test_r_type_comprehensive.v)
```bash
iverilog -o test_r_type_comprehensive test_r_type_comprehensive.v ../../../control_unit.v
vvp test_r_type_comprehensive
```

## Sinais para Visualização no GTKWave

Para uma análise completa das instruções R-type, adicione os seguintes sinais no GTKWave:

### Sinais de Entrada
- `clk` - Clock do sistema
- `reset_in` - Sinal de reset
- `opcode[5:0]` - Código da operação
- `immediate[15:0]` - Campo imediato (contém funct para R-type)
- `overflow` - Sinal de overflow
- `mult_stop` - Sinal de parada da multiplicação
- `div_stop` - Sinal de parada da divisão
- `div_zero` - Sinal de divisão por zero

### Sinais de Controle da ULA
- `ula[2:0]` - Controle da ULA
- `shift[2:0]` - Controle do shifter
- `mux_ula1[1:0]` - Seleção da entrada A da ULA
- `mux_ula2[1:0]` - Seleção da entrada B da ULA

### Sinais de Controle dos Registradores
- `reg_wr` - Habilitação de escrita nos registradores
- `mux_register_wr[1:0]` - Seleção do registrador de destino
- `mux_register_wd[2:0]` - Seleção dos dados a serem escritos

### Sinais de Controle de Multiplicação/Divisão
- `mult_init` - Inicialização da multiplicação
- `div_init` - Inicialização da divisão
- `high_load` - Carregamento do registrador HI
- `low_load` - Carregamento do registrador LO
- `mux_high` - Seleção da entrada do registrador HI
- `mux_low` - Seleção da entrada do registrador LO

### Sinais de Controle de Shift
- `mux_shift_src` - Seleção da fonte do shift
- `mux_shift_amt[1:0]` - Seleção da quantidade de shift

### Sinais de Controle de Memória e PC
- `pc_write` - Habilitação de escrita no PC
- `mux_pc[1:0]` - Seleção da próxima instrução do PC
- `a_load` - Carregamento do registrador A
- `b_load` - Carregamento do registrador B
- `ula_out_load` - Carregamento da saída da ULA

### Sinais de Controle de Endereçamento
- `mux_address[2:0]` - Seleção do endereço de memória
- `address_rg_load` - Carregamento do registrador de endereço

## Instruções R-type Testadas

### Operações Aritméticas
- **ADD** (funct: 100000) - Adição com overflow
- **ADDU** (funct: 100001) - Adição sem overflow
- **SUB** (funct: 100010) - Subtração com overflow
- **SUBU** (funct: 100011) - Subtração sem overflow
- **MULT** (funct: 011000) - Multiplicação
- **DIV** (funct: 011010) - Divisão

### Operações Lógicas
- **AND** (funct: 100100) - E lógico
- **OR** (funct: 100101) - OU lógico
- **XOR** (funct: 100110) - OU exclusivo
- **NOR** (funct: 100111) - NÃO OU

### Operações de Comparação
- **SLT** (funct: 101010) - Set Less Than (com sinal)
- **SLTU** (funct: 101011) - Set Less Than (sem sinal)

### Operações de Shift
- **SLL** (funct: 000000) - Shift Left Logical
- **SRL** (funct: 000010) - Shift Right Logical
- **SRA** (funct: 000011) - Shift Right Arithmetic
- **SLLV** (funct: 000100) - Shift Left Logical Variable
- **SRLV** (funct: 000110) - Shift Right Logical Variable
- **SRAV** (funct: 000111) - Shift Right Arithmetic Variable

### Operações de Movimentação
- **MFHI** (funct: 010000) - Move From HI
- **MFLO** (funct: 010010) - Move From LO

### Operações de Controle
- **JR** (funct: 001000) - Jump Register

### Operações Especiais
- **XCHG** (funct: 000101) - Exchange (troca de registradores)

## Valores Esperados dos Sinais de Controle

### Para Operações Aritméticas/Lógicas Padrão
- `mux_ula1 = 00` (entrada A da ULA vem do registrador rs)
- `mux_ula2 = 00` (entrada B da ULA vem do registrador rt)
- `mux_register_wr = 01` (escreve no registrador rd)
- `mux_register_wd = 000` (dados vêm da saída da ULA)
- `reg_wr = 1` (habilita escrita no registrador)

### Para Operações de Shift
- `mux_shift_src` varia conforme a fonte dos dados
- `mux_shift_amt` varia conforme a fonte da quantidade de shift
- `shift[2:0]` define o tipo de operação de shift

### Para MULT/DIV
- `mult_init = 1` para MULT
- `div_init = 1` para DIV
- `reg_wr = 0` (não escreve diretamente nos registradores)

### Para MFHI/MFLO
- `mux_register_wd = 001` para MFHI (dados vêm do registrador HI)
- `mux_register_wd = 010` para MFLO (dados vêm do registrador LO)
- `reg_wr = 1`

### Para JR
- `mux_pc = 10` (PC vem do registrador rs)
- `pc_write = 1`
- `reg_wr = 0`

## Observações Importantes

1. **Timing**: Cada instrução R-type passa pelos estados FETCH, DECODE, EXECUTE e WRITEBACK
2. **Multiplicação/Divisão**: São operações que podem levar múltiplos ciclos
3. **Shifts**: Podem usar quantidade imediata (shamt) ou variável (registrador)
4. **XCHG**: Operação especial que troca o conteúdo de dois registradores

## Análise dos Resultados

Ao visualizar no GTKWave, observe:
1. A progressão através dos estados da máquina de estados
2. Os valores corretos dos sinais de controle para cada instrução
3. O timing correto dos sinais de load e write
4. A correta seleção dos multiplexadores para cada tipo de operação