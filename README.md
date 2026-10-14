# Análise de vendedores da Olist

Análise dos vendedores do marketplace da Olist usando SQL (SQLite). Procurei responder quatro perguntas: onde estão os vendedores, quem mais vende, quanto do faturamento se concentra em poucos vendedores e se os que mais atrasam têm notas piores.

Faz parte de uma série de projetos que trabalham com o mesmo dataset: [analise-vendas-olist](https://github.com/paulorcmj/analise-vendas-olist) (análise em Python) e [dashboard-vendas-olist](https://github.com/paulorcmj/dashboard-vendas-olist) (dashboard em Power BI).

## Dados

Dataset público de e-commerce da Olist, disponível no Kaggle (9 arquivos CSV). Os arquivos não estão no repositório por causa do tamanho.

## O que encontrei

- Dos 3.095 vendedores, 59,7% estão em SP, que também concentra 64,4% do valor vendido. Seis estados (SP, PR, MG, RJ, SC e RS) respondem por 94,7% do valor.
- No topo do ranking quase todos são de SP, mas os perfis variam: há quem venda muito de itens baratos e quem venda pouco de itens caros. Um vendedor da Bahia aparece em segundo lugar e responde por cerca de 78% do que o estado vendeu.
- Nenhum vendedor passa de 2% do faturamento, porém, os 100 maiores juntos ficam com 45,3% e os 500 maiores com 78,4%.
- Entre os vendedores com pelo menos 50 pedidos, existe uma correlação de -0,50 entre percentual de atrasos e nota média: quem atrasa mais tende a ter nota pior, no entanto, a relação é moderada.

As consultas completas estão em [sql/consultas.sql](sql/consultas.sql) e, com os resultados e comentários, em [notebooks/01_consultas.ipynb](notebooks/01_consultas.ipynb).

## Limitações

- O valor vendido considera apenas o preço dos itens (sem frete) e exclui pedidos cancelados e indisponíveis.
- A análise de atrasos e notas usa somente vendedores com pelo menos 50 pedidos entregues. São 425 vendedores, que respondem por 68,1% do valor entregue.
- A correlação mostra que atraso e nota andam juntos, mas não prova que o atraso causa a nota baixa, e não testei se o tipo de produto influencia.

## Como reproduzir

1. Baixar os CSVs no Kaggle e colocá-los na pasta `data`.
2. Criar o ambiente virtual e instalar as bibliotecas: `py -m venv .venv`, ativar com `.venv\Scripts\activate` e `pip install pandas matplotlib jupyter`.
3. Criar o banco: `py criar_banco.py`.
4. Abrir `notebooks/01_consultas.ipynb` e rodar as células.