from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

DATABASE_URL = URL.create(
    drivername="postgresql+psycopg2",
    username="postgres",
    password="5386537Rla!",
    host="db.gymafrgoigrhzcmrfjhj.supabase.co",
    port=5432,
    database="postgres",
    query={"sslmode": "require"},
)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

with engine.connect() as conn:
    print(conn.execute(text("select 1")).scalar())