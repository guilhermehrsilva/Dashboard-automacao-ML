# Fazendo o Python acessar um site e trazer o código dele para dentro do VS Code

import requests
from bs4 import BeautifulSoup

# 1. A URL do produto será inserida abaixo, nesse caso, um iPhone 16 no Mercado Livre Brasil)
url = "https://www.mercadolivre.com.br/apple-iphone-16-128-gb-preto-distribuidor-autorizado/p/MLB1040287808"

# 2. O "Pivotamento" (Headers)
# Sites bloqueiam robôs. Isso diz ao site: "Ei, sou um navegador Google Chrome, não um robô!"
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

# 3. Fazendo a requisição (Batendo na porta do site)
print("Acessando o site... ⏳")
response = requests.get(url, headers=headers)

# 4. Verificando se deu certo
if response.status_code == 200:
    print("Sucesso! O site permitiu nossa entrada. ✅")
    # Vamos ver um pedacinho do código do site
    site = BeautifulSoup(response.text, 'html.parser')
    print(site.title.text) # Mostra o título da aba do navegador
else:
    print("Falha ao acessar. ❌")
    print(f"Erro: {response.status_code}")