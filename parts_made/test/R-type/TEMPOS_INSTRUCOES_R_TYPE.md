# Tempos de Execução das Instruções R-Type para GTKWave

## Configuração do Clock
- **Período do Clock**: 10ns (5ns HIGH + 5ns LOW)
- **Frequência**: 100MHz
- **Timescale**: 1ns/1ps

## Tempos de Reset
- **Reset Ativo**: 20ns (2 ciclos de clock)
- **Estabilização pós-reset**: 10ns (1 ciclo de clock)
- **Tempo total de reset**: 30ns

## Instruções R-Type e seus Tempos

### 1. Operações Aritméticas Básicas
- **ADD** (funct = 0x20): 4 ciclos = 40ns
- **SUB** (funct = 0x22): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 200ns

### 2. Multiplicação e Recuperação
- **MULT** (funct = 0x18): 4 ciclos + 2 ciclos de espera = 60ns
- **MFHI** (funct = 0x10): 4 ciclos = 40ns
- **MFLO** (funct = 0x12): 4 ciclos = 40ns
- **Sequência completa MULT+MFHI+MFLO**: ~140ns
- **Janela de visualização recomendada**: 0ns - 300ns

### 3. Divisão com Resto
- **DIV** (funct = 0x1A): 4 ciclos + 3 ciclos de espera = 70ns
- **MFLO** (quociente): 4 ciclos = 40ns
- **MFHI** (resto): 4 ciclos = 40ns
- **Sequência completa DIV+MFLO+MFHI**: ~150ns
- **Janela de visualização recomendada**: 0ns - 350ns

### 4. Operações de Deslocamento
- **SLL** (funct = 0x00): 4 ciclos = 40ns
- **SRA** (funct = 0x03): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 150ns

### 5. Operações Lógicas
- **AND** (funct = 0x24): 4 ciclos = 40ns
- **OR** (funct = 0x25): 4 ciclos = 40ns
- **XOR** (funct = 0x26): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 120ns

### 6. Comparação
- **SLT** (funct = 0x2A): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 160ns

### 7. Troca de Valores
- **XCHG** (funct = 0x05): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 120ns

### 8. Salto para Registrador
- **JR** (funct = 0x08): 4 ciclos = 40ns
- **Tempo por instrução**: 40ns
- **Janela de visualização recomendada**: 0ns - 120ns

## Instruções I-Type de Apoio (ADDIU)
- **ADDIU** (opcode = 0x09): 4 ciclos = 40ns
- **Usado para carregar valores nos registradores**

## Cronograma Completo dos Testes

### Teste 1: Operações Aritméticas (ADD/SUB)
- Reset: 0ns - 30ns
- ADDIU $1, $0, 25: 30ns - 70ns
- ADDIU $2, $0, 15: 70ns - 110ns
- ADD $3, $1, $2: 110ns - 150ns
- SUB $4, $1, $2: 150ns - 190ns
- ADD $5, $3, $4: 190ns - 230ns
- **Janela total**: 0ns - 250ns

### Teste 2: Multiplicação (MULT/MFHI/MFLO)
- Reset: 250ns - 280ns
- ADDIU $1, $0, 4: 280ns - 320ns
- ADDIU $2, $0, 3: 320ns - 360ns
- MULT $1, $2: 360ns - 420ns
- MFHI $2: 420ns - 460ns
- MFLO $1: 460ns - 500ns
- **Janela total**: 250ns - 520ns

### Teste 3: Divisão (DIV/MFLO/MFHI)
- Reset: 520ns - 550ns
- ADDIU $1, $0, 17: 550ns - 590ns
- ADDIU $2, $0, 5: 590ns - 630ns
- DIV $1, $2: 630ns - 700ns
- MFLO $3: 700ns - 740ns
- MFHI $4: 740ns - 780ns
- **Janela total**: 520ns - 800ns

### Teste 4: Deslocamento (SLL/SRA)
- Reset: 800ns - 830ns
- ADDIU $1, $0, 8: 830ns - 870ns
- SLL $2, $1, 2: 870ns - 910ns
- ADDIU $3, $0, 0xFFF0: 910ns - 950ns
- SRA $4, $3, 1: 950ns - 990ns
- **Janela total**: 800ns - 1010ns

### Teste 5: Operações Lógicas (AND)
- Reset: 1010ns - 1040ns
- ADDIU $1, $0, 15: 1040ns - 1080ns
- ADDIU $2, $0, 10: 1080ns - 1120ns
- AND $3, $1, $2: 1120ns - 1160ns
- **Janela total**: 1010ns - 1180ns

### Teste 6: Comparação (SLT)
- Reset: 1180ns - 1210ns
- ADDIU $1, $0, 5: 1210ns - 1250ns
- ADDIU $2, $0, 8: 1250ns - 1290ns
- SLT $3, $1, $2: 1290ns - 1330ns
- SLT $4, $2, $1: 1330ns - 1370ns
- SLT $5, $1, $1: 1370ns - 1410ns
- **Janela total**: 1180ns - 1430ns

### Teste 7: Troca de Valores (XCHG)
- Reset: 1430ns - 1460ns
- ADDIU $1, $0, 42: 1460ns - 1500ns
- ADDIU $2, $0, 73: 1500ns - 1540ns
- XCHG $1, $2: 1540ns - 1580ns
- **Janela total**: 1430ns - 1600ns

### Teste 8: Salto para Registrador (JR)
- Reset: 1600ns - 1630ns
- ADDIU $31, $0, 200: 1630ns - 1670ns
- JR $31: 1670ns - 1710ns
- **Janela total**: 1600ns - 1730ns

## Sinais Importantes para Monitoramento no GTKWave

### Sinais Básicos
- `clk`
- `reset`
- `current_state[4:0]`

### Sinais de Controle
- `reg_write`
- `pc_write`
- `mem_write`
- `alu_control[3:0]`

### Campos da Instrução
- `opcode[5:0]`
- `rs[4:0]`
- `rt[4:0]`
- `rd[4:0]`
- `funct[5:0]`
- `shamt[4:0]`

### Multiplexadores
- `reg_dst`
- `alu_src`
- `mem_to_reg`
- `pc_source[1:0]`

### Flags
- `zero_flag`
- `overflow`
- `div_zero`
- `alu_zero`
- `alu_overflow`

## Dicas para Visualização no GTKWave

1. **Configure o zoom** para ver 4-5 ciclos de clock por vez
2. **Use cursores** para medir tempos exatos entre eventos
3. **Agrupe sinais** relacionados (ex: todos os sinais de controle)
4. **Use cores diferentes** para distinguir tipos de sinais
5. **Monitore o estado da máquina** para entender a progressão
6. **Verifique os valores dos registradores** antes e depois das operações

## Pontos Críticos para Verificação

1. **Transições de Estado**: Verificar se a máquina de estados progride corretamente
2. **Sinais de Controle**: Confirmar ativação no momento correto
3. **Multiplicação/Divisão**: Verificar flags de conclusão
4. **Escrita em Registradores**: Confirmar que `reg_write` está ativo no momento certo
5. **PC**: Verificar incremento e saltos corretos