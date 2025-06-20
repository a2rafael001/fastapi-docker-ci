from fastapi import FastAPI, Depends, HTTPException
from fastapi.responses import HTMLResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from src import models, schemas
from src.database import init_db, get_db
from contextlib import asynccontextmanager


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield


app = FastAPI(lifespan=lifespan)


@app.get("/", response_class=HTMLResponse)
async def read_root():
    return """
    <!DOCTYPE html>
    <html lang="ru">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Management</title>
        <style>
            :root {
                --primary: #4361ee;
                --secondary: #3f37c9;
                --light: #f8f9fa;
                --dark: #212529;
                --success: #4cc9f0;
            }
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                line-height: 1.6;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
                padding: 2rem;
                color: var(--dark);
            }
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: white;
                border-radius: 12px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                overflow: hidden;
            }
            header {
                background: var(--primary);
                color: white;
                padding: 2rem;
                text-align: center;
            }
            h1 {
                font-size: 2.5rem;
                margin-bottom: 0.5rem;
            }
            .subtitle {
                font-weight: 300;
                opacity: 0.9;
            }
            .content {
                padding: 2rem;
            }
            .endpoints {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                gap: 1.5rem;
                margin-top: 2rem;
            }
            .endpoint-card {
                background: var(--light);
                border-radius: 8px;
                padding: 1.5rem;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                border-left: 4px solid var(--primary);
            }
            .endpoint-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            }
            .method {
                display: inline-block;
                padding: 0.25rem 0.75rem;
                border-radius: 4px;
                font-weight: bold;
                font-size: 0.8rem;
                text-transform: uppercase;
                margin-right: 0.5rem;
            }
            .get { background: #48cae4; color: white; }
            .post { background: #52b788; color: white; }
            .patch { background: #ffd166; color: #333; }
            .delete { background: #ef476f; color: white; }
            .path {
                font-family: monospace;
                font-size: 1.1rem;
                color: var(--secondary);
            }
            .description {
                margin-top: 0.5rem;
                color: #555;
            }
            .btn {
                display: inline-block;
                margin-top: 2rem;
                padding: 0.8rem 1.5rem;
                background: var(--primary);
                color: white;
                text-decoration: none;
                border-radius: 6px;
                font-weight: 500;
                transition: background 0.3s ease;
            }
            .btn:hover {
                background: var(--secondary);
            }
            @media (max-width: 768px) {
                body {
                    padding: 1rem;
                }
                .container {
                    border-radius: 8px;
                }
                header {
                    padding: 1.5rem;
                }
                h1 {
                    font-size: 2rem;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <h1>Система управления пользователями</h1>
            </header>
            <div class="content">
                <p>Доступные методы API:</p>
                
                <div class="endpoints">
                    <div class="endpoint-card">
                        <span class="method get">GET</span>
                        <span class="path">/users/</span>
                        <p class="description">Получить список всех пользователей</p>
                    </div>
                    
                    <div class="endpoint-card">
                        <span class="method post">POST</span>
                        <span class="path">/users/</span>
                        <p class="description">Создать нового пользователя</p>
                    </div>
                    
                    <div class="endpoint-card">
                        <span class="method get">GET</span>
                        <span class="path">/users/{id}</span>
                        <p class="description">Получить пользователя по ID</p>
                    </div>
                    
                    <div class="endpoint-card">
                        <span class="method patch">PATCH</span>
                        <span class="path">/users/{id}</span>
                        <p class="description">Обновить данные пользователя</p>
                    </div>
                    
                    <div class="endpoint-card">
                        <span class="method delete">DELETE</span>
                        <span class="path">/users/{id}</span>
                        <p class="description">Удалить пользователя</p>
                    </div>
                </div>
                
                <a href="/villani/users/" class="btn">Перейти к API</a>
            </div>
        </div>
    </body>
    </html>
    """


@app.post("/users/", response_model=schemas.User)
async def create_user(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    db_user = models.User(name=user.name)
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user


@app.get("/users/", response_model=list[schemas.User])
async def read_users(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.User).offset(skip).limit(limit))
    return result.scalars().all()


@app.get("/users/{user_id}", response_model=schemas.User)
async def read_user(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return user


@app.patch("/users/{user_id}", response_model=schemas.User)
async def update_user(user_id: int, user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    db_user = result.scalar_one_or_none()
    if not db_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    db_user.name = user.name
    await db.commit()
    await db.refresh(db_user)
    return db_user


@app.delete("/users/{user_id}", response_model=dict)
async def delete_user(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.User).where(models.User.id == user_id))
    db_user = result.scalar_one_or_none()
    if not db_user:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    await db.delete(db_user)
    await db.commit()
    return {"status": "success", "message": "Пользователь удален"}
