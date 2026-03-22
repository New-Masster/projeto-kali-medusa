# 🛡️ Projeto de Auditoria: Brute Force com Medusa no Kali Linux

## 📖 Sobre o Projeto
Este repositório contém a documentação de um laboratório prático de **Segurança Ofensiva** realizado como parte da formação na [DIO](https://www.dio.me/). O objetivo foi simular ataques de força bruta (Brute Force) e Password Spraying em ambientes controlados para entender vulnerabilidades comuns e aplicar medidas de mitigação.

> ⚠️ **Aviso Ético:** Este projeto foi realizado estritamente em ambiente de laboratório (Rede Interna/Host-only) utilizando as máquinas virtuais **Kali Linux** e **Metasploitable 2**. Jamais utilize estas técnicas em sistemas sem autorização prévia.

---

## 🛠️ Tecnologias e Ferramentas
- **Sistema Atacante:** Kali Linux
- **Alvos Vulneráveis:** Metasploitable 2 / DVWA (Damn Vulnerable Web App)
- **Ferramentas Utilizadas:**
  - `Nmap`: Mapeamento de rede e descoberta de serviços.
  - `Medusa`: Ferramenta modular para ataques de login remoto por força bruta.
  - `Wordlists`: Listas personalizadas para simulação de credenciais fracas.

---

## 🚀 Cenários de Teste

### 1. Brute Force em Serviço FTP
- **Objetivo:** Ganhar acesso ao servidor FTP do Metasploitable.
- **Comando base:** `medusa -h [IP_ALVO] -u msfadmin -P path/to/wordlist.txt -M ftp`
- **Resultado:** [Descreva se obteve sucesso ou o tempo de tentativa].

### 2. Automação de Formulário Web (DVWA)
- **Objetivo:** Testar a segurança do login da aplicação DVWA em nível "Low".
- **Módulo:** `web-form`
- **Aprendizado:** Entendimento de como os parâmetros de requisição HTTP são manipulados.

### 3. SMB Password Spraying
- **Objetivo:** Testar uma única senha comum contra vários usuários enumerados no serviço SMB.

---

## 🛡️ Medidas de Mitigação (Como Prevenir?)
A parte mais importante de uma auditoria é a correção. Para evitar os ataques acima, recomenda-se:
1. **Políticas de Senhas Fortes:** Exigir caracteres especiais, números e letras maiúsculas/minúsculas.
2. **MFA (Autenticação de Múltiplos Fatores):** Essencial para impedir acessos mesmo com a senha correta.
3. **Bloqueio de Conta (Account Lockout):** Bloquear o IP ou usuário após X tentativas falhas.
4. **Desabilitar Serviços Desnecessários:** Se o FTP não é vital, ele deve ser desativado.

---

## 📸 Evidências
*(Dica: Coloque aqui prints do terminal do Kali mostrando o Medusa encontrando a senha ou o Nmap escaneando as portas)*

---

## 👨‍💻 Autor
Desenvolvido por **[SEU NOME]**
[Seu LinkedIn] | [Seu Portfólio]
