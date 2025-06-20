from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import URL

url_object = URL.create(drivername="postgresql+psycopg",
                 username="kubsu",
                 password="kubsu",
                 host="127.0.0.1",
                 port="5432", 
                 database="kubsu")


engine = create_async_engine(url_object, echo=True)
AsyncSessionLocal = sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()


async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        yield session
