# 📸 Evidências e Capturas de Tela

Nesta pasta devem ser armazenadas as **evidências visuais** dos testes executados.

---

## 📋 Como Organizar

Crie subpastas para organizar as evidências por teste:

```
images/
├── README.md (este arquivo)
├── ftp-brute-force/
│   ├── 01-nmap-ftp-port.png
│   ├── 02-medusa-attack.png
│   └── 03-success.png
├── smb-enumeration/
│   ├── 01-nmap-smb-enum-users.png
│   ├── 02-users-discovered.png
│   └── 03-password-spraying.png
├── dvwa-webform/
│   ├── 01-dvwa-login.png
│   ├── 02-medusa-web-attack.png
│   └── 03-access-gained.png
└── network-setup/
    ├── 01-vms-running.png
    ├── 02-network-config.png
    └── 03-ping-test.png
```

---

## 🎯 Capturas Importantes

### 1️⃣ FTP Brute Force
**O que capturar:**

1. **Nmap discovery de FTP**
   ```
   Screenshot: nmap -sV 192.168.56.102 | grep 21
   Esperado: 21/tcp open ftp vsftpd 2.3.4
   ```

2. **Medusa atacando FTP**
   ```
   Screenshot: medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt -M ftp -v 6
   Esperado: Progress, tentativas de login
   ```

3. **Sucesso do Medusa**
   ```
   Screenshot: ACCOUNT FOUND: [ftp] Host: 192.168.56.102 User: msfadmin Password: msfadmin [SUCCESS]
   Esperado: Mensagem verde de sucesso
   ```

4. **Acesso FTP confirmado**
   ```
   Screenshot: ftp 192.168.56.102
   ftp> ls
   Esperado: Listagem de arquivos FTP
   ```

---

### 2️⃣ SMB Enumeration
**O que capturar:**

1. **Nmap SMB enumeration script**
   ```
   Screenshot: nmap -p 139,445 --script smb-enum-users.nse 192.168.56.102
   Esperado: Lista de usuários descobertos
   ```

2. **Usuários enumerados**
   ```
   Screenshot: Saída com usuários do sistema
   Esperado: msfadmin, root, postgres, etc.
   ```

---

### 3️⃣ SMB Password Spraying
**O que capturar:**

1. **Medusa testando múltiplos usuários**
   ```
   Screenshot: medusa -h 192.168.56.102 -U wordlists/users.txt -p msfadmin -M smbnt -v 6
   Esperado: Progresso das tentativas
   ```

2. **Sucesso de Password Spraying**
   ```
   Screenshot: ACCOUNT FOUND: [smbnt] Host: 192.168.56.102 User: [user] Password: [pass]
   Esperado: Uma ou mais contas descobertas
   ```

---

### 4️⃣ DVWA Web Form Attack (Opcional)
**O que capturar:**

1. **DVWA Login Page**
   ```
   Screenshot: Tela de login do DVWA
   URL: http://192.168.56.11/login.php (ou seu IP local do DVWA)
   ```

2. **Medusa atacando formulário**
   ```
   Screenshot: Execução do Medusa contra web-form
   Esperado: Múltiplas requisições HTTP
   ```

3. **Sucesso de login**
   ```
   Screenshot: Dashboard do DVWA após login bem-sucedido
   Esperado: "Welcome to DVWA"
   ```

4. **Captura Wireshark (opcional)**
   ```
   Screenshot: Tráfego HTTP no Wireshark
   Esperado: POST requests para /login.php com credenciais
   ```

---

### 5️⃣ Network Setup (Validação)
**O que capturar:**

1. **VirtualBox com VMs rodando**
   ```
   Screenshot: Tela principal do VirtualBox
   Esperado: Kali Linux e Metasploitable 2 iniciadas
   ```

2. **Configuração de rede**
   ```
   Screenshot: Settings → Network da VM Kali
   Esperado: Host-only Adapter selecionado
   ```

3. **Teste de conectividade**
   ```
   Screenshot: ping 192.168.56.102 com resposta positiva
   Esperado: Reply from 192.168.56.102
   ```

---

## 🎬 Como Capturar Screenshots

### Windows
- **Ferramenta padrão:** Win + Shift + S (Snipping Tool)
- **Alternativa:** Print Screen + (cole em Paint)

### Linux
```bash
# GNOME/Ubuntu
screenshot  # Abre interface gráfica

# Captura rápida
gnome-screenshot -f screenshot_$(date +%s).png

# Captura com delay
gnome-screenshot -d 3 -f screenshot.png
```

### macOS
```bash
# Captura fullscreen
Cmd + Shift + 3

# Captura seleção
Cmd + Shift + 4

# Captura com ferramenta
Cmd + Shift + 5
```

---

## 🎨 Boas Práticas

✅ **FAZER:**
- Nomes descritivos (`01-nmap-ftp-discovery.png`)
- Extensão `.png` (melhor qualidade)
- Pasta organizada por teste
- Timestamp ou número sequencial

❌ **NÃO FAZER:**
- Nomes genéricos (`screenshot1.png`, `image.jpg`)
- Capturas com dados sensíveis expostos
- Informações de IP real (usar 192.168.x.x)
- Senhas visíveis nos screenshots

---

## 📊 Template de Documento com Evidências

Crie um `EVIDENCIES.md` para documentar:

```markdown
# Evidências dos Testes

## 1. FTP Brute Force

### Descoberta de Serviço
![Nmap FTP]./images/ftp-brute-force/01-nmap-ftp-port.png)

Comando: `nmap -sV 192.168.56.102`
Resultado: FTP (vsftpd 2.3.4) descoberto na porta 21

### Ataque
![Medusa Attack]./images/ftp-brute-force/02-medusa-attack.png)

Comando: `medusa -h 192.168.56.102 -u msfadmin -P wordlists/common-passwords.txt -M ftp`
Tempo: ~35 segundos
Resultado: Sucesso na 5ª tentativa

### Confirmação
![FTP Access]./images/ftp-brute-force/03-ftp-access.png)

Login FTP confirmado: msfadmin / msfadmin
Acesso ao servidor de arquivos obtido
```

---

## 📋 Checklist de Evidências

- [ ] 1 screenshot de network setup (VMs + conectividade)
- [ ] 1 screenshot de Nmap discovery (serviços)
- [ ] 2+ screenshots de FTP attack (início + sucesso)
- [ ] 2+ screenshots de SMB enumeration (usuários)
- [ ] 2+ screenshots de Password Spraying (progress + sucesso)
- [ ] 2+ screenshots de DVWA attack (login + acesso)
- [ ] Nomes de arquivo descritivos
- [ ] Sem informações sensíveis expostas

---

## 🎥 Alternativa: Gravação de Vídeo

Se preferir, pode criar um vídeo demonstrando os testes:

```bash
# Gravar tela com ffmpeg
ffmpeg -f gdigrab -framerate 30 -i desktop -c:v libx264 -crf 0 -preset ultrafast output.mp4

# Gravar com OBS Studio (mais fácil)
# Baixar em: https://obsproject.com/
```

---

## 📤 Fazer Upload para GitHub

```bash
# Adicionar imagens ao git
git add images/

# Commit
git commit -m "Add evidence screenshots"

# Push
git push origin main
```

---

## ✅ Próximos Passos

1. Executar os testes (SETUP.md → TECHNICAL-ANALYSIS.md)
2. Capturar evidências em cada etapa
3. Organizar em subpastas
4. Documentar em EVIDENCIES.md
5. Fazer upload para GitHub
6. Linkar no README.md principal

---

**Última atualização:** 22 de março de 2026
