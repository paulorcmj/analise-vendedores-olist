import sqlite3
from pathlib import Path

import pandas as pd

con = sqlite3.connect("olist.db")

for arquivo in Path("data").glob("*.csv"):
    tabela = arquivo.stem.replace("olist_", "").replace("_dataset", "")
    pd.read_csv(arquivo).to_sql(tabela, con, if_exists="replace", index=False)
    print("carregada:", tabela)

con.close()