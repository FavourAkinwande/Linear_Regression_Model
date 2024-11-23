from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, ValidationError
from joblib import load
import pandas as pd  # Import pandas
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse


model = load("Food_waste_Analysis_By_Country.joblib")
scaler = load("scaler_model.joblib")


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_methods=["*"],  
    allow_headers=["*"], 
)


class PredictionRequest(BaseModel):
    household_estimate: float = Field(
        ..., 
        ge=0, 
        le=100, 
        description="Household estimate in kg/capita/year, should be between 0 and 100",
        example=45.5
    )
    retail_estimate: float = Field(
        ..., 
        ge=0, 
        le=100, 
        description="Retail estimate in kg/capita/year, should be between 0 and 100",
        example=20.3
    )
    food_service_estimate: float = Field(
        ..., 
        ge=0, 
        le=100, 
        description="Food service estimate in kg/capita/year, should be between 0 and 100",
        example=15.2
    )


@app.exception_handler(ValidationError)
async def validation_exception_handler(request, exc: ValidationError):
    
    error_messages = []
    
    for error in exc.errors():
        loc = error.get("loc")[-1]  
        msg = f"Input for {loc} is out of range. Please provide a value between the specified limits."
        error_messages.append({
            "msg": msg,
            "loc": error.get("loc"),
            "input_value": error.get("input"),
            "constraint": error.get("ctx"),
        })
    
    
    return JSONResponse(
        status_code=422,
        content={"detail": error_messages},
    )


@app.post("/predict")
def predict(data: PredictionRequest):
    
    input_data = pd.DataFrame([[data.household_estimate, data.retail_estimate, data.food_service_estimate]],
                              columns=['Household estimate (kg/capita/year)', 
                                       'Retail estimate (kg/capita/year)', 
                                       'Food service estimate (kg/capita/year)'])
    
    
    print("Input Data (DataFrame):")
    print(input_data)

    
    input_data_scaled = scaler.transform(input_data)
    
  
    prediction = model.predict(input_data_scaled)

   
    return {"prediction": round(prediction[0], 2)}
