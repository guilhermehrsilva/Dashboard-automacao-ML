import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime
import os

# --- 1. CONFIGURAÇÕES ---
# 1.1. Descobre onde este script está salvo no seu PC
pasta_atual = os.path.dirname(os.path.abspath(__file__))

# 1.2. Cria o caminho completo para o Excel ficar na mesma pasta
arquivo_excel = os.path.join(pasta_atual, "historico_precos.xlsx")

# 1.3. Seu Link do Mercado Livre
url = "https://www.mercadolivre.com.br/apple-iphone-16-128-gb-preto-distribuidor-autorizado/p/MLB1040287808"

# ... 1.4. Nome do arquivo Excel onde os dados serão salvos
arquivo_excel = "historico_precos.xlsx"

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

print("🔎 Lendo o site...")

try:
    response = requests.get(url, headers=headers)
    
    if response.status_code == 200:
        site = BeautifulSoup(response.text, 'html.parser')

        # --- 2. EXTRAÇÃO DE DADOS ---
        # Tenta achar o PREÇO
        meta_preco = site.find("meta", itemprop="price")
        
        if meta_preco:
            # Converte o preço para número decimal
            preco_final = float(meta_preco["content"])
            
            # Tenta achar o NOME (Com proteção contra erro)
            meta_nome = site.find("meta", itemprop="name")
            
            if meta_nome:
                # Se achou a etiqueta de nome, usa ela
                nome_produto = meta_nome["content"]
            else:
                # Se não achou, pega o título da aba do navegador (Plano B)
                print("⚠️ Etiqueta de nome não encontrada. Usando o título da página.")
                nome_produto = site.title.text.strip()

            data_agora = datetime.now().strftime("%d/%m/%Y %H:%M:%S")

            print(f"✅ Preço Capturado: R$ {preco_final}")
            print(f"📦 Produto: {nome_produto}")

            # --- 3. SALVANDO NO EXCEL ---
            novo_dado = {
                "Data Coleta": [data_agora],
                "Produto": [nome_produto],
                "Preço": [preco_final],
                "Link": [url]
            }
            
            df_novo = pd.DataFrame(novo_dado)

            if os.path.exists(arquivo_excel):
                # Se o arquivo já existe, abre e adiciona embaixo (Append)
                df_antigo = pd.read_excel(arquivo_excel)
                df_final = pd.concat([df_antigo, df_novo], ignore_index=True)
                print("📂 Arquivo existente atualizado.")
            else:
                # Se não existe, cria um novo
                df_final = df_novo
                print("🆕 Arquivo Novo criado.")

            df_final.to_excel(arquivo_excel, index=False)
            print("💾 Sucesso! Dados salvos.")
            
        else:
            print("⚠️ Erro: Não encontrei a etiqueta de preço (meta itemprop='price').")
            print("O Mercado Livre pode ter mudado a página ou o produto está pausado.")

    else:
        print(f"❌ Erro de conexão: {response.status_code}")

except Exception as e:
    print(f"❌ Ocorreu um erro inesperado: {e}")

