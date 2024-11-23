from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, ValidationError
from joblib import load
import pandas as pd  # Import pandas
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

# Load the saved model and scaler
model = load("Food_waste_Analysis_By_Country.joblib")
scaler = load("scaler_model.joblib")

# Initialize FastAPI app
app = FastAPI()

# Add CORS middleware to handle cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins; restrict this in production
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers
)

# Define input data model with constraints using Pydantic
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

# Custom exception handler to customize error message
@app.exception_handler(ValidationError)
async def validation_exception_handler(request, exc: ValidationError):
    # Creating a custom message for the validation error
    error_messages = []
    
    for error in exc.errors():
        loc = error.get("loc")[-1]  # Get the field name from the location
        msg = f"Input for {loc} is out of range. Please provide a value between the specified limits."
        error_messages.append({
            "msg": msg,
            "loc": error.get("loc"),
            "input_value": error.get("input"),
            "constraint": error.get("ctx"),
        })
    
    # Return a customized response with the new error message
    return JSONResponse(
        status_code=422,
        content={"detail": error_messages},
    )

# Define the prediction endpoint
@app.post("/predict")
def predict(data: PredictionRequest):
    # Prepare input data for the model as a pandas DataFrame with the correct feature names
    input_data = pd.DataFrame([[data.household_estimate, data.retail_estimate, data.food_service_estimate]],
                              columns=['Household estimate (kg/capita/year)', 
                                       'Retail estimate (kg/capita/year)', 
                                       'Food service estimate (kg/capita/year)'])
    
    # Print to verify the input data format (this is for debugging purposes)
    print("Input Data (DataFrame):")
    print(input_data)

    # Scale the data using the loaded scaler (ensure it was fitted with the same feature names)
    input_data_scaled = scaler.transform(input_data)
    
    # Make a prediction using the loaded model
    prediction = model.predict(input_data_scaled)

    # Return the prediction as a JSON response
    return {"prediction": round(prediction[0], 2)}
