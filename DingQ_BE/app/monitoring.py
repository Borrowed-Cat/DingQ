import logging
import os
import time
from typing import Any, Dict

import psutil
from fastapi import HTTPException

logger = logging.getLogger(__name__)


class SystemMonitor:
    """시스템 모니터링 클래스"""

    @staticmethod
    def get_system_health() -> Dict[str, Any]:
        """시스템 상태 정보 반환"""
        try:
            # CPU 사용률
            cpu_percent = psutil.cpu_percent(interval=1)

            # 메모리 사용률
            memory = psutil.virtual_memory()

            # 디스크 사용률
            disk = psutil.disk_usage("/")

            # 네트워크 정보
            network = psutil.net_io_counters()

            return {
                "status": "healthy"
                if cpu_percent < 90 and memory.percent < 90
                else "warning",
                "cpu_percent": cpu_percent,
                "memory_percent": memory.percent,
                "memory_available_gb": round(memory.available / (1024**3), 2),
                "disk_percent": disk.percent,
                "disk_free_gb": round(disk.free / (1024**3), 2),
                "network_bytes_sent": network.bytes_sent,
                "network_bytes_recv": network.bytes_recv,
                "timestamp": time.time(),
            }
        except Exception as e:
            logger.error(f"System health check failed: {e}")
            return {"status": "error", "message": str(e)}


class DatabaseMonitor:
    """데이터베이스 모니터링 클래스"""

    @staticmethod
    def check_database_connection(db_manager) -> Dict[str, Any]:
        """데이터베이스 연결 상태 확인"""
        try:
            start_time = time.time()

            # 간단한 쿼리로 연결 테스트
            with db_manager.get_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1")
                    result = cur.fetchone()

            response_time = time.time() - start_time

            return {
                "status": "connected",
                "response_time_ms": round(response_time * 1000, 2),
                "timestamp": time.time(),
            }
        except Exception as e:
            logger.error(f"Database connection check failed: {e}")
            return {"status": "disconnected", "error": str(e), "timestamp": time.time()}


class APIMetrics:
    """API 메트릭 수집 클래스"""

    def __init__(self):
        self.request_count = 0
        self.error_count = 0
        self.response_times = []
        self.start_time = time.time()

    def record_request(self, response_time: float, status_code: int):
        """요청 메트릭 기록"""
        self.request_count += 1
        self.response_times.append(response_time)

        if status_code >= 400:
            self.error_count += 1

        # 최근 100개 요청만 유지
        if len(self.response_times) > 100:
            self.response_times.pop(0)

    def get_metrics(self) -> Dict[str, Any]:
        """현재 메트릭 반환"""
        uptime = time.time() - self.start_time

        avg_response_time = 0
        if self.response_times:
            avg_response_time = sum(self.response_times) / len(self.response_times)

        error_rate = 0
        if self.request_count > 0:
            error_rate = (self.error_count / self.request_count) * 100

        return {
            "uptime_seconds": round(uptime, 2),
            "total_requests": self.request_count,
            "error_count": self.error_count,
            "error_rate_percent": round(error_rate, 2),
            "avg_response_time_ms": round(avg_response_time * 1000, 2),
            "requests_per_minute": round(self.request_count / (uptime / 60), 2)
            if uptime > 0
            else 0,
        }


# 전역 메트릭 인스턴스
api_metrics = APIMetrics()


def get_comprehensive_health_check(db_manager=None) -> Dict[str, Any]:
    """종합 헬스체크"""
    health_status = {
        "service": "DingQ Backend",
        "status": "healthy",
        "timestamp": time.time(),
        "components": {},
    }

    # 시스템 상태 확인
    system_health = SystemMonitor.get_system_health()
    health_status["components"]["system"] = system_health

    # 데이터베이스 상태 확인
    if db_manager:
        db_health = DatabaseMonitor.check_database_connection(db_manager)
        health_status["components"]["database"] = db_health
    else:
        health_status["components"]["database"] = {"status": "not_configured"}

    # API 메트릭
    health_status["components"]["api_metrics"] = api_metrics.get_metrics()

    # 전체 상태 결정
    all_healthy = True
    for component, status in health_status["components"].items():
        if isinstance(status, dict) and status.get("status") not in [
            "healthy",
            "connected",
            "not_configured",
        ]:
            all_healthy = False
            break

    health_status["status"] = "healthy" if all_healthy else "degraded"

    return health_status
