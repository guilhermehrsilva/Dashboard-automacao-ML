import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime

# 1. Configurações Iniciais
url = "https://www.mercadolivre.com.br/apple-iphone-16-128-gb-preto-distribuidor-autorizado/p/MLB1040287808" 
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

print("🔎 Investigando o site...")
response = requests.get(url, headers=headers)

if response.status_code == 200:
    site = BeautifulSoup(response.text, 'html.parser')
    
    # 2. A Técnica Meta Tag (Mais precisa para busca de preço)
    # O site esconde o preço real aqui para o Google ler
    meta_preco = site.find("meta", itemprop="price")
    
    if meta_preco:
        # Pega o conteúdo da tag (ex: "4299.00")
        preco_final = meta_preco["content"]
        
        # Pega o nome do produto também da meta tag para vir limpo
        meta_nome = site.find("meta", itemprop="name")
        nome_produto = meta_nome["content"] if meta_nome else site.title.text

        print(f"✅ Sucesso! Preço Real Identificado: R$ {preco_final}")
        
        # 3. Salvando
        dados = {
            "Data": datetime.now().strftime("%d/%m/%Y %H:%M"),
            "Produto": nome_produto,
            "Preço": float(preco_final) # Já converte para número decimal
        }
        
        # Cria a tabela (DataFrame) e mostra
        df = pd.DataFrame([dados])
        print("\n--- Tabela Capturada ---")
        print(df)
        
        # Opcional: Salvar em Excel de verdade
        # df.to_excel("monitoramento_precos.xlsx", index=False)
        
    else:
        print("⚠️ Não achei a Meta Tag de preço. O site pode ter mudado a estrutura.")
        # Debug: Imprime o título para ver se não fomos bloqueados
        print(f"Título da página acessada: {site.title.text}")

else:
    print("❌ Erro de conexão.")