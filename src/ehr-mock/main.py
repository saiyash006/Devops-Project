import os
import time
import random
import asyncio
from fastapi import FastAPI, HTTPException

app = FastAPI(title="EHR Mock Service")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/ehr-data")
async def get_ehr_data(mode: str = None):
    # mode can be overridden by query param, else defaults to env var
    actual_mode = mode if mode else os.getenv("EHR_MODE", "ok")
    
    if actual_mode == "ok":
        return {"data": "patient_ehr_details"}
    elif actual_mode == "slow":
        await asyncio.sleep(2)
        return {"data": "patient_ehr_details_delayed"}
    elif actual_mode == "timeout":
        await asyncio.sleep(10)
        return {"data": "timeout_occurred"} # Client should have timed out
    elif actual_mode == "500":
        raise HTTPException(status_code=500, detail="Internal Server Error from EHR")
    elif actual_mode == "unauthorized":
        raise HTTPException(status_code=401, detail="Unauthorized")
    elif actual_mode == "flaky":
        if random.random() < 0.5:
            raise HTTPException(status_code=500, detail="Flaky error")
        return {"data": "patient_ehr_details_flaky_success"}
    else:
        return {"data": "unknown_mode"}
