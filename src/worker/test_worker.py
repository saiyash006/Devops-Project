import sys
import os

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

def test_process_appointment():
    # Simple unit test for the worker logic
    from worker import process_appointment
    # Assuming WORKER_CRASH is not set during tests
    os.environ["WORKER_CRASH"] = "false"
    result = process_appointment({"patient_id": 1, "date": "2026-09-19", "details": "Checkup"})
    assert result == "processed"
