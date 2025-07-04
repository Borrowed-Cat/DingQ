import os
from typing import Any, Dict, List, Optional

import numpy as np
import psycopg2
from dotenv import load_dotenv
from psycopg2.extras import RealDictCursor
from sqlalchemy import (JSON, Column, DateTime, Integer, LargeBinary, String,
                        Text, create_engine)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.sql import func

load_dotenv()

# Database configuration
DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://postgres:password@localhost:5432/dingq_db"
)

# SQLAlchemy setup
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# ORM Models
class UserSketch(Base):
    __tablename__ = "user_sketches"

    id = Column(Integer, primary_key=True, index=True)
    user_ip = Column(String(45), index=True)
    sketch_data = Column(LargeBinary, nullable=False)
    original_filename = Column(String(255))
    content_type = Column(String(100))
    file_size = Column(Integer)
    search_results = Column(JSON)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    processed_at = Column(DateTime(timezone=True))


class SvgIcon(Base):
    __tablename__ = "svg_icons"

    id = Column(Integer, primary_key=True, index=True)
    icon_name = Column(String(255), nullable=False)
    svg_path = Column(String(500), nullable=False)
    category = Column(String(100), index=True)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )


# FastAPI dependency for database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# Create tables
def create_tables():
    Base.metadata.create_all(bind=engine)


# Legacy DatabaseManager for backward compatibility
class DatabaseManager:
    def __init__(self):
        self.connection_string = DATABASE_URL

    def get_connection(self):
        """데이터베이스 연결 반환"""
        return psycopg2.connect(self.connection_string)

    def search_similar_icons(
        self, vector_features: np.ndarray, top_n: int = 5
    ) -> List[Dict[str, Any]]:
        """벡터 유사도 검색"""
        try:
            with self.get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    # 벡터를 PostgreSQL 배열 형식으로 변환
                    vector_str = "[" + ",".join(map(str, vector_features)) + "]"

                    query = """
                    SELECT 
                        id, icon_name, svg_path, category, description, tags,
                        1 - (vector_features <=> %s::vector) as similarity_score
                    FROM svg_icons 
                    WHERE vector_features IS NOT NULL
                    ORDER BY vector_features <=> %s::vector
                    LIMIT %s
                    """

                    cur.execute(query, (vector_str, vector_str, top_n))
                    results = cur.fetchall()

                    return [dict(row) for row in results]

        except Exception as e:
            print(f"Database search error: {e}")
            return []

    def get_all_icons(self) -> List[Dict[str, Any]]:
        """모든 아이콘 조회"""
        try:
            with self.get_connection() as conn:
                with conn.cursor(cursor_factory=RealDictCursor) as cur:
                    cur.execute("SELECT * FROM svg_icons ORDER BY icon_name")
                    results = cur.fetchall()
                    return [dict(row) for row in results]
        except Exception as e:
            print(f"Database query error: {e}")
            return []

    def update_icon_vector(self, icon_name: str, vector_features: np.ndarray) -> bool:
        """아이콘의 벡터 특징 업데이트"""
        try:
            with self.get_connection() as conn:
                with conn.cursor() as cur:
                    vector_str = "[" + ",".join(map(str, vector_features)) + "]"

                    cur.execute(
                        "UPDATE svg_icons SET vector_features = %s::vector WHERE icon_name = %s",
                        (vector_str, icon_name),
                    )
                    conn.commit()
                    return cur.rowcount > 0
        except Exception as e:
            print(f"Database update error: {e}")
            return False


# 전역 데이터베이스 매니저 인스턴스
db_manager = DatabaseManager()


# Helper functions for sketch management
def save_user_sketch(
    db: Session,
    user_ip: str,
    sketch_data: bytes,
    original_filename: str,
    content_type: str,
    file_size: int,
    search_results: dict,
) -> UserSketch:
    """사용자 스케치 저장"""
    sketch = UserSketch(
        user_ip=user_ip,
        sketch_data=sketch_data,
        original_filename=original_filename,
        content_type=content_type,
        file_size=file_size,
        search_results=search_results,
        processed_at=func.now(),
    )
    db.add(sketch)
    db.commit()
    db.refresh(sketch)
    return sketch


def get_user_sketches(db: Session, user_ip: str, limit: int = 10) -> List[UserSketch]:
    """사용자 스케치 조회"""
    return (
        db.query(UserSketch)
        .filter(UserSketch.user_ip == user_ip)
        .order_by(UserSketch.created_at.desc())
        .limit(limit)
        .all()
    )
