# 🤖 Bot de Monitoramento de Preços (Python + Power BI)

## 📌 Sobre o Projeto
Projeto de Engenharia de Dados desenvolvido para automatizar o monitoramento de preços de produtos em e-commerce (Mercado Livre). O objetivo foi eliminar a verificação manual, criando um histórico de preços confiável para análise de tendências e tomada de decisão de compra.

O sistema coleta os dados automaticamente, trata as informações, armazena em histórico e alimenta um Dashboard interativo.

## ⚙️ Arquitetura da Solução
O pipeline de dados segue o fluxo:
1.  **Extração (Python):** Script de Web Scraping utilizando `Requests` e `BeautifulSoup`.
    * *Destaque:* Uso de extração via **Meta Tags** para garantir precisão no preço e evitar erros de HTML dinâmico.
    * *Resiliência:* Implementação de tratativa de erros (`Try/Except`) e fallback para captura de nomes de produtos.
2.  **Armazenamento (Excel/Pandas):**
    * Verificação automática de base histórica.
    * Modo "Append" para adicionar novos registros sem sobrescrever os antigos.
3.  **Automação (Windows):**
    * Criação de script executável (`.bat`).
    * Agendamento via **Windows Task Scheduler** para execução diária autônoma.
4.  **Visualização (Power BI):**
    * ETL no Power Query para limpeza de strings e tipagem de dados.
    * Dashboard para acompanhamento da variação de preço ao longo do tempo.

## 🛠️ Tecnologias Utilizadas
* **Linguagem:** Python 3.12
* **Bibliotecas:** `pandas`, `requests`, `beautifulsoup4`, `os`, `datetime`
* **Automação:** Windows Task Scheduler + Batch Script
* **Analytics:** Microsoft Excel & Power BI

## 🚀 Como Executar
1.  Clone o repositório.
2.  Instale as dependências:
    ```bash
    pip install pandas requests beautifulsoup4 openpyxl
    ```
3.  Insira a URL do produto desejado no arquivo `scraperfinal.py`.
4.  Execute o script diariamente ou configure o agendamento no Windows.

## 📊 Resultado Visual
*[Dashboard do Power BI](https://github.com/guilhermehrsilva/Dashboard-automacao-ML/blob/main/dashboard/Dashboard.jpg)*

---
*Projeto desenvolvido como parte do meu portfólio de Dados.*
