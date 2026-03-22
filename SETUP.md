# 🔧 Guia de Configuração do Ambiente de Laboratório

**Objetivo:** Configurar um laboratório de segurança isolado com Kali Linux (atacante) e Metasploitable 2 (alvo) conectados via rede interna (Host-only).

---

## 📋 Pré-requisitos

### Hardware Mínimo
- **CPU:** Intel/AMD com suporte a virtualização (VT-x/AMD-V habilitado na BIOS)
- **RAM:** Mínimo 8GB (recomendado 16GB+)
- **Disco:** 100GB livre em SSD (melhor desempenho)
- **SO Host:** Windows, macOS ou Linux

### Software Necessário
- [VirtualBox 6.0+](https://www.virtualbox.org/wiki/Downloads) - Hypervisor
- [Kali Linux ISO](https://www.kali.org/get-kali/) - Distribuição atacante
- [Metasploitable 2 OVA](https://docs.rapid7.com/metasploit/metasploitable-2/) - Máquina vulnerável

### Opcional
- [DVWA Docker](https://github.com/digininja/DVWA#docker-container-setup) - Para testes web
- Screenshot tool (para documentar evidências)

---

## 1️⃣ Instalação do VirtualBox

### Windows / macOS / Linux
1. Visite [VirtualBox Downloads](https://www.virtualbox.org/wiki/Downloads)
2. Baixe a versão para seu SO
3. Execute o instalador e siga as instruções padrão
4. **Importante:** Reinicie o computador após a instalação

### Verificação
```bash
VBoxManage --version
# Esperado: 6.1.x ou superior
```

---

## 2️⃣ Criação da Rede Host-Only

A rede Host-only garante que as VMs estejam isoladas da internet, mantendo-as seguras.

### No VirtualBox:
1. Abra **VirtualBox**
2. Vá para **File → Preferences** (ou **VirtualBox → Preferences** no macOS)
3. Clique em **Network**
4. Clique no ícone **+ (Add new NAT Network)**
5. Configure:
   - **Name:** `LabNetwork`
   - **CIDR:** `192.168.56.0/24`
   - **DHCP:** ✅ Habilitado
6. Clique **OK**

### Verificação
- O adaptador `vboxnet0` deve aparecer na lista

---

## 3️⃣ Importação/Criação da Máquina Kali Linux

### Opção A: Criar do Instalador (Recomendado)

#### Passo 1: Criar Máquina Virtual
```
Nome: Kali Linux
Tipo: Linux
Versão: Debian (64-bit)
RAM: 2048 MB (mínimo) ou 4096 MB (recomendado)
Disco: 50 GB (VDI, Dinamicamente Alocado)
```

#### Passo 2: Configurar Rede
1. Clique em **Settings (Configurações)**
2. Vá para **Network**
3. Mude o **Adapter 1** para:
   - **Attached to:** `Host-only Adapter`
   - **Name:** `vboxnet0`
4. Deixe outras configurações no padrão

#### Passo 3: Instalar Kali Linux
1. Attach a ISO do Kali ao drive virtual
2. Inicie a VM e siga o instalador padrão
3. Crie usuário (ex: `kali` / `kali`)
4. Instale com particionamento automático

#### Passo 4: Pós-Instalação
```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar ferramenta essenciais
sudo apt install -y medusa nmap hydra hashcat

# Verificar instalação
medusa --version
nmap --version
```

### Opção B: Usar VM Pré-construída
1. Faça download da imagem pré-construída do Kali (arquivo .ova)
2. No VirtualBox: **File → Import Appliance**
3. Selecione o arquivo .ova
4. Configure conforme passo anterior (network)

---

## 4️⃣ Importação da Máquina Metasploitable 2

### Passo 1: Baixar Metasploitable 2
- Faça download do arquivo `.ova` em: [Rapid7 Downloads](https://information.rapid7.com/metasploitable-2-download.html)

### Passo 2: Importar para VirtualBox
1. **File → Import Appliance**
2. Selecione `Metasploitable.ova`
3. Deixe as configurações padrão
4. Clique **Import**

### Passo 3: Configurar Rede
1. Clique em **Settings** da VM Metasploitable
2. Vá para **Network**
3. Mude o **Adapter 1** para:
   - **Attached to:** `Host-only Adapter`
   - **Name:** `vboxnet0`
4. Deixe outras configurações no padrão

### Passo 4: Verificação
1. Inicie a VM Metasploitable
2. Login padrão: `msfadmin` / `msfadmin`
3. Execute:
   ```bash
   ifconfig
   # Deve mostrar IP na faixa 192.168.56.x
   ```

---

## 5️⃣ Configuração do Kali Linux (Máquina Atacante)

### Passo 1: Verificar Conectividade
Inicie a VM Kali e execute:

```bash
# Verificar IP da Kali
ifconfig
# Deve aparecer algo como: inet 192.168.56.10

# Testar conectividade com Metasploitable
ping 192.168.56.102
# Deve receber respostas PONG
```

**Se não conseguir ping:**
- Verifique se ambas as VMs estão na mesma rede Host-only
- Reinicie as interfaces de rede: `sudo ifdown eth0 && sudo ifup eth0`

### Passo 2: Instalar/Atualizar Ferramentas

```bash
# Atualizar repositórios
sudo apt update && sudo apt upgrade -y

# Instalar Medusa (se não estiver)
sudo apt install -y medusa

# Confirmar instalação
medusa -V
# Esperado: Medusa v2.2.1 ou superior

# Instalar Nmap (se necessário)
sudo apt install -y nmap

# Outras ferramentas úteis
sudo apt install -y hydra john hashcat curl wget git
```

### Passo 3: Clonar Este Repositório

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/projeto-kali-medusa.git
cd projeto-kali-medusa

# Verificar estrutura
ls -la
# Deve listar: README.md, SETUP.md, wordlists/, scripts/, etc.
```

---

## 6️⃣ Validação do Ambiente

Execute este script de validação para confirmar que tudo está funcionando:

```bash
#!/bin/bash

echo "=== VALIDAÇÃO DO AMBIENTE DE LABORATÓRIO ==="
echo ""

# Verificar IP do Kali
echo "[1] IP da Máquina Kali:"
kali_ip=$(hostname -I | awk '{print $1}')
echo "    IP: $kali_ip"
echo ""

# Verificar conectividade com Metasploitable
echo "[2] Verificando conectividade com Metasploitable (192.168.56.102):"
if ping -c 1 192.168.56.102 > /dev/null 2>&1; then
    echo "    ✅ CONECTADO"
else
    echo "    ❌ FALHA - Verifique a configuração de rede"
    exit 1
fi
echo ""

# Verificar Medusa
echo "[3] Verificando Medusa:"
if command -v medusa &> /dev/null; then
    medusa_version=$(medusa -V)
    echo "    ✅ INSTALADO: $medusa_version"
else
    echo "    ❌ NÃO INSTALADO - Execute: sudo apt install medusa"
    exit 1
fi
echo ""

# Verificar Nmap
echo "[4] Verificando Nmap:"
if command -v nmap &> /dev/null; then
    nmap_version=$(nmap -V | head -n1)
    echo "    ✅ INSTALADO: $nmap_version"
else
    echo "    ❌ NÃO INSTALADO - Execute: sudo apt install nmap"
    exit 1
fi
echo ""

# Escanear serviços no Metasploitable
echo "[5] Serviços Disponíveis em Metasploitable:"
nmap -sV --top-ports 20 192.168.56.102 | grep -E "^[0-9]+/tcp"
echo ""

echo "✅ AMBIENTE VALIDADO COM SUCESSO!"
echo "Você está pronto para começar os testes de penetração."
```

**Como usar:**
```bash
# Salvar como validate-lab.sh
nano validate-lab.sh

# Dar permissão de execução
chmod +x validate-lab.sh

# Executar
./validate-lab.sh
```

---

## 7️⃣ Solução de Problemas

### Problema: Ping não funciona entre as VMs
**Solução:**
1. Verifique se adaptadores estão em `Host-only Adapter`
2. Reinicie o VirtualBox e as VMs
3. Verifique firewall do Host (temporariamente desabilite para teste)
4. Tente: `sudo service networking restart` na Kali

### Problema: Medusa não encontra a senha
**Possíveis causas:**
1. Wordlist está vazia
2. IP/porta incorretos
3. Serviço não está rodando (verifique com `nmap -sV`)
4. Senha está fora da wordlist

### Problema: VirtualBox não encontra vboxnet0
**Solução:**
1. File → Preferences → Network → + (recrear a rede)
2. Ou reinstalar VirtualBox
3. Reiniciar o computador

### Problema: Metasploitable não inicia
**Solução:**
1. Verifique se tem RAM disponível
2. Tente resetar a VM: Settings → Reset
3. Reexporte a VM e reimporte

---

## 📊 Mapa da Rede Final

```
┌─────────────────────────────────────┐
│        Host (seu computador)         │
│                                      │
│  ┌────────────────────────────────┐ │
│  │  Rede Virtual Host-only         │ │
│  │  192.168.56.0/24                 │ │
│  │                                  │ │
│  │  ┌──────────────┐  ┌──────────┐ │ │
│  │  │ Kali Linux   │  │Metasploit│ │ │
│  │  │ 192.168.56.10 │  │  2       │ │ │
│  │  │ (Atacante)   └──┤192.168.. │ │ │
│  │  └──────────────┘  │(Alvo)    │ │ │
│  │                    └──────────┘ │ │
│  │                                  │ │
│  └────────────────────────────────┘ │
│  (Isolada da Internet)              │
└─────────────────────────────────────┘
```

---

## ✅ Checklist de Configuração

- [ ] VirtualBox instalado e funcionando
- [ ] Rede Host-only criada (vboxnet0)
- [ ] VM Kali Linux criada/importada
- [ ] VM Metasploitable 2 importada
- [ ] Ambas as VMs com adaptador Host-only
- [ ] Kali consegue fazer ping em Metasploitable
- [ ] Medusa instalado e funcionando na Kali
- [ ] Nmap instalado e funcionando na Kali
- [ ] Repositório clonado na Kali
- [ ] Wordlists e scripts prontos

---

## 🚀 Próximos Passos

Após completar este setup:
1. Leia [TECHNICAL-ANALYSIS.md](TECHNICAL-ANALYSIS.md) para executar os ataques
2. Execute os comandos de teste (Nmap, Medusa)
3. Documente suas evidências em `/images`
4. Consulte [MITIGATION.md](MITIGATION.md) para entender como defender

---

**Última atualização:** 22 de março de 2026
