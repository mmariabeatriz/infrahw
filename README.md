
# Projeto de Infraestrutura de Hardware - 25.1

## Processador MIPS Multiciclo

Este projeto implementa um processador MIPS de 32 bits com arquitetura multiciclo, desenvolvido como parte da disciplina de Infraestrutura de Hardware.

## Visão Geral
O processador implementa uma versão simplificada da arquitetura MIPS com suporte a instruções básicas dos tipos R, I e J. A implementação utiliza uma máquina de estados finita para controlar a execução das instruções em múltiplos ciclos de clock.

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
│   ├── cpu.v             # Top-level do processador
│   ├── mux/              # Multiplexadores
│   ├── test/             # Testes organizados por tipo
│   │   ├── r-type/       # Testes para instruções R
│   │   ├── i-type/       # Testes para instruções I
│   │   ├── j-type/       # Testes para instruções J
│   │   └── states/       # Testes de estados
│   └── *.v               # Outros módulos auxiliares
└── README.md             # Este arquivo
```

## Como Usar
### Pré-requisitos
- Icarus Verilog (iverilog)
- GTKWave (para visualização de sinais)
- Make (opcional)

### Compilação e Simulação
1. **Navegar para o diretório de testes:**
   ```bash
   cd parts_made/test/
   ```

2. **Executar testes específicos:**
   ```bash
   # Teste de instruções R-type
   cd r-type
   make
   ./test_r_type
   
   # Teste de instruções I-type
   cd ../i-type
   make
   ./test_i_type
   
   # Teste de instruções J-type
   cd ../j-type
   make
   ./test_j_type
   ```

3. **Visualizar sinais:**
   ```bash
   gtkwave test_*.vcd
   ```

### Sinais Importantes para Monitoramento
- `current_state`: Estado atual da máquina
- `counter`: Contador de ciclos
- `pc_write`: Habilitação de escrita no PC
- `reg_wr`: Habilitação de escrita nos registradores
- `memory_wr`: Habilitação de escrita na memória
- `mux_pc`: Seletor do próximo PC
- `ula`: Código de operação da ULA
- `opcode`: Código da instrução atual

## Testes
O projeto inclui uma suíte abrangente de testes:

- **Testes por Tipo de Instrução**: Verificam o funcionamento correto de cada categoria
- **Testes de Estados**: Validam as transições da máquina de estados
- **Cobertura**: Todos os tipos de instrução e casos especiais

### Executando Todos os Testes
```bash
cd parts_made/test/

# Executar todos os testes
for dir in r-type i-type j-type; do
    cd $dir
    make && ./test_${dir//-/_}
    cd ..
done
```

## Resultados
Todos os testes foram executados com sucesso, confirmando:

✅ Funcionamento correto de todas as instruções R-type  
✅ Funcionamento correto de todas as instruções I-type  
✅ Funcionamento correto de todas as instruções J-type  
✅ Transições corretas da máquina de estados  
✅ Controle adequado dos sinais de datapath  

## Desenvolvimento
### Arquivos Principais

- `control_unit.v`: Implementação da máquina de estados principal
- `cpu.v`: Integração de todos os componentes
- `mux/*.v`: Multiplexadores para seleção de dados
- `test/*.v`: Testbenches para validação

## Notas Técnicas
- A ULA opera com códigos 000 (inicial), 001 (soma) e 010 (subtração)
- O comportamento de alternância da ULA entre 000 e 001 é esperado
- Instruções JAL salvam PC+4 no registrador $ra (31)
- Branches calculam endereço como PC + 4 + offset

---

**Disciplina**: Infraestrutura de Hardware  
**Período**: 2025.1  
**Arquitetura**: MIPS 32 bits Multiciclo